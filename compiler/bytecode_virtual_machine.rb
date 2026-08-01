# frozen_string_literal: true

require 'json'
require 'set'
require_relative 'ast_nodes'
require_relative 'bytecode_contract'
require_relative 'bytecode_loader'
require_relative 'text_literal'
require_relative 'world_save'

module BasicSharp
  class BytecodeVirtualMachineError < ArgumentError; end

  # Executes only completely validated BSharp Bytecode models.
  # It intentionally does not depend on BasicSharp::Runtime or reconstruct BSIR.
  class BytecodeVirtualMachine
    MAX_WHOLE_NUMBER = 2_147_483_647
    MAX_FOLLOW_UP_EVENTS = 1_024
    EVENT_CHAIN_LIMIT_MESSAGE = [
      'Events kept causing more events.',
      '',
      'BASIC# stopped this chain after 1,024 follow-up events so it would not run forever.'
    ].join("\n").freeze

    VALUE_NAME_PATTERN = /\A[a-z][a-z0-9]*\z/
    OPPOSITE_STATES = {
      'open' => 'closed', 'closed' => 'open',
      'locked' => 'unlocked', 'unlocked' => 'locked',
      'alive' => 'dead', 'dead' => 'alive',
      'calm' => 'angry', 'angry' => 'calm',
      'friendly' => 'hostile', 'hostile' => 'friendly',
      'visible' => 'hidden', 'hidden' => 'visible',
      'carried' => 'dropped', 'dropped' => 'carried',
      'broken' => 'whole', 'whole' => 'broken',
      'on' => 'off', 'off' => 'on'
    }.freeze

    attr_reader :startup_ran, :startup_if_rules, :startup_if_error, :startup_follow_up_events

    def game_declarations
      canonical_game_data({
        'controls' => @program.fetch(:controls, []),
        'hover' => @program.fetch(:hover_declarations, []),
        'context' => @program.fetch(:context_declarations, [])
      })
    end

    def canonical_game_data(value)
      case value
      when Hash then value.each_with_object({}) { |(key, entry), result| result[key.to_s] = canonical_game_data(entry) unless %w[line_number raw].include?(key.to_s) }
      when Array then value.map { |entry| canonical_game_data(entry) }
      else value
      end
    end
    private :canonical_game_data

    def initialize(loader, world_save: nil)
      unless loader.is_a?(BytecodeLoader)
        raise BytecodeVirtualMachineError,
              'The BSharp Virtual Machine accepts only a successfully validated BytecodeLoader.'
      end

      @loader = loader
      @program = loader.model
      validate_profile!
      build_indexes
      create_world
      execute_start_records
      @if_active = Array.new(@program.fetch(:if_rules).length, false)
      @startup_ran = []
      @startup_if_rules = []
      @startup_if_error = nil
      @startup_follow_up_events = []
      @world_origin = world_save ? 'BSharp Save' : 'START'
      @loaded_world_save = world_save ? stringify_keys(world_save) : nil

      if world_save
        restore_world_save!(world_save)
      else
        settlement = settle_if_rules(cause: 'START')
        @startup_if_rules = settlement.fetch('rules')
        @startup_if_error = settlement['error']
        @startup_ran = @startup_if_rules.flat_map do |entry|
          entry.fetch('steps').map { |step| step.fetch('word') }
        end

        if @startup_if_error.nil? && !settlement.fetch('follow_ups').empty?
          chain = drain_follow_up_events(settlement.fetch('follow_ups'))
          @startup_follow_up_events = chain.fetch('events')
          @startup_if_error = chain['error']
        end
        @save_ready = @startup_if_error.nil?
      end
    end

    def run_event(text)
      @save_ready = false
      root = process_event(normalize(text))
      queued = root.delete('_follow_ups') || []
      root_fatal_error = root.delete('_fatal_error')
      chain = if root_fatal_error
                { 'events' => [], 'error' => nil, 'trail' => [] }
              else
                drain_follow_up_events(queued)
              end

      root['follow_up_events'] = chain.fetch('events')
      root['event_trail'] = chain.fetch('trail')
      root['error'] ||= chain['error']
      root['state'] = snapshot
      @save_ready = root.fetch('matched') && root['error'].nil?
      root
    end

    def snapshot
      @world.map do |thing|
        entry = {
          'name' => thing.fetch(:name),
          'kind' => kind_name(thing.fetch(:kind_index)),
          'builtin' => thing.fetch(:builtin),
          'states' => thing.fetch(:states).to_a.sort,
          'relations' => thing.fetch(:relations).sort.to_h,
          'values' => thing.fetch(:values).sort.to_h
        }
        damage = thing.fetch(:values).fetch('damage', 0)
        entry['damage'] = damage if damage.positive?
        entry
      end
    end

    def program_fingerprint
      @program.fetch(:fingerprint)
    end

    def meaning_profile
      @program.fetch(:meaning_profile)
    end

    def save_ready?
      @save_ready == true
    end

    def world_save_state
      unless save_ready?
        raise WorldSaveError, 'BSharp Save was not written because the world did not finish a successful event.'
      end

      {
        'settled' => true,
        'things' => snapshot.map do |thing|
          saved = thing.reject { |key, _| key == 'damage' }
          saved['values'] = typed_save_values(saved.fetch('values')) unless meaning_profile == WorldSave::MEANING_PROFILE_1
          saved
        end,
        'if_rules' => @program.fetch(:if_rules).each_with_index.map do |rule, index|
          {
            'index' => index,
            'condition' => canonical_condition(rule.fetch(:condition)),
            'active' => @if_active.fetch(index)
          }
        end
      }
    end

    def write_world_save(path)
      WorldSave.write(path, self)
    end

    def restore_world_save!(document)
      WorldSave.validate_header_for_fingerprint!(document, program_fingerprint, meaning_profile: meaning_profile)
      candidate_world, candidate_if_active = validate_world_save_state!(document['world'], save_version: document['format_version'])
      @world = candidate_world
      @if_active = candidate_if_active
      @startup_ran = []
      @startup_if_rules = []
      @startup_if_error = nil
      @startup_follow_up_events = []
      @world_origin = 'BSharp Save'
      @loaded_world_save = stringify_keys(document)
      @save_ready = true
      self
    end

    def ask_thing(name)
      canonical = normalize(name)
      snapshot.find { |entry| entry.fetch('name') == canonical }
    end

    def ask_kind(name)
      canonical = normalize(name)
      index = @kinds.index { |kind| kind.fetch(:name) == canonical }
      return nil if index.nil?

      parent_index = @kinds.fetch(index).fetch(:parent_index)
      {
        'name' => canonical,
        'parent' => parent_index == BytecodeContract::NO_REFERENCE_U32 ? nil : kind_name(parent_index),
        'thing_count' => ask_kind_members(canonical).length
      }
    end

    def ask_resolve_kind(text)
      supplied = normalize(text)
      matches = @kinds.filter_map do |kind|
        name = kind.fetch(:name)
        name if supplied == name || supplied == ask_plural_kind(name)
      end
      matches.length == 1 ? matches.first : nil
    end

    def ask_kind_members(kind_text)
      canonical = normalize(kind_text)
      kind_index = @kinds.index { |kind| kind.fetch(:name) == canonical }
      return [] if kind_index.nil?

      @world.each_index.filter_map do |index|
        distance = kind_distance(@things.fetch(index).fetch(:kind_index), kind_index)
        next if distance.nil?

        {
          'name' => thing_name(index),
          'kind' => kind_name(@things.fetch(index).fetch(:kind_index)),
          'inherited' => distance.positive?,
          'distance' => distance
        }
      end
    end

    def ask_event_match(event_text)
      event = normalize(event_text)
      match = find_event_match(event)
      unless match[:event]
        return {
          'matched' => false, 'matched_when' => nil, 'understood' => [],
          'actions' => [], 'error' => match[:error]
        }
      end

      rule = match.fetch(:event)
      context = match.fetch(:context)
      {
        'matched' => true,
        'matched_when' => canonical_event_pattern(rule),
        'understood' => context_explanations(rule, context),
        'actions' => @blocks.fetch(rule.fetch(:block_index)).fetch(:instructions).map { |instruction| ask_action_text(instruction) },
        'error' => nil
      }
    end

    def ask_if_rules
      @program.fetch(:if_rules).each_with_index.map do |rule, index|
        {
          'index' => index,
          'condition' => canonical_condition(rule.fetch(:condition)),
          'true' => condition_true?(rule.fetch(:condition)),
          'active' => @if_active.fetch(index)
        }
      end
    end

    def ask_world_summary
      things = snapshot
      rules = ask_if_rules
      summary = {
        'origin' => @world_origin,
        'settled' => save_ready?,
        'things' => things.length,
        'kinds_used' => things.map { |thing| thing.fetch('kind') }.uniq.length,
        'true_if_rules' => rules.count { |rule| rule.fetch('true') },
        'if_rules' => rules.length,
        'whole_number_values' => things.sum { |thing| thing.fetch('values').values.count { |value| value.is_a?(Integer) } }
      }
      unless meaning_profile == WorldSave::MEANING_PROFILE_1
        summary['text_values'] = things.sum { |thing| thing.fetch('values').values.count { |value| value.is_a?(String) } }
      end
      summary
    end

    def ask_save_summary
      unless @loaded_world_save
        return {
          'loaded' => false, 'format_version' => nil, 'settled' => save_ready?,
          'things' => snapshot.length, 'fingerprint_matched' => nil
        }
      end

      {
        'loaded' => true,
        'format_version' => @loaded_world_save['format_version'],
        'settled' => @loaded_world_save.dig('world', 'settled') == true,
        'things' => Array(@loaded_world_save.dig('world', 'things')).length,
        'fingerprint_matched' => true
      }
    end

    def report(event_result)
      lines = []
      lines << "BSharp Virtual Machine v#{VERSION}"
      lines << "event: #{event_result.fetch('event')}"
      lines << "matched: #{event_result.fetch('matched') ? 'yes' : 'no'}"
      lines << "error: #{event_result.fetch('error')}" if event_result['error']
      if event_result['matched_when']
        lines << 'what matched:'
        lines << "  #{event_result.fetch('matched_when')}"
      end
      unless event_result.fetch('understood', []).empty?
        lines << 'what I understood:'
        event_result.fetch('understood').each { |line| lines << "  #{line}" }
      end
      unless event_result.fetch('selections', []).empty?
        lines << 'what I selected:'
        append_selection_report(lines, event_result.fetch('selections'), indent: '  ')
      end
      unless startup_if_rules.empty?
        lines << 'starting IF rules:'
        append_if_rule_report(lines, startup_if_rules)
      end
      unless startup_follow_up_events.empty?
        lines << 'starting follow-up events:'
        append_follow_up_report(lines, startup_follow_up_events)
      end
      lines << "starting IF error: #{startup_if_error}" if startup_if_error
      unless event_result.fetch('steps', []).empty?
        lines << 'what happened:'
        append_steps_report(lines, event_result.fetch('steps'), indent: '  ')
      end
      unless event_result.fetch('if_rules', []).empty?
        lines << 'IF rules:'
        append_if_rule_report(lines, event_result.fetch('if_rules'))
      end
      unless event_result.fetch('follow_up_events', []).empty?
        lines << 'what happened next:'
        append_follow_up_report(lines, event_result.fetch('follow_up_events'))
      end
      if event_result['error'] == EVENT_CHAIN_LIMIT_MESSAGE && !event_result.fetch('event_trail', []).empty?
        lines << 'last events before BASIC# stopped:'
        event_result.fetch('event_trail').each { |event| lines << "  #{event}" }
      end
      lines << 'world state:'
      snapshot.each { |thing| lines << "  #{format_thing(thing)}" }
      lines.join("\n")
    end

    def execute_context_action(action, object_name)
      supplied = deep_symbolize(action)
      index = @thing_indexes_by_name[normalize(object_name)]
      raise BytecodeVirtualMachineError, "Context action object '#{object_name}' is not defined." unless index

      @save_ready = false
      step, follow_up = execute_semantic_context_action(supplied, index)
      settlement = settle_if_rules(cause: 'context')
      chain = drain_follow_up_events(([follow_up].compact + settlement.fetch('follow_ups', [])))
      error = settlement['error'] || chain['error']
      @save_ready = error.nil?
      {
        'object' => normalize(object_name),
        'ran' => [step && step['word']].compact,
        'steps' => [step].compact,
        'if_rules' => settlement.fetch('rules'),
        'follow_up_events' => chain.fetch('events'),
        'error' => error,
        'state' => snapshot
      }
    end

    private

    def execute_semantic_context_action(action, target_index)
      target = world_thing(target_index)
      name = normalize(action.fetch(:action))
      case name
      when 'change'
        if action[:value_name]
          value_name = normalize(action[:value_name])
          new_value = action.key?(:to_text) ? action[:to_text] : action[:to_amount]
          target.fetch(:values)[value_name] = new_value
          return [{ 'word' => "(change #{value_name} of #{target.fetch(:name)} to #{new_value}", 'change' => "#{target.fetch(:name)} #{value_name} changed" }, nil]
        end
        state = normalize(action.dig(:to, :name) || action.dig(:to, :text))
        set_state(target, state, OPPOSITE_STATES[state])
        [{ 'word' => "(change #{target.fetch(:name)} to #{state}", 'change' => "#{target.fetch(:name)} is now #{state}" }, nil]
      when 'damage'
        amount = action.fetch(:amount, 1)
        target.fetch(:values)['damage'] = target.fetch(:values).fetch('damage', 0) + amount
        [{ 'word' => "(damage #{target.fetch(:name)}", 'change' => "#{target.fetch(:name)} damage is now #{target.fetch(:values)['damage']}" }, nil]
      when 'unlock'
        set_state(target, 'unlocked')
        [{ 'word' => "(unlock #{target.fetch(:name)}", 'change' => "#{target.fetch(:name)} is now unlocked" }, nil]
      when 'carry'
        target.fetch(:relations)['carried by'] = 'player'
        [{ 'word' => "(carry #{target.fetch(:name)}", 'change' => "#{target.fetch(:name)} is now carried by player" }, nil]
      when 'cause'
        event = action.fetch(:event)
        raw = event.fetch(:raw).to_s.gsub(/\bit\b/, target.fetch(:name))
        [{ 'word' => "(cause #{raw}", 'change' => "event queued: #{raw}" }, { 'event' => raw, 'caused_by' => "(cause #{raw}" }]
      else
        raise BytecodeVirtualMachineError, "BSharp VM context action does not support (#{name}."
      end
    end

    def deep_symbolize(value)
      case value
      when Hash then value.each_with_object({}) { |(key, entry), result| result[key.to_sym] = deep_symbolize(entry) }
      when Array then value.map { |entry| deep_symbolize(entry) }
      else value
      end
    end

    def ask_plural_kind(kind)
      return "#{kind[0...-1]}ies" if kind.end_with?('y') && kind.length > 1
      return "#{kind}es" if kind.end_with?('s', 'x', 'z', 'ch', 'sh')

      "#{kind}s"
    end

    def ask_action_text(instruction)
      operands = instruction.fetch(:operands)
      if instruction.fetch(:name) == 'CAUSE_EVENT'
        actor = ask_event_reference_text(selector_name(operands.fetch(0)), operands.fetch(1))
        action = third_person_action(string(operands.fetch(2)))
        target = ask_event_reference_text(selector_name(operands.fetch(3)), operands.fetch(4))
        return "(cause #{normalize([actor, action, target].reject(&:empty?).join(' '))}"
      end

      selector = selector_name(operands.fetch(0))
      target = case selector
               when 'EXACT_THING' then thing_name(operands.fetch(1))
               when 'BOUND_THAT_KIND' then "that #{kind_name(operands.fetch(1))}"
               when 'EVERY_KIND' then "every #{kind_name(operands.fetch(1))}"
               else 'unknown target'
               end
      case instruction.fetch(:name)
      when 'DAMAGE'
        amount = operands.fetch(2)
        amount == 1 ? "(damage #{target}" : "(damage #{target} by #{amount}"
      when 'CHANGE_STATE' then "(change #{target} to #{string(operands.fetch(2))}"
      when 'CHANGE_VALUE' then "(change #{string(operands.fetch(2))} of #{target} to #{operands.fetch(3)}"
      when 'CHANGE_TEXT_VALUE' then "(change #{string(operands.fetch(2))} of #{target} to #{quote_text(string(operands.fetch(3)))}"
      when 'INCREASE_VALUE' then "(increase #{string(operands.fetch(2))} of #{target} by #{operands.fetch(3)}"
      when 'DECREASE_VALUE' then "(decrease #{string(operands.fetch(2))} of #{target} by #{operands.fetch(3)}"
      when 'CARRY' then "(carry #{target}"
      when 'UNLOCK' then "(unlock #{target}"
      else "(#{canonical_action_name(instruction)} #{target}"
      end
    end

    def ask_event_reference_text(selector, reference)
      case selector
      when 'NO_REFERENCE' then ''
      when 'EXACT_THING' then thing_name(reference)
      when 'ONE_KIND' then "one #{kind_name(reference)}"
      when 'BOUND_THAT_KIND' then "that #{kind_name(reference)}"
      else 'unknown reference'
      end
    end

    def validate_world_save_state!(world, save_version:)
      unless world.is_a?(Hash)
        raise WorldSaveError, 'BSharp Save cannot load because its world entry is missing or invalid.'
      end
      unless world['settled'] == true
        raise WorldSaveError, 'BSharp Save cannot load because the saved world was not fully settled.'
      end

      entries = world['things']
      unless entries.is_a?(Array)
        raise WorldSaveError, 'BSharp Save cannot load because its Things entry is not a list.'
      end
      unless entries.length == @world.length
        raise WorldSaveError, "BSharp Save contains #{entries.length} Things, but this bytecode defines #{@world.length}."
      end

      expected_names = @world.map { |thing| thing.fetch(:name) }.to_set
      candidate_world = entries.each_with_index.map do |entry, index|
        unless entry.is_a?(Hash)
          raise WorldSaveError, "BSharp Save Thing #{index + 1} does not describe one Thing."
        end
        expected = @world.fetch(index)
        name = canonical_save_text(entry['name'], "Thing #{index + 1} name")
        unless name == expected.fetch(:name)
          raise WorldSaveError, "BSharp Save expected Thing #{index + 1} to be #{expected.fetch(:name)}, but found #{name}."
        end
        kind = canonical_save_text(entry['kind'], "#{name} Kind")
        expected_kind = kind_name(expected.fetch(:kind_index))
        unless kind == expected_kind
          raise WorldSaveError, "BSharp Save says #{name} is a #{kind}, but this bytecode defines #{name} as a #{expected_kind}."
        end
        builtin = entry['builtin']
        unless builtin == true || builtin == false
          raise WorldSaveError, "BSharp Save builtin flag for #{name} must be true or false."
        end
        unless builtin == expected.fetch(:builtin)
          raise WorldSaveError, "BSharp Save builtin identity for #{name} does not match this bytecode."
        end

        {
          index: index, name: name, kind_index: expected.fetch(:kind_index), builtin: builtin,
          states: validate_saved_states!(entry['states'], name),
          relations: validate_saved_relations!(entry['relations'], name, expected_names),
          values: validate_saved_values!(entry['values'], name, expected.fetch(:values), save_version: save_version)
        }
      end

      rules = world['if_rules']
      unless rules.is_a?(Array)
        raise WorldSaveError, 'BSharp Save cannot load because its IF-rule entry is not a list.'
      end
      unless rules.length == @program.fetch(:if_rules).length
        raise WorldSaveError, "BSharp Save contains #{rules.length} IF-rule records, but this bytecode defines #{@program.fetch(:if_rules).length}."
      end
      previous_world = @world
      @world = candidate_world
      candidate_if_active = rules.each_with_index.map do |entry, index|
        unless entry.is_a?(Hash) && entry['index'] == index
          raise WorldSaveError, "BSharp Save IF-rule record #{index + 1} has the wrong index."
        end
        expected_condition = canonical_condition(@program.fetch(:if_rules).fetch(index).fetch(:condition))
        condition = canonical_saved_condition(entry['condition'], "IF-rule #{index + 1} condition")
        unless condition == expected_condition
          raise WorldSaveError, "BSharp Save IF-rule #{index + 1} does not match '#{expected_condition}'."
        end
        active = entry['active']
        unless active == true || active == false
          raise WorldSaveError, "BSharp Save IF-rule #{index + 1} active flag must be true or false."
        end
        truth = condition_true?(@program.fetch(:if_rules).fetch(index).fetch(:condition))
        unless active == truth
          raise WorldSaveError, "BSharp Save IF-rule '#{expected_condition}' does not match the restored world."
        end
        active
      end
      [candidate_world, candidate_if_active]
    ensure
      @world = previous_world if defined?(previous_world) && previous_world
    end

    def validate_saved_states!(entries, thing_name)
      unless entries.is_a?(Array)
        raise WorldSaveError, "BSharp Save states for #{thing_name} must be a list."
      end
      states = entries.map { |state| canonical_save_text(state, "#{thing_name} state") }
      if states.uniq.length != states.length
        raise WorldSaveError, "BSharp Save lists the same state more than once for #{thing_name}."
      end
      states.each do |state|
        opposite = OPPOSITE_STATES[state]
        if opposite && states.include?(opposite)
          raise WorldSaveError, "BSharp Save gives #{thing_name} contradictory states: #{state} and #{opposite}."
        end
      end
      Set.new(states)
    end

    def validate_saved_relations!(entries, thing_name, expected_names)
      unless entries.is_a?(Hash)
        raise WorldSaveError, "BSharp Save relationships for #{thing_name} must be an object."
      end
      entries.each_with_object({}) do |(relation_value, target_value), result|
        relation = canonical_save_text(relation_value, "#{thing_name} relationship")
        target = canonical_save_text(target_value, "#{thing_name} #{relation} target")
        unless expected_names.include?(target)
          raise WorldSaveError, "BSharp Save relationship '#{relation}' for #{thing_name} points to missing Thing '#{target}'."
        end
        result[relation] = target
      end
    end

    def validate_saved_values!(entries, thing_name, expected_values, save_version:)
      unless entries.is_a?(Hash)
        raise WorldSaveError, "BSharp Save values for #{thing_name} must be an object."
      end
      normalized_keys = entries.keys.map { |name| canonical_save_text(name, "#{thing_name} value name") }
      unless normalized_keys.sort == expected_values.keys.sort
        raise WorldSaveError, "BSharp Save value names for #{thing_name} do not match this bytecode."
      end
      entries.each_with_object({}) do |(name_value, saved_value), result|
        name = canonical_save_text(name_value, "#{thing_name} value name")
        unless VALUE_NAME_PATTERN.match?(name)
          raise WorldSaveError, "BSharp Save value name '#{name}' for #{thing_name} must be one plain word."
        end
        expected_type = expected_values.fetch(name).is_a?(String) ? 'text' : 'whole_number'
        value = if [WorldSave::FORMAT_VERSION_2, WorldSave::FORMAT_VERSION_3, WorldSave::FORMAT_VERSION_4, WorldSave::FORMAT_VERSION_5, WorldSave::FORMAT_VERSION_6].include?(save_version)
                  validate_typed_saved_value!(saved_value, name, thing_name, expected_type)
                else
                  saved_value
                end
        if expected_type == 'whole_number'
          unless value.is_a?(Integer) && value.between?(0, MAX_WHOLE_NUMBER)
            raise WorldSaveError, "BSharp Save value #{name} for #{thing_name} must be a whole number from 0 to #{MAX_WHOLE_NUMBER}."
          end
        else
          begin
            TextLiteral.new(value)
          rescue TextLiteralError => error
            raise WorldSaveError, "BSharp Save value #{name} for #{thing_name} is invalid text: #{error.message}"
          end
        end
        result[name] = value
      end
    end

    def validate_typed_saved_value!(entry, value_name, thing_name, expected_type)
      unless entry.is_a?(Hash) && entry.keys.sort == %w[type value]
        raise WorldSaveError, "BSharp Save value #{value_name} for #{thing_name} must contain exactly type and value."
      end
      unless entry['type'] == expected_type
        raise WorldSaveError, "BSharp Save value #{value_name} for #{thing_name} has the wrong value type."
      end
      entry['value']
    end

    def canonical_save_text(value, label)
      unless value.is_a?(String)
        raise WorldSaveError, "BSharp Save #{label} must be text."
      end
      normalized = normalize(value)
      raise WorldSaveError, "BSharp Save #{label} cannot be empty." if normalized.empty?
      unless value == normalized
        raise WorldSaveError, "BSharp Save #{label} must use its canonical lowercase spelling."
      end
      normalized
    end

    def canonical_saved_condition(value, label)
      return canonical_save_text(value, label) if meaning_profile == WorldSave::MEANING_PROFILE_1
      raise WorldSaveError, "BSharp Save #{label} must be text." unless value.is_a?(String)
      raise WorldSaveError, "BSharp Save #{label} cannot be empty." if value.empty?
      value
    end

    def validate_profile!
      pair = [@program.fetch(:profile), @program.fetch(:meaning_profile)]
      supported = [
        [BytecodeContract::PROFILE, BytecodeContract::MEANING_PROFILE],
        [BytecodeContract::PROFILE_2, BytecodeContract::MEANING_PROFILE_2],
        [BytecodeContract::PROFILE_3, BytecodeContract::MEANING_PROFILE_3],
        [BytecodeContract::PROFILE_4, BytecodeContract::MEANING_PROFILE_4],
        [BytecodeContract::PROFILE_5, BytecodeContract::MEANING_PROFILE_5],
        [BytecodeContract::PROFILE_6, BytecodeContract::MEANING_PROFILE_6]
      ]
      unless supported.include?(pair)
        raise BytecodeVirtualMachineError, 'The BSharp Virtual Machine cannot execute this bytecode profile.'
      end
    end

    def build_indexes
      @strings = @program.fetch(:strings)
      @kinds = @program.fetch(:kinds)
      @things = @program.fetch(:things)
      @blocks = @program.fetch(:blocks).to_h { |entry| [entry.fetch(:id), entry] }
      @kind_distances = @kinds.each_index.map do |index|
        distances = {}
        current = index
        distance = 0
        while current != BytecodeContract::NO_REFERENCE_U32
          distances[current] = distance
          current = @kinds.fetch(current).fetch(:parent_index)
          distance += 1
        end
        distances.freeze
      end.freeze
      @thing_indexes_by_name = @things.each_with_index.to_h { |thing, index| [thing.fetch(:name), index] }.freeze
    end

    def create_world
      @world = @things.each_with_index.map do |thing, index|
        name = thing.fetch(:name)
        {
          index: index,
          name: name,
          kind_index: thing.fetch(:kind_index),
          builtin: name == 'player' && kind_name(thing.fetch(:kind_index)) == 'person',
          states: Set.new,
          relations: {},
          values: { 'damage' => 0 }
        }
      end
    end

    def execute_start_records
      @program.fetch(:start_records).each do |record|
        operands = record.fetch(:operands)
        case record.fetch(:name)
        when 'START_STATE'
          set_state(world_thing(operands.fetch(0)), string(operands.fetch(1)), optional_string(operands.fetch(2)))
        when 'START_RELATION'
          world_thing(operands.fetch(0)).fetch(:relations)[string(operands.fetch(1))] = thing_name(operands.fetch(2))
        when 'START_VALUE'
          world_thing(operands.fetch(0)).fetch(:values)[string(operands.fetch(1))] = operands.fetch(2)
        when 'START_TEXT_VALUE'
          world_thing(operands.fetch(0)).fetch(:values)[string(operands.fetch(1))] = string(operands.fetch(2))
        else
          raise BytecodeVirtualMachineError, "The BSharp Virtual Machine cannot execute START instruction #{record.fetch(:name)}."
        end
      end
    end

    def process_event(event_text, caused_by: nil)
      match = find_event_match(event_text)
      unless match[:event]
        outcome = result(event_text, false, [], {}, match[:error], caused_by: caused_by)
        outcome['_follow_ups'] = []
        outcome['_fatal_error'] = nil
        return outcome
      end

      event = match.fetch(:event)
      context = match.fetch(:context)
      actor_index = resolved_event_reference(event.fetch(:actor_selector), event.fetch(:actor_reference), context)
      selections = []
      action_result = execute_block(event.fetch(:block_index), actor_index: actor_index, context: context, selections: selections)
      if_settlement = if action_result['error']
                        { 'rules' => [], 'error' => nil, 'follow_ups' => [] }
                      else
                        settle_if_rules(cause: 'event')
                      end
      fatal_error = action_result['error'] || if_settlement['error']
      if if_settlement['error'] && action_result['error'].nil?
        discard_follow_up_steps!(action_result.fetch('steps'), 'IF rules did not finish, so this event will not happen.')
      end
      follow_ups = fatal_error ? [] : action_result.fetch('follow_ups') + if_settlement.fetch('follow_ups')

      outcome = result(
        event_text,
        true,
        action_result.fetch('steps').map { |step| step.fetch('word') },
        context_names(context),
        fatal_error,
        matched_when: canonical_event_pattern(event),
        understood: context_explanations(event, context),
        steps: action_result.fetch('steps'),
        selections: selections,
        if_rules: if_settlement.fetch('rules'),
        caused_by: caused_by
      )
      outcome['_follow_ups'] = follow_ups
      outcome['_fatal_error'] = fatal_error
      outcome
    end

    def find_event_match(event_text)
      exact = @program.fetch(:events).find do |event|
        event.fetch(:actor_selector) == 'EXACT_THING' &&
          %w[EXACT_THING NO_REFERENCE].include?(event.fetch(:target_selector)) &&
          event_text == canonical_concrete_event(event)
      end
      return { event: exact, context: {}, error: nil } if exact

      best = nil
      best_distance = nil
      best_error = nil
      @program.fetch(:events).each do |event|
        parsed = parse_event_text(event_text, event.fetch(:action))
        next unless parsed

        actor = match_event_reference(event.fetch(:actor_selector), event.fetch(:actor_reference), parsed.fetch(:actor))
        unless actor[:matched]
          best_error ||= actor[:error] if event.fetch(:actor_selector) == 'ONE_KIND'
          next
        end
        target = match_event_reference(event.fetch(:target_selector), event.fetch(:target_reference), parsed.fetch(:target))
        unless target[:matched]
          best_error ||= target[:error]
          next
        end

        context = {}
        bind_context(context, actor)
        bind_context(context, target)
        distance = actor.fetch(:distance, 0) + target.fetch(:distance, 0)
        if best.nil? || distance < best_distance
          best = { event: event, context: context, error: nil }
          best_distance = distance
        end
      end
      best || { event: nil, context: {}, error: best_error }
    end

    def match_event_reference(selector, reference, supplied)
      supplied = normalize(supplied)
      case selector
      when 'NO_REFERENCE'
        { matched: supplied.empty?, distance: 0 }
      when 'EXACT_THING'
        { matched: supplied == thing_name(reference), distance: 0, thing_index: reference }
      when 'ONE_KIND'
        thing_index = @thing_indexes_by_name[supplied]
        unless thing_index
          return { matched: false, error: "event Thing '#{supplied}' is not defined", kind_index: reference }
        end
        actual_kind = @things.fetch(thing_index).fetch(:kind_index)
        distance = kind_distance(actual_kind, reference)
        unless distance
          return {
            matched: false,
            error: "#{supplied} is a #{kind_name(actual_kind)}, not a #{kind_name(reference)}",
            kind_index: reference,
            thing_index: thing_index
          }
        end
        { matched: true, distance: distance, kind_index: reference, thing_index: thing_index }
      else
        { matched: false, error: "event selector #{selector} is not executable" }
      end
    end

    def bind_context(context, match)
      context[match[:kind_index]] = match[:thing_index] if match[:kind_index] && match[:thing_index]
    end

    def parse_event_text(event_text, expected_action)
      words = normalize(event_text).split
      action_index = words.each_index.find do |index|
        index.positive? && normalize_event_word(words[index]) == normalize(expected_action)
      end
      return nil unless action_index

      {
        actor: words[0...action_index].join(' '),
        target: words[(action_index + 1)..]&.join(' ').to_s
      }
    end

    def normalize_event_word(word)
      normalized = normalize(word)
      return normalized[0...-3] + 'y' if normalized.end_with?('ies')
      if normalized.end_with?('es') && normalized[0...-2].end_with?('s', 'x', 'z', 'ch', 'sh')
        return normalized[0...-2]
      end
      normalized.sub(/s\z/, '')
    end

    def execute_block(block_index, actor_index:, context:, selections: [])
      block = @blocks.fetch(block_index)
      steps = []
      follow_ups = []
      error = nil

      block.fetch(:instructions).each do |instruction|
        if instruction.fetch(:name) == 'CAUSE_EVENT'
          event_text = materialize_caused_event(instruction, context)
          caused_by = "(cause #{event_text}"
          steps << {
            'word' => caused_by,
            'change' => "#{event_text} will happen next",
            'caused_event' => event_text,
            '_staged_follow_up' => true
          }
          follow_ups << { 'event' => event_text, 'caused_by' => caused_by }
          next
        end

        selection = action_selection(instruction, context)
        selections << selection.reject { |key, _| key == :thing_indexes } if selection[:set]
        targets = selection.fetch(:thing_indexes)

        if targets.empty? && selection[:set]
          steps << {
            'word' => display_action_for_selection(instruction, selection.fetch(:text)),
            'notice_lines' => [
              "#{selection.fetch(:text)} found no Things",
              "(#{canonical_action_name(instruction)} had nothing to act on"
            ],
            'targets' => []
          }
          next
        end

        preflight_error = preflight_action(instruction, targets)
        if preflight_error
          steps << {
            'word' => display_action_for_selection(instruction, selection.fetch(:text)),
            'notice_lines' => [preflight_error, 'Nothing in this action line was changed.'],
            'targets' => targets.map { |index| thing_name(index) }
          }
          error = preflight_error
          break
        end

        targets.each do |target_index|
          steps << execute_instruction(instruction, target_index: target_index, actor_index: actor_index)
        end
      rescue BytecodeVirtualMachineError, KeyError => runtime_error
        steps << {
          'word' => display_action_for_selection(instruction, selection ? selection.fetch(:text) : 'unknown target'),
          'notice_lines' => [runtime_error.message]
        }
        error = runtime_error.message
        break
      end

      if error && !follow_ups.empty?
        steps.each do |step|
          next unless step.delete('_staged_follow_up')

          event_text = step.fetch('caused_event')
          step.delete('change')
          step['notice_lines'] = ["#{event_text} will not happen because this action body did not finish."]
        end
        follow_ups = []
      else
        steps.each { |step| step.delete('_staged_follow_up') }
      end

      { 'steps' => steps, 'error' => error, 'follow_ups' => follow_ups }
    end

    def action_selection(instruction, context)
      selector = selector_name(instruction.fetch(:operands).fetch(0))
      reference = instruction.fetch(:operands).fetch(1)
      case selector
      when 'EXACT_THING'
        indexes = [reference]
        { set: false, text: thing_name(reference), targets: indexes.map { |i| thing_name(i) }, count: 1, thing_indexes: indexes }
      when 'BOUND_THAT_KIND'
        index = context[reference]
        indexes = index.nil? ? [] : [index]
        { set: false, text: "that #{kind_name(reference)}", targets: indexes.map { |i| thing_name(i) }, count: indexes.length, thing_indexes: indexes }
      when 'EVERY_KIND'
        indexes = @world.each_index.select do |index|
          !kind_distance(@things.fetch(index).fetch(:kind_index), reference).nil?
        end
        { set: true, text: "every #{kind_name(reference)}", kind_name: kind_name(reference), targets: indexes.map { |i| thing_name(i) }, count: indexes.length, thing_indexes: indexes }
      else
        raise BytecodeVirtualMachineError, "Action selector #{selector} cannot select a Thing."
      end
    end

    def preflight_action(instruction, targets)
      operands = instruction.fetch(:operands)
      case instruction.fetch(:name)
      when 'DAMAGE'
        amount = operands.fetch(2)
        overflowing = targets.find do |index|
          world_thing(index).fetch(:values).fetch('damage', 0) > MAX_WHOLE_NUMBER - amount
        end
        "#{thing_name(overflowing)} damage would be greater than #{MAX_WHOLE_NUMBER}" if overflowing
      when 'CHANGE_VALUE'
        value_name = string(operands.fetch(2))
        missing = targets.find { |index| !world_thing(index).fetch(:values).key?(value_name) }
        return "#{thing_name(missing)} does not have a value named #{value_name}." if missing
        wrong_type = targets.find { |index| !world_thing(index).fetch(:values).fetch(value_name).is_a?(Integer) }
        "#{thing_name(wrong_type)} value #{value_name} is not a whole number." if wrong_type
      when 'INCREASE_VALUE', 'DECREASE_VALUE'
        value_name = string(operands.fetch(2))
        missing = targets.find { |index| !world_thing(index).fetch(:values).key?(value_name) }
        return "#{thing_name(missing)} does not have a value named #{value_name}." if missing
        wrong_type = targets.find { |index| !world_thing(index).fetch(:values).fetch(value_name).is_a?(Integer) }
        return "#{thing_name(wrong_type)} value #{value_name} is not a whole number." if wrong_type
        amount = operands.fetch(3)
        if instruction.fetch(:name) == 'INCREASE_VALUE'
          overflowing = targets.find { |index| world_thing(index).fetch(:values).fetch(value_name) > MAX_WHOLE_NUMBER - amount }
          return "#{thing_name(overflowing)} #{value_name} would be greater than #{MAX_WHOLE_NUMBER}." if overflowing
        else
          underflowing = targets.find { |index| world_thing(index).fetch(:values).fetch(value_name) < amount }
          return "#{thing_name(underflowing)} #{value_name} would be less than 0." if underflowing
        end
      when 'CHANGE_TEXT_VALUE'
        value_name = string(operands.fetch(2))
        missing = targets.find { |index| !world_thing(index).fetch(:values).key?(value_name) }
        return "#{thing_name(missing)} does not have a value named #{value_name}." if missing
        wrong_type = targets.find { |index| !world_thing(index).fetch(:values).fetch(value_name).is_a?(String) }
        "#{thing_name(wrong_type)} value #{value_name} is not text." if wrong_type
      end
    end

    def execute_instruction(instruction, target_index:, actor_index:)
      target = world_thing(target_index)
      target_name = target.fetch(:name)
      operands = instruction.fetch(:operands)
      case instruction.fetch(:name)
      when 'DAMAGE'
        amount = operands.fetch(2)
        old_amount = target.fetch(:values).fetch('damage', 0)
        new_amount = old_amount + amount
        target.fetch(:values)['damage'] = new_amount
        step = {
          'word' => amount == 1 ? "(damage #{target_name}" : "(damage #{target_name} by #{amount}",
          'change' => amount == 1 ? "#{target_name} damage is now #{new_amount}" : "#{target_name} damage changed from #{old_amount} to #{new_amount}"
        }
        if amount != 1
          step['value_change'] = {
            'value_name' => 'damage', 'old_amount' => old_amount,
            'new_amount' => new_amount, 'action_amount' => amount
          }
        end
        step
      when 'CHANGE_STATE'
        state = string(operands.fetch(2))
        opposite = optional_string(operands.fetch(3))
        set_state(target, state, opposite)
        { 'word' => "(change #{target_name} to #{state}", 'change' => "#{target_name} is now #{state}" }
      when 'CHANGE_VALUE'
        value_name = string(operands.fetch(2))
        old_amount = target.fetch(:values).fetch(value_name)
        new_amount = operands.fetch(3)
        target.fetch(:values)[value_name] = new_amount
        {
          'word' => "(change #{value_name} of #{target_name} to #{new_amount}",
          'change' => "#{target_name} #{value_name} changed from #{old_amount} to #{new_amount}",
          'value_change' => { 'value_name' => value_name, 'old_amount' => old_amount, 'new_amount' => new_amount }
        }
      when 'CHANGE_TEXT_VALUE'
        value_name = string(operands.fetch(2))
        old_text = target.fetch(:values).fetch(value_name)
        new_text = string(operands.fetch(3))
        target.fetch(:values)[value_name] = new_text
        {
          'word' => "(change #{value_name} of #{target_name} to #{quote_text(new_text)}",
          'change' => "#{target_name} #{value_name} changed from #{quote_text(old_text)} to #{quote_text(new_text)}",
          'value_change' => { 'value_name' => value_name, 'old_text' => old_text, 'new_text' => new_text }
        }
      when 'INCREASE_VALUE', 'DECREASE_VALUE'
        value_name = string(operands.fetch(2))
        old_amount = target.fetch(:values).fetch(value_name)
        action_amount = operands.fetch(3)
        operation = instruction.fetch(:name) == 'INCREASE_VALUE' ? 'increase' : 'decrease'
        new_amount = operation == 'increase' ? old_amount + action_amount : old_amount - action_amount
        target.fetch(:values)[value_name] = new_amount
        {
          'word' => "(#{operation} #{value_name} of #{target_name} by #{action_amount}",
          'change' => "#{target_name} #{value_name} changed from #{old_amount} to #{new_amount}",
          'value_change' => {
            'value_name' => value_name, 'old_amount' => old_amount,
            'new_amount' => new_amount, 'action_amount' => action_amount,
            'operation' => operation
          }
        }
      when 'CARRY'
        carrier = actor_index.nil? ? 'player' : thing_name(actor_index)
        target.fetch(:relations).delete('on')
        target.fetch(:relations).delete('in')
        target.fetch(:relations)['carried by'] = carrier
        { 'word' => "(carry #{target_name}", 'change' => "#{target_name} is now carried by #{carrier}" }
      when 'UNLOCK'
        set_state(target, 'unlocked', 'locked')
        { 'word' => "(unlock #{target_name}", 'change' => "#{target_name} is now unlocked" }
      else
        raise BytecodeVirtualMachineError, "The BSharp Virtual Machine cannot execute #{instruction.fetch(:name)}."
      end
    end

    def materialize_caused_event(instruction, context)
      operands = instruction.fetch(:operands)
      actor = materialize_event_reference(selector_name(operands.fetch(0)), operands.fetch(1), context)
      action = third_person_action(string(operands.fetch(2)))
      target_selector = selector_name(operands.fetch(3))
      target = materialize_event_reference(target_selector, operands.fetch(4), context)
      normalize([actor, action, target].reject(&:empty?).join(' '))
    end

    def materialize_event_reference(selector, reference, context)
      case selector
      when 'NO_REFERENCE' then ''
      when 'EXACT_THING' then thing_name(reference)
      when 'BOUND_THAT_KIND'
        index = context[reference]
        raise BytecodeVirtualMachineError, "BASIC# could not resolve 'that #{kind_name(reference)}' for this caused event." if index.nil?
        thing_name(index)
      when 'ONE_KIND' then "one #{kind_name(reference)}"
      else
        raise BytecodeVirtualMachineError, "Caused-event selector #{selector} is not executable."
      end
    end

    def settle_if_rules(cause:)
      rules = @program.fetch(:if_rules)
      return { 'rules' => [], 'error' => nil, 'follow_ups' => [] } if rules.empty?

      fired = []
      follow_ups = []
      fired_indexes = Set.new
      initially_true = rules.map { |rule| condition_true?(rule.fetch(:condition)) }
      seen = nil
      firing_limit = [256, rules.length * 8].max
      condition_trail = []

      loop do
        fired_this_pass = false
        rules.each_with_index do |rule, index|
          current = condition_true?(rule.fetch(:condition))
          unless current
            @if_active[index] = false
            next
          end
          next if @if_active[index]

          if fired.length >= firing_limit
            error = if_loop_error(condition_trail)
            discard_if_follow_up_steps!(fired, 'IF rules did not finish, so this event will not happen.')
            return { 'rules' => fired, 'error' => error, 'follow_ups' => [] }
          end

          seen ||= { if_world_signature => true }
          @if_active[index] = true
          selections = []
          action_result = execute_block(rule.fetch(:block_index), actor_index: nil, context: {}, selections: selections)
          condition = canonical_condition(rule.fetch(:condition))
          reason = if initially_true[index] && !fired_indexes.include?(index)
                     cause == 'START' ? 'was true after START' : 'became true after the event'
                   else
                     'became true'
                   end
          fired << {
            'condition' => condition,
            'reason' => reason,
            'steps' => action_result.fetch('steps'),
            'selections' => selections
          }
          follow_ups.concat(action_result.fetch('follow_ups'))
          fired_indexes.add(index)
          condition_trail << condition
          condition_trail.shift while condition_trail.length > 3
          fired_this_pass = true

          if action_result['error']
            discard_if_follow_up_steps!(fired, 'IF rules did not finish, so this event will not happen.')
            return { 'rules' => fired, 'error' => action_result['error'], 'follow_ups' => [] }
          end

          rearm_false_if_rules!
          signature = if_world_signature
          if seen.key?(signature)
            error = if_loop_error(condition_trail)
            discard_if_follow_up_steps!(fired, 'IF rules did not finish, so this event will not happen.')
            return { 'rules' => fired, 'error' => error, 'follow_ups' => [] }
          end
          seen[signature] = true
        end
        break unless fired_this_pass
      end

      { 'rules' => fired, 'error' => nil, 'follow_ups' => follow_ups }
    end

    def condition_true?(condition)
      if %w[ALL_CONDITIONS ANY_CONDITIONS].include?(condition.fetch(:name))
        truths = Array(condition[:clauses]).map { |clause| condition_true?(clause) }
        return condition.fetch(:name) == 'ALL_CONDITIONS' ? truths.all? : truths.any?
      end
      operands = condition.fetch(:operands)
      subject = world_thing(operands.fetch(0))
      case condition.fetch(:name)
      when 'STATE_IS'
        subject.fetch(:states).include?(string(operands.fetch(1)))
      when 'STATE_ISNT'
        !subject.fetch(:states).include?(string(operands.fetch(1)))
      when 'RELATION_EXISTS'
        subject.fetch(:relations)[string(operands.fetch(1))] == thing_name(operands.fetch(2))
      when 'VALUE_EQUALS'
        subject.fetch(:values)[string(operands.fetch(1))] == operands.fetch(2)
      when 'VALUE_AT_LEAST'
        value = subject.fetch(:values)[string(operands.fetch(1))]
        !value.nil? && value >= operands.fetch(2)
      when 'VALUE_MORE_THAN'
        value = subject.fetch(:values)[string(operands.fetch(1))]
        !value.nil? && value > operands.fetch(2)
      when 'VALUE_AT_MOST'
        value = subject.fetch(:values)[string(operands.fetch(1))]
        !value.nil? && value <= operands.fetch(2)
      when 'VALUE_LESS_THAN'
        value = subject.fetch(:values)[string(operands.fetch(1))]
        !value.nil? && value < operands.fetch(2)
      when 'TEXT_VALUE_EQUALS'
        subject.fetch(:values)[string(operands.fetch(1))] == string(operands.fetch(2))
      else
        false
      end
    end

    def drain_follow_up_events(initial_events)
      queue = initial_events.map(&:dup)
      events = []
      trail = []
      error = nil
      until queue.empty?
        if events.length >= MAX_FOLLOW_UP_EVENTS
          error = EVENT_CHAIN_LIMIT_MESSAGE
          break
        end
        pending = queue.shift
        event_text = normalize(pending.fetch('event'))
        outcome = process_event(event_text, caused_by: pending['caused_by'])
        produced = outcome.delete('_follow_ups') || []
        fatal_error = outcome.delete('_fatal_error')
        events << outcome
        trail << event_text
        trail.shift while trail.length > 3
        if fatal_error
          error = fatal_error
          break
        end
        queue.concat(produced)
      end
      { 'events' => events, 'error' => error, 'trail' => trail }
    end

    def rearm_false_if_rules!
      @program.fetch(:if_rules).each_with_index do |rule, index|
        @if_active[index] = false unless condition_true?(rule.fetch(:condition))
      end
    end

    def if_world_signature
      JSON.generate([snapshot, @if_active])
    end

    def if_loop_error(condition_trail)
      shown = condition_trail.empty? ? ['IF conditions repeated'] : condition_trail
      "IF rules kept waking each other.\n\n#{shown.join("\n")}\n\nBASIC# stopped this chain so it would not run forever."
    end

    def discard_if_follow_up_steps!(rules, message)
      rules.each { |entry| discard_follow_up_steps!(entry.fetch('steps'), message) }
    end

    def discard_follow_up_steps!(steps, message)
      steps.each do |step|
        next unless step['caused_event'] && step['change']
        step.delete('change')
        step['notice_lines'] = [message]
      end
    end

    def set_state(thing, state, opposite = nil)
      thing.fetch(:states).delete(opposite) if opposite
      thing.fetch(:states).add(state)
    end

    def canonical_condition(condition)
      if %w[ALL_CONDITIONS ANY_CONDITIONS].include?(condition.fetch(:name))
        connector = condition.fetch(:name) == 'ALL_CONDITIONS' ? 'and' : 'or'
        return Array(condition[:clauses]).map { |clause| canonical_condition(clause) }.join(" #{connector} ")
      end
      operands = condition.fetch(:operands)
      subject = thing_name(operands.fetch(0))
      case condition.fetch(:name)
      when 'STATE_IS' then "#{subject} is #{string(operands.fetch(1))}"
      when 'STATE_ISNT' then "#{subject} isnt #{string(operands.fetch(1))}"
      when 'RELATION_EXISTS' then "#{subject} is #{string(operands.fetch(1))} #{thing_name(operands.fetch(2))}"
      when 'VALUE_EQUALS' then "#{subject} has #{operands.fetch(2)} #{string(operands.fetch(1))}"
      when 'VALUE_AT_LEAST' then "#{subject} has at least #{operands.fetch(2)} #{string(operands.fetch(1))}"
      when 'VALUE_MORE_THAN' then "#{subject} has more than #{operands.fetch(2)} #{string(operands.fetch(1))}"
      when 'VALUE_AT_MOST' then "#{subject} has at most #{operands.fetch(2)} #{string(operands.fetch(1))}"
      when 'VALUE_LESS_THAN' then "#{subject} has less than #{operands.fetch(2)} #{string(operands.fetch(1))}"
      when 'TEXT_VALUE_EQUALS' then "#{subject} has #{quote_text(string(operands.fetch(2)))} #{string(operands.fetch(1))}"
      end
    end

    def canonical_event_pattern(event)
      actor = event_reference_text(event.fetch(:actor_selector), event.fetch(:actor_reference), article: true)
      target = event_reference_text(event.fetch(:target_selector), event.fetch(:target_reference), article: true)
      normalize([actor, third_person_action(event.fetch(:action)), target].reject(&:empty?).join(' '))
    end

    def canonical_concrete_event(event)
      actor = event_reference_text(event.fetch(:actor_selector), event.fetch(:actor_reference), article: false)
      target = event_reference_text(event.fetch(:target_selector), event.fetch(:target_reference), article: false)
      normalize([actor, third_person_action(event.fetch(:action)), target].reject(&:empty?).join(' '))
    end

    def event_reference_text(selector, reference, article:)
      case selector
      when 'NO_REFERENCE' then ''
      when 'EXACT_THING' then thing_name(reference)
      when 'ONE_KIND' then article ? "a #{kind_name(reference)}" : kind_name(reference)
      else ''
      end
    end

    def third_person_action(action)
      normalized = normalize(action)
      return normalized[0...-1] + 'ies' if normalized.end_with?('y') && normalized.length > 1
      return "#{normalized}es" if normalized.end_with?('s', 'x', 'z', 'ch', 'sh')
      "#{normalized}s"
    end

    def context_names(context)
      context.to_h { |kind_index, thing_index| [kind_name(kind_index), thing_name(thing_index)] }
    end

    def context_explanations(event, context)
      explanations = []
      [[event.fetch(:actor_selector), event.fetch(:actor_reference)],
       [event.fetch(:target_selector), event.fetch(:target_reference)]].each do |selector, reference|
        next unless selector == 'ONE_KIND' && context.key?(reference)
        explanations << "a #{kind_name(reference)} means #{thing_name(context.fetch(reference))}"
      end
      @blocks.fetch(event.fetch(:block_index)).fetch(:instructions).each do |instruction|
        refs = if instruction.fetch(:name) == 'CAUSE_EVENT'
                 [[selector_name(instruction.fetch(:operands).fetch(0)), instruction.fetch(:operands).fetch(1)],
                  [selector_name(instruction.fetch(:operands).fetch(3)), instruction.fetch(:operands).fetch(4)]]
               else
                 [[selector_name(instruction.fetch(:operands).fetch(0)), instruction.fetch(:operands).fetch(1)]]
               end
        refs.each do |selector, reference|
          next unless selector == 'BOUND_THAT_KIND' && context.key?(reference)
          explanations << "that #{kind_name(reference)} means #{thing_name(context.fetch(reference))}"
        end
      end
      explanations.uniq
    end

    def resolved_event_reference(selector, reference, context)
      case selector
      when 'EXACT_THING' then reference
      when 'ONE_KIND' then context[reference]
      else nil
      end
    end

    def result(event_text, matched, ran, context, error, matched_when: nil, understood: [], steps: [], selections: [], if_rules: [], caused_by: nil)
      outcome = {
        'event' => event_text,
        'matched' => matched,
        'matched_when' => matched_when,
        'understood' => understood,
        'ran' => ran,
        'steps' => steps,
        'selections' => selections.map { |entry| stringify_symbol_hash(entry) },
        'if_rules' => if_rules,
        'context' => context,
        'error' => error
      }
      outcome['caused_by'] = caused_by if caused_by
      outcome
    end

    def display_action_for_selection(instruction, text)
      operands = instruction.fetch(:operands)
      case instruction.fetch(:name)
      when 'DAMAGE'
        amount = operands.fetch(2)
        amount == 1 ? "(damage #{text}" : "(damage #{text} by #{amount}"
      when 'CHANGE_VALUE'
        "(change #{string(operands.fetch(2))} of #{text} to #{operands.fetch(3)}"
      when 'INCREASE_VALUE'
        "(increase #{string(operands.fetch(2))} of #{text} by #{operands.fetch(3)}"
      when 'DECREASE_VALUE'
        "(decrease #{string(operands.fetch(2))} of #{text} by #{operands.fetch(3)}"
      when 'CHANGE_TEXT_VALUE'
        "(change #{string(operands.fetch(2))} of #{text} to #{quote_text(string(operands.fetch(3)))}"
      when 'CHANGE_STATE'
        "(change #{text} to #{string(operands.fetch(2))}"
      when 'CARRY' then "(carry #{text}"
      when 'UNLOCK' then "(unlock #{text}"
      else "(#{canonical_action_name(instruction)} #{text}"
      end
    end

    def canonical_action_name(instruction)
      {
        'DAMAGE' => 'damage', 'CHANGE_STATE' => 'change', 'CHANGE_VALUE' => 'change', 'CHANGE_TEXT_VALUE' => 'change',
        'INCREASE_VALUE' => 'increase', 'DECREASE_VALUE' => 'decrease',
        'CARRY' => 'carry', 'UNLOCK' => 'unlock', 'CAUSE_EVENT' => 'cause'
      }.fetch(instruction.fetch(:name), instruction.fetch(:name).downcase)
    end

    def selector_name(code)
      @selector_names ||= BytecodeContract::SELECTORS.invert.freeze
      @selector_names.fetch(code)
    end

    def kind_distance(actual_kind_index, expected_kind_index)
      @kind_distances.fetch(actual_kind_index)[expected_kind_index]
    end

    def kind_name(index)
      @kinds.fetch(index).fetch(:name)
    end

    def thing_name(index)
      @things.fetch(index).fetch(:name)
    end

    def world_thing(index)
      @world.fetch(index)
    end

    def string(index)
      @strings.fetch(index)
    end

    def optional_string(index)
      index == BytecodeContract::NO_REFERENCE_U32 ? nil : string(index)
    end

    def normalize(value)
      value.to_s.strip.downcase.gsub(/\s+/, ' ')
    end

    def quote_text(value)
      %Q{"#{value}"}
    end

    def typed_save_values(values)
      values.to_h do |name, value|
        type = value.is_a?(String) ? 'text' : 'whole_number'
        [name, { 'type' => type, 'value' => value }]
      end
    end

    def stringify_symbol_hash(hash)
      hash.each_with_object({}) { |(key, value), out| out[key.to_s] = value }
    end

    def stringify_keys(value)
      case value
      when Hash
        value.each_with_object({}) { |(key, item), out| out[key.to_s] = stringify_keys(item) }
      when Array
        value.map { |item| stringify_keys(item) }
      else
        value
      end
    end

    def append_follow_up_report(lines, entries)
      entries.each_with_index do |entry, index|
        lines << "  event #{index + 1}: #{entry.fetch('event')}"
        lines << "  matched: #{entry.fetch('matched') ? 'yes' : 'no'}"
        lines << "  error: #{entry.fetch('error')}" if entry['error']
      end
    end

    def append_if_rule_report(lines, entries)
      entries.each do |entry|
        lines << "  #{entry.fetch('condition')} #{entry.fetch('reason')}"
        lines << '  ran:'
        append_steps_report(lines, entry.fetch('steps'), indent: '    ')
      end
    end

    def append_selection_report(lines, selections, indent:)
      selections.each do |selection|
        targets = selection.fetch('targets')
        if selection.fetch('count').zero?
          lines << "#{indent}#{selection.fetch('text')} found no Things"
        else
          lines << "#{indent}#{selection.fetch('text')} means #{targets.join(', ')}"
        end
      end
    end

    def append_steps_report(lines, steps, indent:)
      steps.each do |step|
        lines << "#{indent}#{step.fetch('word')}"
        lines << "#{indent}#{step.fetch('change')}" if step['change']
        step.fetch('notice_lines', []).each { |notice| lines << "#{indent}#{notice}" }
      end
    end

    def format_thing(thing)
      details = ["kind=#{thing.fetch('kind')}"]
      states = thing.fetch('states')
      details << "states=#{states.join(', ')}" unless states.empty?
      details << "damage=#{thing.fetch('damage')}" if thing.key?('damage')
      thing.fetch('values').each do |name, amount|
        next if name == 'damage'
        details << "#{name}=#{amount.is_a?(String) ? quote_text(amount) : amount}"
      end
      thing.fetch('relations').each { |relation, target| details << "#{relation}=#{target}" }
      "#{thing.fetch('name')}: #{details.join('; ')}"
    end
  end
end

# frozen_string_literal: true

require 'json'
require 'set'
require_relative 'ast_nodes'
require_relative 'dictionary'
require_relative 'text_literal'
require_relative 'world_save'

module BasicSharp
  class RetiredDKIRFormatError < ArgumentError; end

  class Runtime
    RETIRED_DKIR_MESSAGE = [
      'This file uses the retired DKIR format.',
      'BASIC# v0.1.20 uses BSharp IR.',
      'Recompile the original .bsharp source to create a new BSIR file.'
    ].join("\n").freeze

    MAX_WHOLE_NUMBER = 2_147_483_647
    MAX_FOLLOW_UP_EVENTS = 1_024
    EVENT_CHAIN_LIMIT_MESSAGE = [
      'Events kept causing more events.',
      '',
      'BASIC# stopped this chain after 1,024 follow-up events so it would not run forever.'
    ].join("\n").freeze
    VALUE_NAME_PATTERN = /\A[a-z][a-z0-9]*\z/

    OPPOSITE_STATES = {
      'open' => 'closed',
      'closed' => 'open',
      'locked' => 'unlocked',
      'unlocked' => 'locked',
      'alive' => 'dead',
      'dead' => 'alive',
      'calm' => 'angry',
      'angry' => 'calm',
      'friendly' => 'hostile',
      'hostile' => 'friendly',
      'visible' => 'hidden',
      'hidden' => 'visible',
      'carried' => 'dropped',
      'dropped' => 'carried',
      'broken' => 'whole',
      'whole' => 'broken',
      'on' => 'off',
      'off' => 'on'
    }.freeze

    attr_reader :startup_ran, :startup_if_rules, :startup_if_error, :startup_follow_up_events

    def game_declarations
      canonical_game_data({
        'controls' => @ir.fetch('controls', []),
        'hover' => @ir.fetch('hover_declarations', []),
        'context' => @ir.fetch('context_declarations', [])
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

    def self.load(path, world_save_path: nil)
      save_document = world_save_path ? WorldSave.read(world_save_path) : nil
      new(JSON.parse(File.read(path)), world_save: save_document)
    end

    def initialize(document, world_save: nil)
      @ir = stringify_keys(document.respond_to?(:to_h) ? document.to_h : document)
      validate_ir!

      @objects = {}
      @object_order = []
      @kind_parents = {}
      @known_kinds = Set.new(CoreDictionary::BUILTIN_KINDS)
      @kind_distance_index = {}
      @startup_ran = []
      @startup_if_rules = []
      @startup_if_error = nil
      @startup_follow_up_events = []
      @if_active = Array.new(@ir.fetch('if_rules', []).length, false)
      @world_origin = world_save ? 'BSharp Save' : 'START'
      @loaded_world_save = world_save ? stringify_keys(world_save) : nil
      load_kind_families
      create_things
      validate_reference_contracts!
      validate_numeric_contracts!

      if world_save
        prepare_value_schema
        restore_world_save!(world_save)
      else
        apply_start_facts
        startup_settlement = settle_if_rules(cause: 'START')
        @startup_if_rules = startup_settlement.fetch('rules')
        @startup_if_error = startup_settlement['error']
        @startup_ran = @startup_if_rules.flat_map { |entry| entry.fetch('steps').map { |step| step.fetch('word') } }

        if @startup_if_error.nil? && !startup_settlement.fetch('follow_ups', []).empty?
          startup_chain = drain_follow_up_events(startup_settlement.fetch('follow_ups'))
          @startup_follow_up_events = startup_chain.fetch('events')
          @startup_if_error = startup_chain['error']
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

    def save_ready?
      @save_ready == true
    end

    def program_fingerprint
      WorldSave.program_fingerprint(@ir)
    end

    def meaning_profile
      return WorldSave::MEANING_PROFILE_3 if @ir['meaning_profile'] == WorldSave::MEANING_PROFILE_3
      @ir['meaning_profile'] == WorldSave::MEANING_PROFILE_2 ? WorldSave::MEANING_PROFILE_2 : WorldSave::MEANING_PROFILE_1
    end

    def world_save_state
      unless save_ready?
        raise WorldSaveError, 'BSharp Save was not written because the world did not finish a successful event.'
      end

      {
        'settled' => true,
        'things' => snapshot.map do |thing|
          saved = thing.except('damage')
          saved['values'] = typed_save_values(saved.fetch('values')) unless meaning_profile == WorldSave::MEANING_PROFILE_1
          saved
        end,
        'if_rules' => @ir.fetch('if_rules', []).each_with_index.map do |rule, index|
          {
            'index' => index,
            'condition' => canonical_condition_text(rule.fetch('if')),
            'active' => @if_active.fetch(index)
          }
        end
      }
    end

    def write_world_save(path)
      WorldSave.write(path, self)
    end

    def restore_world_save!(document)
      WorldSave.validate_header!(document, @ir)
      world = document['world']
      candidate_objects, candidate_if_active = validate_world_save_state!(world, save_version: document['format_version'])
      @objects = candidate_objects
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
      return nil unless @known_kinds.include?(canonical)

      {
        'name' => canonical,
        'parent' => @kind_parents[canonical],
        'thing_count' => ask_kind_members(canonical).length
      }
    end

    def ask_resolve_kind(text)
      supplied = normalize(text)
      matches = @known_kinds.select do |kind|
        supplied == kind || supplied == ask_plural_kind(kind)
      end
      matches.length == 1 ? matches.first : nil
    end

    def ask_kind_members(kind_name)
      canonical = normalize(kind_name)
      @object_order.filter_map do |name|
        thing = @objects.fetch(name)
        distance = kind_distance(thing.fetch('kind'), canonical)
        next if distance.nil?

        {
          'name' => name,
          'kind' => thing.fetch('kind'),
          'inherited' => distance.positive?,
          'distance' => distance
        }
      end
    end

    def ask_event_match(event_text)
      event = normalize(event_text)
      match = find_event_match(event)
      unless match && match['rule']
        return {
          'matched' => false,
          'matched_when' => nil,
          'understood' => [],
          'actions' => [],
          'error' => match && match['error']
        }
      end

      rule = match.fetch('rule')
      context = match.fetch('context')
      {
        'matched' => true,
        'matched_when' => normalize(rule.dig('when', 'raw')),
        'understood' => context_explanations(rule, context),
        'actions' => rule.fetch('then', []).map { |word| ask_action_text(word) },
        'error' => nil
      }
    end

    def ask_if_rules
      @ir.fetch('if_rules', []).each_with_index.map do |rule, index|
        {
          'index' => index,
          'condition' => canonical_condition_text(rule.fetch('if')),
          'true' => condition_true?(rule.fetch('if')),
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
          'loaded' => false,
          'format_version' => nil,
          'settled' => save_ready?,
          'things' => snapshot.length,
          'fingerprint_matched' => nil
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

    def snapshot
      @object_order.map do |name|
        thing = @objects.fetch(name)
        entry = {
          'name' => thing.fetch('name'),
          'kind' => thing.fetch('kind'),
          'builtin' => thing.fetch('builtin'),
          'states' => thing.fetch('states').to_a.sort,
          'relations' => thing.fetch('relations').sort.to_h,
          'values' => thing.fetch('values').sort.to_h
        }
        damage = thing.fetch('values').fetch('damage', 0)
        entry['damage'] = damage if damage.positive?
        entry
      end
    end

    def report(event_result)
      lines = []
      lines << "BASIC# Runtime v#{VERSION}"
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
      name = normalize(object_name)
      thing = @objects[name]
      raise ArgumentError, "Context action object '#{name}' is not defined" unless thing

      word = replace_context_reference(stringify_keys(action), name, thing.fetch('kind'))
      @save_ready = false
      action_result = run_action_list([word], actor: 'player', context: {}, selections: [])
      settlement = action_result['error'] ? { 'rules' => [], 'error' => nil, 'follow_ups' => [] } : settle_if_rules(cause: 'context')
      error = action_result['error'] || settlement['error']
      chain = error ? { 'events' => [], 'error' => nil } : drain_follow_up_events(action_result.fetch('follow_ups', []) + settlement.fetch('follow_ups', []))
      error ||= chain['error']
      @save_ready = error.nil?
      {
        'object' => name,
        'ran' => action_result.fetch('steps').map { |step| step.fetch('word') },
        'steps' => action_result.fetch('steps'),
        'if_rules' => settlement.fetch('rules'),
        'follow_up_events' => chain.fetch('events'),
        'error' => error,
        'state' => snapshot
      }
    end

    private

    def replace_context_reference(value, object_name, object_kind)
      case value
      when Hash
        if normalize(value['type']) == 'context_it'
          return {
            'type' => 'object', 'text' => object_name, 'name' => object_name,
            'object_kind' => object_kind
          }
        end
        value.each_with_object({}) do |(key, entry), result|
          result[key] = replace_context_reference(entry, object_name, object_kind)
        end
      when Array
        value.map { |entry| replace_context_reference(entry, object_name, object_kind) }
      else
        value
      end
    end

    def ask_plural_kind(kind)
      return "#{kind[0...-1]}ies" if kind.end_with?('y') && kind.length > 1
      return "#{kind}es" if kind.end_with?('s', 'x', 'z', 'ch', 'sh')

      "#{kind}s"
    end

    def ask_action_text(word)
      action = normalize(word['action'])
      return "(cause #{normalize(word.dig('event', 'raw'))}" if action == 'cause'

      target = normalize(word.dig('target', 'text') || word.dig('target', 'name'))
      if action == 'damage'
        amount = word.fetch('amount', 1)
        return amount == 1 ? "(damage #{target}" : "(damage #{target} by #{amount}"
      end
      if action == 'change' && word['value_name']
        value = word.key?('to_text') ? quote_text(word['to_text']) : word['to_amount']
        return "(change #{normalize(word['value_name'])} of #{target} to #{value}"
      end
      if action == 'change'
        state = normalize(word.dig('to', 'name') || word.dig('to', 'text'))
        return "(change #{target} to #{state}"
      end

      "(#{action} #{target}"
    end

    def prepare_value_schema
      @ir.fetch('facts', []).each do |fact|
        next unless normalize(fact['relation']) == 'has'

        subject = thing_for_reference(fact['subject'])
        next unless subject

        default = fact.key?('text_value') ? '' : 0
        subject.fetch('values')[normalize(fact['value_name'])] = default unless subject.fetch('values').key?(normalize(fact['value_name']))
      end
    end

    def validate_world_save_state!(world, save_version:)
      unless world.is_a?(Hash)
        raise WorldSaveError, 'BSharp Save cannot load because its world entry is missing or invalid.'
      end
      unless world['settled'] == true
        raise WorldSaveError, 'BSharp Save cannot load because the saved world was not fully settled.'
      end

      things = world['things']
      unless things.is_a?(Array)
        raise WorldSaveError, 'BSharp Save cannot load because its Things entry is not a list.'
      end
      unless things.length == @object_order.length
        raise WorldSaveError, "BSharp Save contains #{things.length} Things, but this program defines #{@object_order.length}."
      end

      expected_names = @object_order.to_set
      candidate_objects = {}

      things.each_with_index do |entry, index|
        unless entry.is_a?(Hash)
          raise WorldSaveError, "BSharp Save Thing #{index + 1} does not describe one Thing."
        end

        expected_name = @object_order.fetch(index)
        name = canonical_save_text(entry['name'], "Thing #{index + 1} name")
        unless name == expected_name
          raise WorldSaveError, "BSharp Save expected Thing #{index + 1} to be #{expected_name}, but found #{name}."
        end

        expected = @objects.fetch(expected_name)
        kind = canonical_save_text(entry['kind'], "#{name} Kind")
        unless kind == expected.fetch('kind')
          raise WorldSaveError, "BSharp Save says #{name} is a #{kind}, but this program defines #{name} as a #{expected.fetch('kind')}."
        end

        builtin = entry['builtin']
        unless builtin == true || builtin == false
          raise WorldSaveError, "BSharp Save builtin flag for #{name} must be true or false."
        end
        unless builtin == expected.fetch('builtin')
          raise WorldSaveError, "BSharp Save builtin identity for #{name} does not match this program."
        end

        states = validate_saved_states!(entry['states'], name)
        relations = validate_saved_relations!(entry['relations'], name, expected_names)
        values = validate_saved_values!(entry['values'], name, expected.fetch('values'), save_version: save_version)

        candidate_objects[name] = {
          'name' => name,
          'kind' => kind,
          'builtin' => builtin,
          'states' => states,
          'relations' => relations,
          'values' => values,
          'damage' => values.fetch('damage')
        }
      end

      if_rules = world['if_rules']
      unless if_rules.is_a?(Array)
        raise WorldSaveError, 'BSharp Save cannot load because its IF-rule entry is not a list.'
      end
      expected_rules = @ir.fetch('if_rules', [])
      unless if_rules.length == expected_rules.length
        raise WorldSaveError, "BSharp Save contains #{if_rules.length} IF-rule records, but this program defines #{expected_rules.length}."
      end

      candidate_if_active = if_rules.each_with_index.map do |entry, index|
        unless entry.is_a?(Hash)
          raise WorldSaveError, "BSharp Save IF-rule record #{index + 1} is invalid."
        end
        unless entry['index'] == index
          raise WorldSaveError, "BSharp Save IF-rule record #{index + 1} has the wrong index."
        end

        expected_condition = canonical_condition_text(expected_rules.fetch(index).fetch('if'))
        condition = canonical_saved_condition(entry['condition'], "IF-rule #{index + 1} condition")
        unless condition == expected_condition
          raise WorldSaveError, "BSharp Save IF-rule #{index + 1} does not match '#{expected_condition}'."
        end

        active = entry['active']
        unless active == true || active == false
          raise WorldSaveError, "BSharp Save IF-rule #{index + 1} active flag must be true or false."
        end

        truth = condition_true_in_objects?(expected_rules.fetch(index).fetch('if'), candidate_objects)
        unless active == truth
          raise WorldSaveError, "BSharp Save IF-rule '#{expected_condition}' does not match the restored world."
        end
        active
      end

      [candidate_objects, candidate_if_active]
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
        next unless opposite && states.include?(opposite)

        raise WorldSaveError, "BSharp Save gives #{thing_name} contradictory states: #{state} and #{opposite}."
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
        raise WorldSaveError, "BSharp Save value names for #{thing_name} do not match this program."
      end

      entries.each_with_object({}) do |(name_value, saved_value), result|
        name = canonical_save_text(name_value, "#{thing_name} value name")
        unless VALUE_NAME_PATTERN.match?(name)
          raise WorldSaveError, "BSharp Save value name '#{name}' for #{thing_name} must be one plain word."
        end
        expected_type = expected_values.fetch(name).is_a?(String) ? 'text' : 'whole_number'
        value = if [WorldSave::FORMAT_VERSION_2, WorldSave::FORMAT_VERSION_3].include?(save_version)
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

    def condition_true_in_objects?(condition, objects)
      subject_name = saved_reference_name(condition['subject'])
      subject = objects[subject_name]
      return false unless subject

      if normalize(condition['relation']) == 'has'
        value_name = normalize(condition['value_name'])
        expected = condition.key?('text_value') ? condition['text_value'] : condition['amount']
        return subject.fetch('values')[value_name] == expected
      end

      if condition['target']
        relation = normalize(condition['relation'])
        return subject.fetch('relations')[relation] == saved_reference_name(condition['target'])
      end

      state = condition.dig('value', 'name') || condition.dig('value', 'text')
      return false unless state

      present = subject.fetch('states').include?(normalize(state))
      normalize(condition['relation']) == 'isnt' ? !present : present
    end

    def saved_reference_name(reference)
      return nil unless reference.is_a?(Hash)

      normalize(reference['name'] || reference['text'])
    end

    def validate_ir!
      format = normalize(@ir['format'])
      raise RetiredDKIRFormatError, RETIRED_DKIR_MESSAGE if format == 'dkir.debug.json'

      unless format == 'bsir.debug.json'
        shown = @ir['format'] || '(missing)'
        raise ArgumentError, "BSharp IR format '#{shown}' is not supported"
      end

      %w[kinds objects facts events if_rules diagnostics].each do |name|
        value = @ir[name]
        raise ArgumentError, "BSharp IR '#{name}' must be a list" unless value.is_a?(Array)
      end

      profile = @ir['meaning_profile']
      supported_profiles = [nil, '', WorldSave::MEANING_PROFILE_1, WorldSave::MEANING_PROFILE_2, WorldSave::MEANING_PROFILE_3]
      unless supported_profiles.include?(profile)
        raise ArgumentError, "BSharp IR meaning profile '#{profile}' is not supported"
      end
      text_used = ir_uses_text_values?
      if text_used && ![WorldSave::MEANING_PROFILE_2, WorldSave::MEANING_PROFILE_3].include?(profile)
        raise ArgumentError, 'Creator-facing text values require bsharp.meaning.v2 or bsharp.meaning.v3 in BSharp IR'
      end
      if profile == WorldSave::MEANING_PROFILE_2 && !text_used
        raise ArgumentError, 'bsharp.meaning.v2 requires at least one creator-facing text value'
      end
      game_used = Array(@ir['controls']).any? || Array(@ir['hover_declarations']).any? || Array(@ir['context_declarations']).any?
      if profile == WorldSave::MEANING_PROFILE_3 && !game_used
        raise ArgumentError, 'bsharp.meaning.v3 requires game input or interaction meaning'
      end

      raise ArgumentError, 'BSharp IR contains errors and cannot run' if ir_errors.any?
    end

    def ir_uses_text_values?
      @ir.fetch('facts', []).any? { |fact| fact.key?('text_value') } ||
        @ir.fetch('events', []).any? { |event| event.fetch('then', []).any? { |word| word.key?('to_text') } } ||
        @ir.fetch('if_rules', []).any? do |rule|
          rule.fetch('if', {}).key?('text_value') || rule.fetch('then', []).any? { |word| word.key?('to_text') }
        end
    end

    def ir_errors
      @ir.fetch('diagnostics', []).select { |diagnostic| diagnostic['severity'] == 'error' }
    end

    def validate_reference_contracts!
      @ir.fetch('facts', []).each do |fact|
        validate_reference!(fact['subject'], location: :start)
        validate_reference!(fact['target'], location: :start) if fact['target']
      end

      @ir.fetch('events', []).each do |rule|
        when_part = rule.fetch('when')
        validate_reference!(when_part['actor'], location: :event)
        validate_reference!(when_part['target'], location: :event) if when_part['target']
        bound_kinds = event_bound_kinds(when_part)
        rule.fetch('then', []).each { |word| validate_action_reference!(word, bound_kinds: bound_kinds) }
      end

      @ir.fetch('if_rules', []).each do |rule|
        condition = rule.fetch('if')
        validate_reference!(condition['subject'], location: :condition)
        validate_reference!(condition['target'], location: :condition) if condition['target']
        rule.fetch('then', []).each { |word| validate_action_reference!(word, bound_kinds: []) }
      end
    end
    def validate_action_reference!(word, bound_kinds:)
      if normalize(word['action']) == 'cause'
        validate_cause_action!(word, bound_kinds: bound_kinds)
        return
      end

      reference = word['target']
      return unless reference

      validate_reference!(reference, location: :action)

      type = normalize(reference['type'])
      return unless %w[kind_one kind].include?(type)

      kind = normalize(reference['kind_name'] || reference['text']).sub(/\Aa\s+/, '')
      raise ArgumentError,
            "BASIC# cannot choose one #{kind} here.\n\nName the #{kind}, use 'that #{kind}' after selecting one in WHEN,\nor use 'every #{kind}' for all #{kind} Things."
    end

    def validate_cause_action!(word, bound_kinds:)
      event = word['event']
      raise ArgumentError, '(cause is missing its event description' unless event.is_a?(Hash)

      raw = event['raw']
      raise ArgumentError, '(cause event text must be plain text' unless raw.is_a?(String)
      raise ArgumentError, '(cause must name an event' if normalize(raw).empty?

      action = event['action']
      unless action.is_a?(String) && !normalize(action).empty?
        raise ArgumentError, '(cause event is missing its event word'
      end
      raise ArgumentError, '(cause cannot cause another cause word as an event' if normalize(action) == 'cause'

      validate_caused_event_reference!(event['actor'], bound_kinds: bound_kinds, role: 'actor')
      validate_caused_event_reference!(event['target'], bound_kinds: bound_kinds, role: 'target') if event['target']
    end

    def validate_caused_event_reference!(reference, bound_kinds:, role:)
      validate_reference!(reference, location: :caused_event)
      type = normalize(reference['type'])
      text = normalize(reference['text'])

      case type
      when 'object'
        name = normalize(reference['name'] || reference['text'])
        raise ArgumentError, "Caused event #{role} '#{name}' is not a defined Thing" unless @objects.key?(name)
      when 'previous'
        kind = normalize(reference['kind_name'])
        raise ArgumentError, "'#{text}' has no selected #{kind} in this event" unless bound_kinds.include?(kind)
      when 'kind_set'
        kind = normalize(reference['kind_name'])
        raise ArgumentError, "'every #{kind}' cannot be used inside (cause yet"
      when 'kind_one', 'kind'
        kind = normalize(reference['kind_name'] || reference['text']).sub(/\Aa\s+/, '')
        raise ArgumentError, "BASIC# cannot choose one #{kind} for this caused event"
      else
        raise ArgumentError, "Caused event #{role} '#{text}' must name a Thing or use 'that Kind'"
      end
    end

    def event_bound_kinds(event)
      [event['actor'], event['target']].compact.filter_map do |reference|
        type = normalize(reference['type'])
        normalize(reference['kind_name']) if %w[kind_one kind].include?(type)
      end.uniq
    end
    def validate_reference!(reference, location:)
      unless reference.is_a?(Hash)
        raise ArgumentError, "#{reference_location_name(location)} reference must describe a Thing"
      end

      return unless normalize(reference['type']) == 'kind_set'

      selector = reference['selector']
      unless selector.is_a?(String)
        raise ArgumentError, 'Set reference is missing its text selector'
      end
      unless normalize(selector) == 'every'
        raise ArgumentError, "Set reference selector '#{selector}' is not supported; use 'every'"
      end

      unless reference.key?('kind_name')
        raise ArgumentError, 'Set reference is missing its Kind name'
      end

      kind_value = reference['kind_name']
      unless kind_value.is_a?(String)
        raise ArgumentError, 'Set reference has a Kind name that is not text'
      end

      kind = normalize(kind_value)
      raise ArgumentError, 'Set reference has an empty Kind name' if kind.empty?
      raise ArgumentError, "Set reference uses unknown Kind '#{kind}'" unless @known_kinds.include?(kind)

      case location
      when :action
        nil
      when :event
        raise ArgumentError, "'every #{kind}' can be used as an action target after |then.\n\nWHEN still describes one event Thing."
      when :start
        raise ArgumentError, "'every #{kind}' can be used as an action target after |then.\n\nSTART still describes one Thing at a time."
      when :condition
        raise ArgumentError, "'every #{kind}' is not yet supported inside an IF condition.\n\nBASIC# would need to know whether you mean every #{kind} or any #{kind}."
      end
    end

    def validate_numeric_contracts!
      starting_values = {}
      value_types = { 'damage' => :whole_number }

      @ir.fetch('facts', []).each_with_index do |fact, index|
        next unless normalize(fact['relation']) == 'has'

        value_name = validate_value_name_field!(fact, 'value_name', "START value entry #{index + 1}")
        value_type = fact.key?('text_value') ? :text : :whole_number
        value = if value_type == :text
                  raise ArgumentError, 'damage is a whole-number value and cannot store text' if value_name == 'damage'
                  validate_text_value_field!(fact, 'text_value', label: "START #{value_name} text")
                else
                  validate_whole_number_field!(fact, 'amount', minimum: 0, label: "START #{value_name} amount")
                end
        subject_name = reference_name(fact['subject'])
        next unless subject_name

        key = [subject_name, value_name]
        if starting_values.key?(key)
          raise ArgumentError, "#{subject_name} already has a starting #{value_name} value.
Choose one starting amount."
        end
        starting_values[key] = value
        established = value_types[value_name]
        if established && established != value_type
          raise ArgumentError, "BASIC# value #{value_name} cannot change its established value type"
        end
        value_types[value_name] = value_type
      end

      @ir.fetch('events', []).each do |rule|
        rule.fetch('then', []).each { |word| validate_numeric_action!(word, value_types) }
      end

      @ir.fetch('if_rules', []).each do |rule|
        condition = rule.fetch('if')
        if normalize(condition['relation']) == 'has'
          value_name = validate_value_name_field!(condition, 'value_name', 'IF value condition')
          if condition.key?('text_value')
            validate_text_value_field!(condition, 'text_value', label: "IF #{value_name} text")
            validate_established_value_type!(condition['subject'], value_name, :text, value_types, 'IF text comparison')
          else
            validate_whole_number_field!(condition, 'amount', minimum: 0, label: "IF #{value_name} amount")
            validate_established_value_type!(condition['subject'], value_name, :whole_number, value_types, 'IF whole-number comparison')
          end
        end
        rule.fetch('then', []).each { |word| validate_numeric_action!(word, value_types) }
      end
    end

    def validate_numeric_action!(word, value_types)
      action = normalize(word['action'])
      if action == 'damage'
        return unless word.key?('amount')

        validate_whole_number_field!(word, 'amount', minimum: 1, label: 'Damage amount')
        return
      end

      return unless action == 'change'

      value_shape = word.key?('value_name') || word.key?('to_amount') || word.key?('to_text')
      return unless value_shape

      value_name = validate_value_name_field!(word, 'value_name', 'Value change')
      if word.key?('to_text')
        raise ArgumentError, 'Text value change cannot also contain a whole-number amount' if word.key?('to_amount')
        validate_text_value_field!(word, 'to_text', label: "New #{value_name} text")
        validate_established_value_type!(word['target'], value_name, :text, value_types, 'Text value change')
      else
        validate_whole_number_field!(word, 'to_amount', minimum: 0, label: "New #{value_name} amount")
        validate_established_value_type!(word['target'], value_name, :whole_number, value_types, 'Whole-number value change')
      end
      raise ArgumentError, 'Value change cannot also contain a state target' if word.key?('to')
    end

    def validate_established_value_type!(reference, value_name, expected_type, value_types, label)
      actual = value_types[value_name]
      if actual.nil?
        value_types[value_name] = expected_type
        return
      end
      return if actual == expected_type

      shown = actual == :text ? 'text' : 'a whole number'
      raise ArgumentError, "#{label} cannot use #{value_name} because it is #{shown}"
    end

    def validate_value_name_field!(entry, key, label)
      raise ArgumentError, "#{label} is missing its value name" unless entry.key?(key)

      value = entry[key]
      raise ArgumentError, "#{label} has a value name that is not text" unless value.is_a?(String)

      normalized = normalize(value)
      raise ArgumentError, "#{label} has an empty value name" if normalized.empty?
      unless VALUE_NAME_PATTERN.match?(normalized)
        raise ArgumentError, "Value name '#{normalized}' must be one plain word"
      end

      normalized
    end

    def validate_whole_number_field!(entry, key, minimum:, label:)
      raise ArgumentError, "#{label} is missing" unless entry.key?(key)

      amount = entry[key]
      raise ArgumentError, "#{label} must be a whole number" unless amount.is_a?(Integer)
      raise ArgumentError, "#{label} must be at least #{minimum}" if amount < minimum
      if amount > MAX_WHOLE_NUMBER
        raise ArgumentError, "#{label} cannot be greater than #{MAX_WHOLE_NUMBER}"
      end

      amount
    end

    def validate_text_value_field!(entry, key, label:)
      raise ArgumentError, "#{label} is missing" unless entry.key?(key)
      TextLiteral.new(entry[key]).value
    rescue TextLiteralError => error
      raise ArgumentError, "#{label} is invalid: #{error.message}"
    end

    def reference_location_name(location)
      {
        start: 'START',
        event: 'WHEN',
        condition: 'IF',
        action: 'Action target',
        caused_event: 'Caused event'
      }.fetch(location, 'BSharp IR')
    end


    def load_kind_families
      @ir.fetch('kinds', []).each_with_index do |entry, index|
        position = index + 1
        unless entry.is_a?(Hash)
          raise ArgumentError, "Kind family entry #{position} must describe one Kind"
        end

        name = kind_entry_text(entry, 'name', position, 'Kind name')
        parent = kind_entry_text(entry, 'parent', position, 'parent Kind')

        if @kind_parents.key?(name)
          previous = @kind_parents.fetch(name)
          if previous == parent
            raise ArgumentError, "Kind family has a duplicate: #{name} is listed more than once"
          end

          raise ArgumentError, "Kind family conflicts: #{name} has more than one parent: #{previous} and #{parent}"
        end

        @kind_parents[name] = parent
        @known_kinds.add(name)
      end

      @kind_parents.each do |name, parent|
        next if @known_kinds.include?(parent)

        raise ArgumentError, "Kind family is broken: #{name} has unknown parent #{parent}"
      end

      validate_kind_family_loops!
      build_kind_distance_index!
    end

    def kind_entry_text(entry, key, position, label)
      unless entry.key?(key)
        raise ArgumentError, "Kind family entry #{position} is missing its #{label}"
      end

      value = entry[key]
      unless value.is_a?(String)
        raise ArgumentError, "Kind family entry #{position} has a #{label} that is not text"
      end

      normalized = normalize(value)
      if normalized.empty?
        raise ArgumentError, "Kind family entry #{position} has an empty #{label}"
      end

      normalized
    end

    def validate_kind_family_loops!
      @kind_parents.each_key do |starting_kind|
        path = []
        positions = {}
        current = starting_kind

        while current && @kind_parents.key?(current)
          if positions.key?(current)
            cycle = path[positions.fetch(current)..] + [current]
            raise ArgumentError, "Kind family has a loop: #{cycle.join(' -> ')}"
          end

          positions[current] = path.length
          path << current
          current = @kind_parents[current]
        end
      end
    end

    def build_kind_distance_index!
      index = {}

      @known_kinds.each do |kind|
        distances = {}
        current = kind
        distance = 0

        while current
          distances[current] = distance
          current = @kind_parents[current]
          distance += 1
        end

        index[kind] = distances.freeze
      end

      @kind_distance_index = index.freeze
    end

    def create_things
      @ir.fetch('objects', []).each do |object|
        name = normalize(object.fetch('name'))
        raise ArgumentError, "BSharp IR has more than one Thing named '#{name}'" if @objects.key?(name)

        kind = normalize(object.fetch('kind'))
        unless @known_kinds.include?(kind)
          raise ArgumentError, "#{name} says it is a #{kind}, but #{kind} is not a known Kind"
        end

        @object_order << name
        @objects[name] = {
          'name' => name,
          'kind' => kind,
          'builtin' => object.fetch('builtin', false),
          'states' => Set.new,
          'relations' => {},
          'values' => { 'damage' => 0 },
          'damage' => 0
        }
      end
    end

    def apply_start_facts
      @ir.fetch('facts', []).each do |fact|
        subject = thing_for_reference(fact['subject'])
        next unless subject

        if normalize(fact['relation']) == 'has'
          value_name = normalize(fact['value_name'])
          value = fact.key?('text_value') ? fact['text_value'] : fact['amount']
          subject.fetch('values')[value_name] = value
          subject['damage'] = value if value_name == 'damage' && value.is_a?(Integer)
          next
        end

        if fact['target']
          target_name = reference_name(fact['target'])
          subject.fetch('relations')[normalize(fact['relation'])] = target_name if target_name
          next
        end

        value = fact.dig('value', 'name') || fact.dig('value', 'text')
        next unless value

        relation = normalize(fact['relation'])
        relation == 'isnt' ? remove_state(subject, value) : set_state(subject, value)
      end
    end

    def settle_if_rules(cause:)
      rules = @ir.fetch('if_rules', [])
      return { 'rules' => [], 'error' => nil, 'follow_ups' => [] } if rules.empty?

      fired = []
      follow_ups = []
      fired_indexes = Set.new
      initially_true = rules.map { |rule| condition_true?(rule['if']) }
      seen = nil
      firing_limit = [256, rules.length * 8].max
      condition_trail = []

      loop do
        fired_this_pass = false

        rules.each_with_index do |rule, index|
          current = condition_true?(rule['if'])
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
          action_result = run_action_list(rule.fetch('then', []), actor: nil, context: {}, selections: selections)
          steps = action_result.fetch('steps')
          condition = canonical_condition_text(rule.fetch('if'))
          reason = if initially_true[index] && !fired_indexes.include?(index)
                     cause == 'START' ? 'was true after START' : 'became true after the event'
                   else
                     'became true'
                   end
          fired << {
            'condition' => condition,
            'reason' => reason,
            'steps' => steps,
            'selections' => selections
          }
          follow_ups.concat(action_result.fetch('follow_ups', []))
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
    def run_action_list(words, actor:, context:, selections: [])
      steps = []
      follow_ups = []
      error = nil

      words.each do |word|
        if normalize(word['action']) == 'cause'
          materialized = materialize_caused_event(word, context: context)
          if materialized['error']
            steps << {
              'word' => "(cause #{normalize(word.dig('event', 'raw'))}",
              'notice_lines' => [materialized.fetch('error')]
            }
            error = materialized.fetch('error')
            break
          end

          event_text = materialized.fetch('event')
          caused_by = "(cause #{event_text}"
          steps << {
            'word' => caused_by,
            'change' => "#{event_text} will happen next",
            'caused_event' => event_text,
            '_staged_follow_up' => true
          }
          follow_ups << {
            'event' => event_text,
            'caused_by' => caused_by,
            'line_number' => word['line_number']
          }
          next
        end

        selection = action_selection(word['target'], context: context)
        selections << selection.except('things') if selection['set']

        targets = selection.fetch('things')
        if targets.empty?
          next unless selection['set']

          action = normalize(word['action'])
          text = selection.fetch('text')
          steps << {
            'word' => display_action_for_selection(word, text),
            'notice_lines' => [
              "#{text} found no Things",
              "(#{action} had nothing to act on"
            ],
            'targets' => []
          }
          next
        end

        preflight_error = preflight_action(word, targets)
        if preflight_error
          steps << {
            'word' => display_action_for_selection(word, selection.fetch('text')),
            'notice_lines' => [preflight_error, 'Nothing in this action line was changed.'],
            'targets' => targets.map { |target| target.fetch('name') }
          }
          error = preflight_error
          break
        end

        begin
          targets.each do |target|
            step = run_official_word(word, target: target, actor: actor)
            steps << step if step
          end
        rescue ArgumentError, KeyError => runtime_error
          steps << {
            'word' => display_action_for_selection(word, selection.fetch('text')),
            'notice_lines' => [runtime_error.message],
            'targets' => targets.map { |target| target.fetch('name') }
          }
          error = runtime_error.message
          break
        end
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
    def discard_if_follow_up_steps!(rules, message)
      rules.each { |entry| discard_follow_up_steps!(entry.fetch('steps', []), message) }
    end

    def discard_follow_up_steps!(steps, message)
      steps.each do |step|
        next unless step['caused_event'] && step['change']

        step.delete('change')
        step['notice_lines'] = [message]
      end
    end

    def display_action_for_selection(word, text)
      action = normalize(word['action'])
      if action == 'damage'
        amount = word.fetch('amount', 1)
        return amount == 1 ? "(damage #{text}" : "(damage #{text} by #{amount}"
      end
      if action == 'change' && word['value_name']
        value = word.key?('to_text') ? quote_text(word['to_text']) : word['to_amount']
        return "(change #{normalize(word['value_name'])} of #{text} to #{value}"
      end

      "(#{action} #{text}"
    end

    def preflight_action(word, targets)
      action = normalize(word['action'])
      if action == 'damage'
        amount = word.fetch('amount', 1)
        overflowing = targets.find do |target|
          target.fetch('values').fetch('damage', 0) > MAX_WHOLE_NUMBER - amount
        end
        return "#{overflowing.fetch('name')} damage would be greater than #{MAX_WHOLE_NUMBER}" if overflowing
      elsif action == 'change' && word['value_name']
        value_name = normalize(word['value_name'])
        missing = targets.find { |target| !target.fetch('values').key?(value_name) }
        return "#{missing.fetch('name')} does not have a value named #{value_name}." if missing
        wants_text = word.key?('to_text')
        wrong_type = targets.find { |target| target.fetch('values').fetch(value_name).is_a?(String) != wants_text }
        if wrong_type
          expected = wants_text ? 'text' : 'a whole number'
          return "#{wrong_type.fetch('name')} value #{value_name} is not #{expected}."
        end
      end

      nil
    end

    def rearm_false_if_rules!
      @ir.fetch('if_rules', []).each_with_index do |rule, index|
        @if_active[index] = false unless condition_true?(rule['if'])
      end
    end

    def if_world_signature
      JSON.generate([snapshot, @if_active])
    end

    def if_loop_error(condition_trail)
      shown = condition_trail.empty? ? ['IF conditions repeated'] : condition_trail
      "IF rules kept waking each other.\n\n#{shown.join("\n")}\n\nBASIC# stopped this chain so it would not run forever."
    end

    def condition_true?(condition)
      subject = thing_for_reference(condition['subject'])
      return false unless subject

      if normalize(condition['relation']) == 'has'
        value_name = normalize(condition['value_name'])
        expected = condition.key?('text_value') ? condition['text_value'] : condition['amount']
        return subject.fetch('values')[value_name] == expected
      end

      if condition['target']
        relation = normalize(condition['relation'])
        return subject.fetch('relations')[relation] == reference_name(condition['target'])
      end

      state = condition.dig('value', 'name') || condition.dig('value', 'text')
      return false unless state

      present = subject.fetch('states').include?(normalize(state))
      normalize(condition['relation']) == 'isnt' ? !present : present
    end

    def find_event_match(event_text)
      exact = @ir.fetch('events', []).find do |candidate|
        exact_event_rule?(candidate) && normalize(candidate.dig('when', 'raw')) == event_text
      end
      return { 'rule' => exact, 'context' => {}, 'error' => nil } if exact

      best_error = nil
      best_match = nil
      best_distance = nil

      @ir.fetch('events', []).each do |rule|
        attempt = match_event_rule(rule, event_text)
        if attempt['rule']
          distance = attempt.fetch('kind_distance', 0)
          if best_match.nil? || distance < best_distance
            best_match = attempt
            best_distance = distance
          end
          next
        end

        best_error ||= attempt['error'] if attempt['same_event_shape']
      end

      best_match || { 'rule' => nil, 'context' => {}, 'error' => best_error }
    end


    def exact_event_rule?(rule)
      when_part = rule.fetch('when')
      [when_part['actor'], when_part['target']].compact.none? { |reference| kind_reference?(reference) }
    end

    def kind_reference?(reference)
      %w[kind_one kind].include?(normalize(reference && reference['type']))
    end

    def match_event_rule(rule, event_text)
      when_part = rule.fetch('when')
      parsed = parse_event_text(event_text, when_part['action'])
      return no_match unless parsed

      actor_match = match_event_reference(when_part['actor'], parsed['actor'])
      unless actor_match['matched']
        if kind_reference?(when_part['actor'])
          return {
            'rule' => nil,
            'context' => {},
            'error' => actor_match['error'],
            'same_event_shape' => true
          }
        end
        return no_match
      end

      target_match = match_event_reference(when_part['target'], parsed['target'])
      unless target_match['matched']
        return {
          'rule' => nil,
          'context' => {},
          'error' => target_match['error'],
          'same_event_shape' => true
        }
      end

      context = {}
      bind_context(context, actor_match)
      bind_context(context, target_match)
      kind_distance = actor_match.fetch('kind_distance', 0) + target_match.fetch('kind_distance', 0)
      {
        'rule' => rule,
        'context' => context,
        'error' => nil,
        'same_event_shape' => true,
        'kind_distance' => kind_distance
      }
    end

    def parse_event_text(event_text, expected_action)
      words = normalize(event_text).split
      action_index = words.each_index.find do |index|
        index.positive? && normalize_event_word(words[index]) == normalize(expected_action)
      end
      return nil unless action_index

      {
        'actor' => words[0...action_index].join(' '),
        'action' => normalize(expected_action),
        'target' => words[(action_index + 1)..]&.join(' ').to_s
      }
    end

    def normalize_event_word(word)
      normalized = normalize(word)
      return normalized[0...-3] + 'y' if normalized.end_with?('ies')
      return normalized[0...-2] if normalized.end_with?('es') && normalized[0...-2].end_with?('s', 'x', 'z', 'ch', 'sh')

      normalized.sub(/s\z/, '')
    end

    def match_event_reference(reference, supplied_text)
      return { 'matched' => supplied_text.empty?, 'context_kind' => nil, 'name' => nil, 'error' => nil, 'kind_distance' => 0 } unless reference

      type = normalize(reference['type'])
      supplied = normalize(supplied_text)

      case type
      when 'object'
        expected = normalize(reference['name'] || reference['text'])
        return { 'matched' => supplied == expected, 'context_kind' => nil, 'name' => expected, 'error' => nil, 'kind_distance' => 0 }
      when 'kind_one', 'kind'
        match_kind_reference(reference, supplied)
      else
        expected = normalize(reference['name'] || reference['text'])
        { 'matched' => supplied == expected, 'context_kind' => nil, 'name' => expected, 'error' => nil, 'kind_distance' => 0 }
      end
    end

    def match_kind_reference(reference, supplied)
      kind = normalize(reference['kind_name'])
      thing = @objects[supplied]
      unless thing
        return {
          'matched' => false,
          'context_kind' => kind,
          'name' => nil,
          'error' => "event Thing '#{supplied}' is not defined"
        }
      end

      actual_kind = thing.fetch('kind')
      distance = kind_distance(actual_kind, kind)
      unless distance
        return {
          'matched' => false,
          'context_kind' => kind,
          'name' => supplied,
          'error' => "#{supplied} is a #{actual_kind}, not a #{kind}",
          'kind_distance' => 0
        }
      end

      {
        'matched' => true,
        'context_kind' => kind,
        'name' => supplied,
        'error' => nil,
        'kind_distance' => distance
      }
    end


    def kind_distance(actual_kind, expected_kind)
      actual = normalize(actual_kind)
      expected = normalize(expected_kind)
      @kind_distance_index.fetch(actual, {}).fetch(expected, nil)
    end

    def bind_context(context, match)
      kind = match['context_kind']
      name = match['name']
      context[kind] = name if kind && name
    end

    def no_match
      { 'rule' => nil, 'context' => {}, 'error' => nil, 'same_event_shape' => false }
    end

    def context_explanations(rule, context)
      explanations = []
      when_part = rule.fetch('when')

      [when_part['actor'], when_part['target']].compact.each do |reference|
        next unless kind_reference?(reference)

        kind = normalize(reference['kind_name'])
        name = context[kind]
        explanations << "#{normalize(reference['text'])} means #{name}" if name
      end

      rule.fetch('then', []).each do |word|
        references = if normalize(word['action']) == 'cause'
                       event = word['event'] || {}
                       [event['actor'], event['target']].compact
                     else
                       [word['target']].compact
                     end

        references.each do |reference|
          next unless normalize(reference && reference['type']) == 'previous'

          kind = normalize(reference['kind_name'])
          name = context[kind]
          explanations << "#{normalize(reference['text'])} means #{name}" if name
        end
      end

      explanations.uniq
    end
    def action_selection(reference, context:)
      if reference.is_a?(Hash) && normalize(reference['type']) == 'kind_set'
        kind = normalize(reference['kind_name'])
        names = @object_order.select do |name|
          thing = @objects.fetch(name)
          !kind_distance(thing.fetch('kind'), kind).nil?
        end
        return {
          'set' => true,
          'text' => "every #{kind}",
          'kind_name' => kind,
          'targets' => names,
          'count' => names.length,
          'things' => names.map { |name| @objects.fetch(name) }
        }
      end

      target = thing_for_reference(reference, context: context)
      {
        'set' => false,
        'text' => normalize(reference && reference['text']),
        'targets' => target ? [target.fetch('name')] : [],
        'count' => target ? 1 : 0,
        'things' => target ? [target] : []
      }
    end

    def run_official_word(word, target:, actor:)
      name = normalize(word['action'])
      target_name = target.fetch('name')
      case name
      when 'damage'
        amount = word.fetch('amount', 1)
        old_amount = target.fetch('values').fetch('damage', 0)
        new_amount = old_amount + amount
        target.fetch('values')['damage'] = new_amount
        target['damage'] = new_amount
        step = {
          'word' => amount == 1 ? "(damage #{target_name}" : "(damage #{target_name} by #{amount}",
          'change' => amount == 1 ? "#{target_name} damage is now #{new_amount}" : "#{target_name} damage changed from #{old_amount} to #{new_amount}"
        }
        if amount != 1
          step['value_change'] = {
            'value_name' => 'damage',
            'old_amount' => old_amount,
            'new_amount' => new_amount,
            'action_amount' => amount
          }
        end
        step
      when 'change'
        if word['value_name']
          value_name = normalize(word['value_name'])
          old_value = target.fetch('values').fetch(value_name)
          new_value = word.key?('to_text') ? word.fetch('to_text') : word.fetch('to_amount')
          target.fetch('values')[value_name] = new_value
          target['damage'] = new_value if value_name == 'damage' && new_value.is_a?(Integer)
          old_display = old_value.is_a?(String) ? quote_text(old_value) : old_value
          new_display = new_value.is_a?(String) ? quote_text(new_value) : new_value
          return {
            'word' => "(change #{value_name} of #{target_name} to #{new_display}",
            'change' => "#{target_name} #{value_name} changed from #{old_display} to #{new_display}",
            'value_change' => {
              'value_name' => value_name,
              (new_value.is_a?(String) ? 'old_text' : 'old_amount') => old_value,
              (new_value.is_a?(String) ? 'new_text' : 'new_amount') => new_value
            }
          }
        end

        state = word.dig('to', 'name') || word.dig('to', 'text')
        return nil unless state

        state_name = normalize(state)
        set_state(target, state_name)
        { 'word' => "(change #{target_name} to #{state_name}", 'change' => "#{target_name} is now #{state_name}" }
      when 'carry'
        carrier = actor || 'player'
        target.fetch('relations').delete('on')
        target.fetch('relations').delete('in')
        target.fetch('relations')['carried by'] = carrier
        { 'word' => "(carry #{target_name}", 'change' => "#{target_name} is now carried by #{carrier}" }
      when 'unlock'
        set_state(target, 'unlocked')
        { 'word' => "(unlock #{target_name}", 'change' => "#{target_name} is now unlocked" }
      else
        raise ArgumentError, "runtime does not know how to run (#{name}"
      end
    end

    def set_state(thing, state)
      normalized = normalize(state)
      opposite = OPPOSITE_STATES[normalized]
      thing.fetch('states').delete(opposite) if opposite
      thing.fetch('states').add(normalized)
    end

    def remove_state(thing, state)
      thing.fetch('states').delete(normalize(state))
    end

    def thing_for_reference(reference, context: {})
      name = reference_name(reference, context: context)
      name ? @objects[name] : nil
    end

    def reference_name(reference, context: {})
      return nil unless reference.is_a?(Hash)

      if normalize(reference['type']) == 'previous'
        return context[normalize(reference['kind_name'])]
      end

      normalize(reference['name'] || reference['text'])
    end

    def process_event(event_text, caused_by: nil, caused_by_line: nil)
      match = find_event_match(event_text)
      unless match && match['rule']
        outcome = result(event_text, false, [], {}, match && match['error'], caused_by: caused_by, caused_by_line: caused_by_line)
        outcome['_follow_ups'] = []
        outcome['_fatal_error'] = nil
        return outcome
      end

      rule = match.fetch('rule')
      context = match.fetch('context')
      actor = reference_name(rule.dig('when', 'actor'), context: context)
      selections = []
      action_result = run_action_list(rule.fetch('then', []), actor: actor, context: context, selections: selections)
      steps = action_result.fetch('steps')
      if_settlement = if action_result['error']
                        { 'rules' => [], 'error' => nil, 'follow_ups' => [] }
                      else
                        settle_if_rules(cause: 'event')
                      end
      fatal_error = action_result['error'] || if_settlement['error']
      if if_settlement['error'] && action_result['error'].nil?
        discard_follow_up_steps!(steps, 'IF rules did not finish, so this event will not happen.')
      end
      follow_ups = if fatal_error
                     []
                   else
                     action_result.fetch('follow_ups', []) + if_settlement.fetch('follow_ups', [])
                   end

      outcome = result(
        event_text,
        true,
        steps.map { |step| step.fetch('word') },
        context,
        fatal_error,
        matched_when: normalize(rule.dig('when', 'raw')),
        understood: context_explanations(rule, context),
        steps: steps,
        selections: selections,
        if_rules: if_settlement.fetch('rules'),
        caused_by: caused_by,
        caused_by_line: caused_by_line
      )
      outcome['_follow_ups'] = follow_ups
      outcome['_fatal_error'] = fatal_error
      outcome
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
        outcome = process_event(
          event_text,
          caused_by: pending['caused_by'],
          caused_by_line: pending['line_number']
        )
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

    def materialize_caused_event(word, context:)
      event = word['event'] || {}
      raw = normalize(event['raw'])
      actor_reference = event['actor']
      actor_text = normalize(actor_reference && actor_reference['text'])
      actor_name = reference_name(actor_reference, context: context)
      unless actor_name
        return { 'error' => "BASIC# could not resolve '#{actor_text}' for this caused event." }
      end

      unless raw.start_with?("#{actor_text} ")
        return { 'error' => 'BSharp IR caused event does not begin with its actor.' }
      end

      target_reference = event['target']
      unless target_reference
        return { 'event' => normalize("#{actor_name}#{raw[actor_text.length..]}") }
      end

      target_text = normalize(target_reference['text'])
      target_name = reference_name(target_reference, context: context)
      unless target_name
        return { 'error' => "BASIC# could not resolve '#{target_text}' for this caused event." }
      end

      suffix = " #{target_text}"
      unless raw.end_with?(suffix)
        return { 'error' => 'BSharp IR caused event does not end with its target.' }
      end

      middle_end = raw.length - suffix.length
      middle = raw[actor_text.length...middle_end]
      { 'event' => normalize("#{actor_name}#{middle} #{target_name}") }
    end

    def result(event_text, matched, ran, context, error, matched_when: nil, understood: [], steps: [], selections: [], if_rules: [], caused_by: nil, caused_by_line: nil)
      outcome = {
        'event' => event_text,
        'matched' => matched,
        'matched_when' => matched_when,
        'understood' => understood,
        'ran' => ran,
        'steps' => steps,
        'selections' => selections,
        'if_rules' => if_rules,
        'context' => context,
        'error' => error
      }
      outcome['caused_by'] = caused_by if caused_by
      outcome['caused_by_line'] = caused_by_line if caused_by_line
      outcome
    end
    def append_follow_up_report(lines, entries)
      indexes = if entries.length <= 12
                  (0...entries.length).to_a
                else
                  (0...9).to_a + ((entries.length - 3)...entries.length).to_a
                end
      previous_index = nil

      indexes.each do |index|
        if previous_index && index > previous_index + 1
          lines << "  ... #{index - previous_index - 1} more follow-up events happened ..."
        end

        entry = entries.fetch(index)
        lines << "  event #{index + 1}: #{entry.fetch('event')}"
        if entry['caused_by']
          lines << '  caused by:'
          lines << "    #{entry.fetch('caused_by')}"
        end
        lines << "  matched: #{entry.fetch('matched') ? 'yes' : 'no'}"
        lines << "  error: #{entry.fetch('error')}" if entry['error']
        if entry['matched_when']
          lines << '  what matched:'
          lines << "    #{entry.fetch('matched_when')}"
        end
        unless entry.fetch('understood', []).empty?
          lines << '  what I understood:'
          entry.fetch('understood').each { |line| lines << "    #{line}" }
        end
        unless entry.fetch('selections', []).empty?
          lines << '  what I selected:'
          append_selection_report(lines, entry.fetch('selections'), indent: '    ')
        end
        unless entry.fetch('steps', []).empty?
          lines << '  what happened:'
          append_steps_report(lines, entry.fetch('steps'), indent: '    ')
        end
        unless entry.fetch('if_rules', []).empty?
          lines << '  IF rules:'
          append_if_rule_report(lines, entry.fetch('if_rules'))
        end
        previous_index = index
      end
    end

    def append_if_rule_report(lines, entries)
      entries.each do |entry|
        lines << "  #{entry.fetch('condition')} #{entry.fetch('reason')}"
        unless entry.fetch('selections', []).empty?
          lines << '  selected:'
          append_selection_report(lines, entry.fetch('selections'), indent: '    ')
        end
        lines << '  ran:'
        append_steps_report(lines, entry.fetch('steps'), indent: '    ')
      end
    end

    def append_selection_report(lines, selections, indent:)
      selections.each do |selection|
        text = selection.fetch('text')
        targets = selection.fetch('targets')
        count = selection.fetch('count')

        if count.zero?
          lines << "#{indent}#{text} found no Things"
        elsif count <= 12
          lines << "#{indent}#{text} means #{targets.join(', ')}"
        else
          lines << "#{indent}#{text} selected #{count} Things:"
          lines << "#{indent}  #{targets.first(12).join(', ')}"
          lines << "#{indent}  and #{count - 12} more"
        end
      end
    end

    def append_steps_report(lines, steps, indent:)
      visible = steps.length > 12 ? steps.first(12) : steps
      visible.each do |step|
        lines << "#{indent}#{step.fetch('word')}"
        lines << "#{indent}#{step.fetch('change')}" if step['change']
        step.fetch('notice_lines', []).each { |notice| lines << "#{indent}#{notice}" }
      end
      lines << "#{indent}and #{steps.length - 12} more action results" if steps.length > 12
    end

    def format_thing(thing)
      details = ["kind=#{thing.fetch('kind')}"]
      states = thing.fetch('states')
      details << "states=#{states.join(', ')}" unless states.empty?
      details << "damage=#{thing.fetch('damage')}" if thing.key?('damage')
      thing.fetch('values', {}).each do |value_name, amount|
        next if value_name == 'damage'

        details << "#{value_name}=#{amount.is_a?(String) ? quote_text(amount) : amount}"
      end
      thing.fetch('relations').each { |relation, target| details << "#{relation}=#{target}" }
      "#{thing.fetch('name')}: #{details.join('; ')}"
    end

    def normalize(value)
      value.to_s.strip.downcase.gsub(/\s+/, ' ')
    end

    def quote_text(value)
      %Q{"#{value}"}
    end

    def canonical_condition_text(condition)
      return normalize(condition['raw']) unless condition.key?('text_value')

      subject = reference_name(condition['subject']) || normalize(condition.dig('subject', 'text'))
      "#{subject} has #{quote_text(condition['text_value'])} #{normalize(condition['value_name'])}"
    end

    def typed_save_values(values)
      values.to_h do |name, value|
        type = value.is_a?(String) ? 'text' : 'whole_number'
        [name, { 'type' => type, 'value' => value }]
      end
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
  end
end

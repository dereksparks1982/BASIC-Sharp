# frozen_string_literal: true

require 'json'
require 'set'
require_relative 'ast_nodes'
require_relative 'dictionary'

module BasicSharp
  class Runtime
    MAX_WHOLE_NUMBER = 2_147_483_647
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

    attr_reader :startup_ran, :startup_if_rules, :startup_if_error

    def self.load(path)
      new(JSON.parse(File.read(path)))
    end

    def initialize(document)
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
      @if_active = Array.new(@ir.fetch('if_rules', []).length, false)
      load_kind_families
      create_things
      validate_reference_contracts!
      validate_numeric_contracts!
      apply_start_facts
      startup_settlement = settle_if_rules(cause: 'START')
      @startup_if_rules = startup_settlement.fetch('rules')
      @startup_if_error = startup_settlement['error']
      @startup_ran = @startup_if_rules.flat_map { |entry| entry.fetch('steps').map { |step| step.fetch('word') } }
    end

    def run_event(text)
      event_text = normalize(text)
      match = find_event_match(event_text)
      return result(event_text, false, [], {}, match && match['error']) unless match && match['rule']

      rule = match.fetch('rule')
      context = match.fetch('context')
      actor = reference_name(rule.dig('when', 'actor'), context: context)
      selections = []
      action_result = run_action_list(rule.fetch('then', []), actor: actor, context: context, selections: selections)
      steps = action_result.fetch('steps')
      if_settlement = if action_result['error']
                        { 'rules' => [], 'error' => nil }
                      else
                        settle_if_rules(cause: 'event')
                      end

      result(
        event_text,
        true,
        steps.map { |step| step.fetch('word') },
        context,
        action_result['error'] || if_settlement['error'],
        matched_when: normalize(rule.dig('when', 'raw')),
        understood: context_explanations(rule, context),
        steps: steps,
        selections: selections,
        if_rules: if_settlement.fetch('rules')
      )
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
      lines << "starting IF error: #{startup_if_error}" if startup_if_error

      unless event_result.fetch('steps', []).empty?
        lines << 'what happened:'
        append_steps_report(lines, event_result.fetch('steps'), indent: '  ')
      end

      unless event_result.fetch('if_rules', []).empty?
        lines << 'IF rules:'
        append_if_rule_report(lines, event_result.fetch('if_rules'))
      end

      lines << 'world state:'
      snapshot.each { |thing| lines << "  #{format_thing(thing)}" }
      lines.join("\n")
    end

    private


    def validate_ir!
      format = normalize(@ir['format'])
      unless format == 'dkir.debug.json'
        shown = @ir['format'] || '(missing)'
        raise ArgumentError, "DKIR format '#{shown}' is not supported"
      end

      %w[kinds objects facts events if_rules diagnostics].each do |name|
        value = @ir[name]
        raise ArgumentError, "DKIR '#{name}' must be a list" unless value.is_a?(Array)
      end

      raise ArgumentError, 'DKIR contains errors and cannot run' if ir_errors.any?
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
        rule.fetch('then', []).each { |word| validate_action_reference!(word) }
      end

      @ir.fetch('if_rules', []).each do |rule|
        condition = rule.fetch('if')
        validate_reference!(condition['subject'], location: :condition)
        validate_reference!(condition['target'], location: :condition) if condition['target']
        rule.fetch('then', []).each { |word| validate_action_reference!(word) }
      end
    end

    def validate_action_reference!(word)
      reference = word['target']
      return unless reference

      validate_reference!(reference, location: :action)

      type = normalize(reference['type'])
      return unless %w[kind_one kind].include?(type)

      kind = normalize(reference['kind_name'] || reference['text']).sub(/\Aa\s+/, '')
      raise ArgumentError,
            "BASIC# cannot choose one #{kind} here.\n\nName the #{kind}, use 'that #{kind}' after selecting one in WHEN,\nor use 'every #{kind}' for all #{kind} Things."
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
        raise ArgumentError, "'every #{kind}' can be used as an action target after <then>.\n\nWHEN still describes one event Thing."
      when :start
        raise ArgumentError, "'every #{kind}' can be used as an action target after <then>.\n\nSTART still describes one Thing at a time."
      when :condition
        raise ArgumentError, "'every #{kind}' is not yet supported inside an IF condition.\n\nBASIC# would need to know whether you mean every #{kind} or any #{kind}."
      end
    end

    def validate_numeric_contracts!
      starting_values = {}

      @ir.fetch('facts', []).each_with_index do |fact, index|
        next unless normalize(fact['relation']) == 'has'

        value_name = validate_value_name_field!(fact, 'value_name', "START value entry #{index + 1}")
        amount = validate_whole_number_field!(fact, 'amount', minimum: 0, label: "START #{value_name} amount")
        subject_name = reference_name(fact['subject'])
        next unless subject_name

        key = [subject_name, value_name]
        if starting_values.key?(key)
          raise ArgumentError, "#{subject_name} already has a starting #{value_name} value.
Choose one starting amount."
        end
        starting_values[key] = amount
      end

      @ir.fetch('events', []).each do |rule|
        rule.fetch('then', []).each { |word| validate_numeric_action!(word) }
      end

      @ir.fetch('if_rules', []).each do |rule|
        condition = rule.fetch('if')
        if normalize(condition['relation']) == 'has'
          value_name = validate_value_name_field!(condition, 'value_name', 'IF value condition')
          validate_whole_number_field!(condition, 'amount', minimum: 0, label: "IF #{value_name} amount")
        end
        rule.fetch('then', []).each { |word| validate_numeric_action!(word) }
      end
    end

    def validate_numeric_action!(word)
      action = normalize(word['action'])
      if action == 'damage'
        return unless word.key?('amount')

        validate_whole_number_field!(word, 'amount', minimum: 1, label: 'Damage amount')
        return
      end

      return unless action == 'change'

      numeric_shape = word.key?('value_name') || word.key?('to_amount')
      return unless numeric_shape

      value_name = validate_value_name_field!(word, 'value_name', 'Value change')
      validate_whole_number_field!(word, 'to_amount', minimum: 0, label: "New #{value_name} amount")
      raise ArgumentError, 'Value change cannot also contain a state target' if word.key?('to')
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

    def reference_location_name(location)
      {
        start: 'START',
        event: 'WHEN',
        condition: 'IF',
        action: 'Action target'
      }.fetch(location, 'DKIR')
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
        raise ArgumentError, "DKIR has more than one Thing named '#{name}'" if @objects.key?(name)

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
          amount = fact['amount']
          subject.fetch('values')[value_name] = amount
          subject['damage'] = amount if value_name == 'damage'
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
      return { 'rules' => [], 'error' => nil } if rules.empty?

      fired = []
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
            return { 'rules' => fired, 'error' => if_loop_error(condition_trail) }
          end

          seen ||= { if_world_signature => true }
          @if_active[index] = true
          selections = []
          action_result = run_action_list(rule.fetch('then', []), actor: nil, context: {}, selections: selections)
          steps = action_result.fetch('steps')
          condition = normalize(rule.dig('if', 'raw'))
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
          fired_indexes.add(index)
          condition_trail << condition
          condition_trail.shift while condition_trail.length > 3
          fired_this_pass = true

          return { 'rules' => fired, 'error' => action_result['error'] } if action_result['error']

          rearm_false_if_rules!
          signature = if_world_signature
          if seen.key?(signature)
            return { 'rules' => fired, 'error' => if_loop_error(condition_trail) }
          end
          seen[signature] = true
        end

        break unless fired_this_pass
      end

      { 'rules' => fired, 'error' => nil }
    end

    def run_action_list(words, actor:, context:, selections: [])
      steps = []
      error = nil

      words.each do |word|
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

        targets.each do |target|
          step = run_official_word(word, target: target, actor: actor)
          steps << step if step
        end
      end

      { 'steps' => steps, 'error' => error }
    end

    def display_action_for_selection(word, text)
      action = normalize(word['action'])
      if action == 'damage'
        amount = word.fetch('amount', 1)
        return amount == 1 ? "(damage #{text}" : "(damage #{text} by #{amount}"
      end
      if action == 'change' && word['value_name']
        return "(change #{normalize(word['value_name'])} of #{text} to #{word['to_amount']}"
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
        return subject.fetch('values')[value_name] == condition['amount']
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
        reference = word['target']
        next unless normalize(reference && reference['type']) == 'previous'

        kind = normalize(reference['kind_name'])
        name = context[kind]
        explanations << "#{normalize(reference['text'])} means #{name}" if name
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
          old_amount = target.fetch('values').fetch(value_name)
          new_amount = word.fetch('to_amount')
          target.fetch('values')[value_name] = new_amount
          target['damage'] = new_amount if value_name == 'damage'
          return {
            'word' => "(change #{value_name} of #{target_name} to #{new_amount}",
            'change' => "#{target_name} #{value_name} changed from #{old_amount} to #{new_amount}",
            'value_change' => {
              'value_name' => value_name,
              'old_amount' => old_amount,
              'new_amount' => new_amount
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

    def result(event_text, matched, ran, context, error, matched_when: nil, understood: [], steps: [], selections: [], if_rules: [])
      {
        'event' => event_text,
        'matched' => matched,
        'matched_when' => matched_when,
        'understood' => understood,
        'ran' => ran,
        'steps' => steps,
        'selections' => selections,
        'if_rules' => if_rules,
        'context' => context,
        'error' => error,
        'state' => snapshot
      }
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

        details << "#{value_name}=#{amount}"
      end
      thing.fetch('relations').each { |relation, target| details << "#{relation}=#{target}" }
      "#{thing.fetch('name')}: #{details.join('; ')}"
    end

    def normalize(value)
      value.to_s.strip.downcase.gsub(/\s+/, ' ')
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

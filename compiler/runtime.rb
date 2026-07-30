# frozen_string_literal: true

require 'json'
require 'set'
require_relative 'ast_nodes'

module DKScript
  class Runtime
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

    attr_reader :startup_ran

    def self.load(path)
      new(JSON.parse(File.read(path)))
    end

    def initialize(document)
      @ir = stringify_keys(document.respond_to?(:to_h) ? document.to_h : document)
      validate_ir!

      @objects = {}
      @object_order = []
      @startup_ran = []
      create_things
      apply_start_facts
      run_starting_if_rules
    end

    def run_event(text)
      event_text = normalize(text)
      match = find_event_match(event_text)
      return result(event_text, false, [], {}, match && match['error']) unless match && match['rule']

      rule = match.fetch('rule')
      context = match.fetch('context')
      actor = reference_name(rule.dig('when', 'actor'), context: context)
      steps = rule.fetch('then', []).filter_map do |word|
        changes = []
        description = run_official_word(word, actor: actor, context: context, changes: changes)
        next unless description

        {
          'word' => description,
          'change' => changes.first
        }
      end

      result(
        event_text,
        true,
        steps.map { |step| step.fetch('word') },
        context,
        nil,
        matched_when: normalize(rule.dig('when', 'raw')),
        understood: context_explanations(rule, context),
        steps: steps
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
          'relations' => thing.fetch('relations').sort.to_h
        }
        entry['damage'] = thing.fetch('damage') if thing.fetch('damage').positive?
        entry
      end
    end

    def report(event_result)
      lines = []
      lines << "DKScript Runtime v#{VERSION}"
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

      unless startup_ran.empty?
        lines << 'starting rules:'
        startup_ran.each { |word| lines << "  #{word}" }
      end

      unless event_result.fetch('steps', []).empty?
        lines << 'what happened:'
        event_result.fetch('steps').each do |step|
          lines << "  #{step.fetch('word')}"
          lines << "  #{step.fetch('change')}" if step['change']
        end
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

      %w[objects facts events if_rules diagnostics].each do |name|
        value = @ir[name]
        raise ArgumentError, "DKIR '#{name}' must be a list" unless value.is_a?(Array)
      end

      raise ArgumentError, 'DKIR contains errors and cannot run' if ir_errors.any?
    end

    def ir_errors
      @ir.fetch('diagnostics', []).select { |diagnostic| diagnostic['severity'] == 'error' }
    end

    def create_things
      @ir.fetch('objects', []).each do |object|
        name = normalize(object.fetch('name'))
        raise ArgumentError, "DKIR has more than one Thing named '#{name}'" if @objects.key?(name)

        @object_order << name
        @objects[name] = {
          'name' => name,
          'kind' => normalize(object.fetch('kind')),
          'builtin' => object.fetch('builtin', false),
          'states' => Set.new,
          'relations' => {},
          'damage' => 0
        }
      end
    end

    def apply_start_facts
      @ir.fetch('facts', []).each do |fact|
        subject = thing_for_reference(fact['subject'])
        next unless subject

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

    def run_starting_if_rules
      @ir.fetch('if_rules', []).each do |rule|
        next unless condition_true?(rule['if'])

        rule.fetch('then', []).each do |word|
          description = run_official_word(word, actor: nil, context: {}, changes: nil)
          startup_ran << description if description
        end
      end
    end

    def condition_true?(condition)
      subject = thing_for_reference(condition['subject'])
      return false unless subject

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
      @ir.fetch('events', []).each do |rule|
        attempt = match_event_rule(rule, event_text)
        return attempt if attempt['rule']

        best_error ||= attempt['error'] if attempt['same_event_shape']
      end

      { 'rule' => nil, 'context' => {}, 'error' => best_error }
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
      { 'rule' => rule, 'context' => context, 'error' => nil, 'same_event_shape' => true }
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
      return { 'matched' => supplied_text.empty?, 'context_kind' => nil, 'name' => nil, 'error' => nil } unless reference

      type = normalize(reference['type'])
      supplied = normalize(supplied_text)

      case type
      when 'object'
        expected = normalize(reference['name'] || reference['text'])
        return { 'matched' => supplied == expected, 'context_kind' => nil, 'name' => expected, 'error' => nil }
      when 'kind_one', 'kind'
        match_kind_reference(reference, supplied)
      else
        expected = normalize(reference['name'] || reference['text'])
        { 'matched' => supplied == expected, 'context_kind' => nil, 'name' => expected, 'error' => nil }
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
      unless actual_kind == kind
        return {
          'matched' => false,
          'context_kind' => kind,
          'name' => supplied,
          'error' => "#{supplied} is a #{actual_kind}, not a #{kind}"
        }
      end

      { 'matched' => true, 'context_kind' => kind, 'name' => supplied, 'error' => nil }
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

    def run_official_word(word, actor:, context:, changes:)
      name = normalize(word['action'])
      target = thing_for_reference(word['target'], context: context)
      return nil unless target

      target_name = target.fetch('name')
      case name
      when 'damage'
        target['damage'] += 1
        changes << "#{target_name} damage is now #{target.fetch('damage')}" if changes
        "(damage #{target_name}"
      when 'change'
        state = word.dig('to', 'name') || word.dig('to', 'text')
        return nil unless state

        state_name = normalize(state)
        set_state(target, state_name)
        changes << "#{target_name} is now #{state_name}" if changes
        "(change #{target_name} to #{state_name}"
      when 'carry'
        carrier = actor || 'player'
        target.fetch('relations').delete('on')
        target.fetch('relations').delete('in')
        target.fetch('relations')['carried by'] = carrier
        changes << "#{target_name} is now carried by #{carrier}" if changes
        "(carry #{target_name}"
      when 'unlock'
        set_state(target, 'unlocked')
        changes << "#{target_name} is now unlocked" if changes
        "(unlock #{target_name}"
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

    def result(event_text, matched, ran, context, error, matched_when: nil, understood: [], steps: [])
      {
        'event' => event_text,
        'matched' => matched,
        'matched_when' => matched_when,
        'understood' => understood,
        'ran' => ran,
        'steps' => steps,
        'context' => context,
        'error' => error,
        'state' => snapshot
      }
    end

    def format_thing(thing)
      details = ["kind=#{thing.fetch('kind')}"]
      states = thing.fetch('states')
      details << "states=#{states.join(', ')}" unless states.empty?
      details << "damage=#{thing.fetch('damage')}" if thing.key?('damage')
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

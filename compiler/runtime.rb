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
      raise ArgumentError, 'DKIR contains errors and cannot run' if ir_errors.any?

      @objects = {}
      @object_order = []
      @startup_ran = []
      create_things
      apply_start_facts
      run_starting_if_rules
    end

    def run_event(text)
      event_text = normalize(text)
      rule = @ir.fetch('events', []).find { |candidate| normalize(candidate.dig('when', 'raw')) == event_text }

      return result(event_text, false, []) unless rule

      actor = reference_name(rule.dig('when', 'actor'))
      ran = rule.fetch('then', []).filter_map { |word| run_official_word(word, actor: actor) }
      result(event_text, true, ran)
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

      unless startup_ran.empty?
        lines << 'starting rules:'
        startup_ran.each { |word| lines << "  #{word}" }
      end

      unless event_result.fetch('ran').empty?
        lines << 'event words:'
        event_result.fetch('ran').each { |word| lines << "  #{word}" }
      end

      lines << 'world state:'
      snapshot.each { |thing| lines << "  #{format_thing(thing)}" }
      lines.join("\n")
    end

    private

    def ir_errors
      @ir.fetch('diagnostics', []).select { |diagnostic| diagnostic['severity'] == 'error' }
    end

    def create_things
      @ir.fetch('objects', []).each do |object|
        name = normalize(object.fetch('name'))
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
          description = run_official_word(word, actor: nil)
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

    def run_official_word(word, actor:)
      name = normalize(word['action'])
      target = thing_for_reference(word['target'])
      return nil unless target

      case name
      when 'damage'
        target['damage'] += 1
        "(damage #{target.fetch('name')}"
      when 'change'
        state = word.dig('to', 'name') || word.dig('to', 'text')
        return nil unless state

        set_state(target, state)
        "(change #{target.fetch('name')} to #{normalize(state)}"
      when 'carry'
        target.fetch('relations').delete('on')
        target.fetch('relations').delete('in')
        target.fetch('relations')['carried by'] = actor || 'player'
        "(carry #{target.fetch('name')}"
      when 'unlock'
        set_state(target, 'unlocked')
        "(unlock #{target.fetch('name')}"
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

    def thing_for_reference(reference)
      name = reference_name(reference)
      name ? @objects[name] : nil
    end

    def reference_name(reference)
      return nil unless reference.is_a?(Hash)

      normalize(reference['name'] || reference['text'])
    end

    def result(event_text, matched, ran)
      {
        'event' => event_text,
        'matched' => matched,
        'ran' => ran,
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

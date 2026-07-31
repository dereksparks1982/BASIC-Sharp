# frozen_string_literal: true

require 'set'
require_relative 'diagnostics'
require_relative 'dictionary'
require_relative 'basic_sharp_ir'

module BasicSharp
  class SemanticResolver
    RELATIONAL_FACT_PREFIXES = %w[in on].freeze
    MAX_WHOLE_NUMBER = 2_147_483_647
    VALUE_NAME_PATTERN = /\A[a-z][a-z0-9]*\z/

    attr_reader :program, :dictionary, :diagnostics

    def initialize(program, dictionary:)
      @program = program
      @dictionary = dictionary
      @diagnostics = DiagnosticBag.new
      @starting_value_assignments = Set.new
    end

    def resolve
      kinds = resolve_kinds
      objects = resolve_objects
      facts = program.facts.map { |fact| resolve_fact(fact) }
      events = program.event_rules.map { |rule| resolve_event_rule(rule) }
      if_rules = program.if_rules.map { |rule| resolve_if_rule(rule) }

      IR::Document.new(
        version: VERSION,
        kinds: kinds,
        objects: objects,
        facts: facts,
        events: events,
        if_rules: if_rules,
        diagnostics: clean_diagnostics(program.diagnostics + diagnostics.items)
      )
    end

    private

    def clean_diagnostics(items)
      seen = {}
      items.each_with_object([]) do |diagnostic, clean|
        key = [diagnostic.severity, diagnostic.line_number, diagnostic.message]
        next if seen[key]

        seen[key] = true
        clean << diagnostic
      end.sort_by do |diagnostic|
        [diagnostic.line_number || 0, diagnostic.severity == 'error' ? 0 : 1, diagnostic.message]
      end
    end

    def resolve_kinds
      program.kind_definitions.map do |kind|
        {
          'name' => normalize_name(kind.name),
          'parent' => normalize_name(kind.parent),
          'line_number' => kind.line_number
        }
      end
    end

    def resolve_objects
      objects = [{ 'name' => 'player', 'kind' => 'person', 'builtin' => true, 'line_number' => nil }]
      seen = { 'player' => true }

      program.definitions.each do |definition|
        normalized_name = normalize_name(definition.name)
        if seen[normalized_name]
          diagnostics.error(definition.line_number, "duplicate object '#{normalized_name}'")
          next
        end

        diagnostics.error(definition.line_number, "unknown kind '#{definition.kind}'") unless dictionary.known_kind?(definition.kind)
        seen[normalized_name] = true
        objects << {
          'name' => normalized_name,
          'kind' => normalize_name(definition.kind),
          'builtin' => false,
          'line_number' => definition.line_number
        }
      end

      objects
    end

    def resolve_fact(fact)
      if normalize_name(fact.relation) == 'has'
        subject = resolve_reference(fact.subject, fact.line_number, usage: :start)
        amount, value_name = resolve_amount_and_value_name(fact.value, fact.line_number)
        remember_starting_value(subject, value_name, fact.line_number) if value_name
        return {
          'line_number' => fact.line_number,
          'subject' => subject,
          'relation' => 'has',
          'value_name' => value_name,
          'amount' => amount,
          'raw' => fact.to_h
        }
      end

      value = normalize_name(fact.value)
      if (match = value.match(/\A(#{RELATIONAL_FACT_PREFIXES.join('|')})\s+(.+)\z/))
        relation = match[1]
        target_text = match[2]
        return {
          'line_number' => fact.line_number,
          'subject' => resolve_reference(fact.subject, fact.line_number, usage: :start),
          'relation' => relation,
          'target' => resolve_reference(target_text, fact.line_number, usage: :start),
          'raw' => fact.to_h
        }
      end

      {
        'line_number' => fact.line_number,
        'subject' => resolve_reference(fact.subject, fact.line_number, usage: :start),
        'relation' => fact.relation,
        'value' => resolve_state_or_phrase(value, fact.line_number),
        'raw' => fact.to_h
      }
    end

    def remember_starting_value(subject, value_name, line_number)
      return unless subject.is_a?(Hash) && normalize_name(subject['type']) == 'object'

      thing_name = normalize_name(subject['name'])
      key = [thing_name, value_name]
      if @starting_value_assignments.include?(key)
        diagnostics.error(
          line_number,
          "#{thing_name} already has a starting #{value_name} value.\nChoose one starting amount."
        )
      else
        @starting_value_assignments.add(key)
      end
    end

    def resolve_event_rule(rule)
      when_event = resolve_event(rule.event, rule.line_number)
      bound_kinds = event_bound_kinds(when_event)
      {
        'line_number' => rule.line_number,
        'when' => when_event,
        'then' => rule.actions.map { |action| resolve_action(action, bound_kinds: bound_kinds) }
      }
    end

    def resolve_if_rule(rule)
      condition_fact = parse_condition_fact(rule.condition, rule.line_number)
      {
        'line_number' => rule.line_number,
        'if' => condition_fact,
        'then' => rule.actions.map { |action| resolve_action(action, bound_kinds: []) }
      }
    end

    def resolve_event(text, line_number, usage: :event)
      words = normalize_name(text).split
      verb_index = words.each_index.find do |index|
        index.positive? && dictionary.known_event_action?(normalize_verb(words[index]))
      end

      unless verb_index
        diagnostics.error(line_number, "event does not contain a known event word: '#{text}'")
        return { 'raw' => normalize_name(text), 'actor' => nil, 'action' => nil, 'target' => nil }
      end

      actor_text = words[0...verb_index].join(' ')
      action = normalize_verb(words[verb_index])
      target_text = words[(verb_index + 1)..]&.join(' ') || ''

      {
        'raw' => normalize_name(text),
        'actor' => resolve_reference(actor_text, line_number, usage: usage),
        'action' => action,
        'target' => target_text.empty? ? nil : resolve_reference(target_text, line_number, usage: usage)
      }
    end

    def resolve_action(action, bound_kinds:)
      verb = normalize_verb(action.verb)
      diagnostics.error(action.line_number, "unknown official word '(#{action.verb}'") unless dictionary.known_action?(action.verb)

      return resolve_damage_action(action, verb) if verb == 'damage'
      return resolve_change_action(action, verb) if verb == 'change'
      return resolve_cause_action(action, bound_kinds: bound_kinds) if verb == 'cause'

      resolved = {
        'line_number' => action.line_number,
        'action' => verb,
        'target' => action.target.to_s.empty? ? nil : resolve_reference(action.target, action.line_number, usage: :action_target)
      }

      if (match = action.tail.to_s.match(/\Ato\s+(.+)\z/))
        resolved['to'] = resolve_state_or_phrase(match[1], action.line_number)
      elsif (match = action.tail.to_s.match(/\Aby\s+(.+)\z/))
        diagnostics.error(action.line_number, "Only (damage uses 'by an amount' in this build")
        resolved['tail'] = action.tail
      elsif !action.tail.to_s.empty?
        resolved['tail'] = action.tail
      end

      resolved
    end

    def resolve_cause_action(action, bound_kinds:)
      event_text = normalize_name(action.target)
      if event_text.empty?
        diagnostics.error(action.line_number, "Cause must name an event, such as '(cause henry attacks player'")
        return {
          'line_number' => action.line_number,
          'action' => 'cause',
          'event' => { 'raw' => '', 'actor' => nil, 'action' => nil, 'target' => nil }
        }
      end

      event = resolve_event(event_text, action.line_number, usage: nil)
      validate_caused_event_references(event, bound_kinds, action.line_number)
      {
        'line_number' => action.line_number,
        'action' => 'cause',
        'event' => event
      }
    end

    def event_bound_kinds(event)
      [event['actor'], event['target']].compact.filter_map do |reference|
        type = normalize_name(reference['type'])
        normalize_name(reference['kind_name']) if %w[kind_one kind].include?(type)
      end.uniq
    end

    def validate_caused_event_references(event, bound_kinds, line_number)
      [event['actor'], event['target']].compact.each do |reference|
        type = normalize_name(reference['type'])
        kind = normalize_name(reference['kind_name'])
        text = normalize_name(reference['text'])

        case type
        when 'previous'
          next if bound_kinds.include?(kind)

          diagnostics.error(
            line_number,
            "'#{text}' has no selected #{kind} here.
Use it inside a WHEN that selected one #{kind}, or name the Thing."
          )
        when 'kind_set'
          diagnostics.error(
            line_number,
            "'#{text}' cannot be used inside (cause yet.
Cause one event with a named Thing or 'that #{kind}'."
          )
        when 'kind_one', 'kind'
          diagnostics.error(
            line_number,
            "BASIC# cannot choose one #{kind} for this caused event.
Name the #{kind}, or use 'that #{kind}' after WHEN selected one."
          )
        end
      end
    end

    def resolve_damage_action(action, verb)
      amount = 1
      tail = normalize_name(action.tail)
      if (match = tail.match(/\Aby\s+(.+)\z/))
        amount = resolve_whole_number(match[1], action.line_number, minimum: 1, purpose: 'damage amount')
      elsif !tail.empty?
        diagnostics.error(action.line_number, "Damage must look like '(damage henry' or '(damage henry by 3'")
      end

      {
        'line_number' => action.line_number,
        'action' => verb,
        'target' => action.target.to_s.empty? ? nil : resolve_reference(action.target, action.line_number, usage: :action_target),
        'amount' => amount
      }
    end

    def resolve_change_action(action, verb)
      target_text = normalize_name(action.target)
      tail = normalize_name(action.tail)
      numeric_target = target_text.match(/\A([a-z][a-z0-9]*)\s+of\s+(.+)\z/)
      numeric_amount = tail.match(/\Ato\s+(.+)\z/)

      if numeric_target && numeric_amount
        value_name = resolve_value_name(numeric_target[1], action.line_number)
        to_amount = resolve_whole_number(numeric_amount[1], action.line_number, minimum: 0, purpose: 'exact value')
        return {
          'line_number' => action.line_number,
          'action' => verb,
          'value_name' => value_name,
          'target' => resolve_reference(numeric_target[2], action.line_number, usage: :action_target),
          'to_amount' => to_amount
        }
      end

      resolved = {
        'line_number' => action.line_number,
        'action' => verb,
        'target' => target_text.empty? ? nil : resolve_reference(target_text, action.line_number, usage: :action_target)
      }

      if numeric_target && !numeric_amount
        diagnostics.error(action.line_number, "Value change must look like '(change health of henry to 7'")
      elsif numeric_amount
        resolved['to'] = resolve_state_or_phrase(numeric_amount[1], action.line_number)
      elsif !tail.empty?
        resolved['tail'] = action.tail
      end

      resolved
    end

    def parse_condition_fact(text, line_number)
      normalized = normalize_name(text)
      if (has_match = normalized.match(/\A(.+?)\s+has\s+(.+)\z/))
        amount, value_name = resolve_amount_and_value_name(has_match[2], line_number)
        return {
          'raw' => normalized,
          'subject' => resolve_reference(has_match[1], line_number, usage: :condition),
          'relation' => 'has',
          'value_name' => value_name,
          'amount' => amount
        }
      end

      match = normalized.match(/\A(.+?)\s+(is|isnt)\s+(.+)\z/)
      unless match
        diagnostics.error(line_number, "condition must look like 'subject is state' or 'subject has 3 damage'")
        return { 'raw' => normalized, 'subject' => nil, 'relation' => nil, 'value' => nil }
      end

      subject = match[1]
      relation = match[2]
      value = match[3]
      if (target_match = value.match(/\A(#{RELATIONAL_FACT_PREFIXES.join('|')})\s+(.+)\z/))
        return {
          'raw' => normalized,
          'subject' => resolve_reference(subject, line_number, usage: :condition),
          'relation' => target_match[1],
          'target' => resolve_reference(target_match[2], line_number, usage: :condition)
        }
      end

      {
        'raw' => normalized,
        'subject' => resolve_reference(subject, line_number, usage: :condition),
        'relation' => relation,
        'value' => resolve_state_or_phrase(value, line_number)
      }
    end

    def resolve_amount_and_value_name(text, line_number)
      normalized = normalize_name(text)
      match = normalized.match(/\A(\S+)\s+(\S+)\z/)
      unless match
        diagnostics.error(line_number, "Value must look like '10 health' using digits and one value name")
        return [nil, nil]
      end

      amount = resolve_whole_number(match[1], line_number, minimum: 0, purpose: 'value')
      value_name = resolve_value_name(match[2], line_number)
      [amount, value_name]
    end

    def resolve_value_name(text, line_number)
      normalized = normalize_name(text)
      unless VALUE_NAME_PATTERN.match?(normalized)
        diagnostics.error(line_number, "Value name '#{normalized}' must be one plain word")
        return normalized
      end

      normalized
    end

    def resolve_whole_number(text, line_number, minimum:, purpose:)
      shown = text.to_s.strip
      normalized = normalize_name(shown)

      if normalized.start_with?('-')
        diagnostics.error(line_number, "#{purpose.capitalize} cannot be negative: #{shown}")
        return nil
      end
      if normalized.include?('.')
        diagnostics.error(line_number, "#{purpose.capitalize} must be a whole number, not a decimal: #{shown}")
        return nil
      end
      if normalized.include?(',')
        diagnostics.error(line_number, "#{purpose.capitalize} must use digits without commas: #{shown}")
        return nil
      end
      unless normalized.match?(/\A\d+\z/)
        diagnostics.error(line_number, "#{purpose.capitalize} must use digits, such as 3")
        return nil
      end

      amount = normalized.to_i
      if amount < minimum
        diagnostics.error(line_number, "#{purpose.capitalize} must be at least #{minimum}")
        return nil
      end
      if amount > MAX_WHOLE_NUMBER
        diagnostics.error(line_number, "#{purpose.capitalize} cannot be greater than #{MAX_WHOLE_NUMBER}")
        return nil
      end

      amount
    end

    def resolve_reference(text, line_number, usage: nil)
      original = normalize_name(text)
      return reference('empty', original) if original.empty?

      if original.start_with?('that ')
        kind = original.sub(/\Athat\s+/, '')
        diagnostics.error(line_number, "unknown kind '#{kind}'") unless dictionary.known_kind?(kind)
        return reference('previous', original, 'selector' => 'that', 'kind_name' => kind)
      end

      if original.start_with?('every ')
        kind = original.sub(/\Aevery\s+/, '')
        diagnostics.error(line_number, "unknown kind '#{kind}'") unless dictionary.known_kind?(kind)
        diagnose_kind_set_usage(original, line_number, usage)
        return reference('kind_set', original, 'selector' => 'every', 'kind_name' => kind, 'candidates' => dictionary.objects_by_kind(kind))
      end

      if original.start_with?('a ')
        kind = original.sub(/\Aa\s+/, '')
        diagnostics.error(line_number, "unknown kind '#{kind}'") unless dictionary.known_kind?(kind)
        diagnose_unbound_single_action(kind, line_number) if usage == :action_target
        return reference('kind_one', original, 'selector' => 'a', 'kind_name' => kind, 'candidates' => dictionary.objects_by_kind(kind))
      end

      if original.start_with?('the ')
        stripped = original.sub(/\Athe\s+/, '')
        return resolve_definite_reference(original, stripped, line_number)
      end

      return reference('object', original, 'name' => original, 'object_kind' => dictionary.object_kind(original)) if dictionary.known_object?(original)
      if dictionary.known_kind?(original)
        diagnose_unbound_single_action(original, line_number) if usage == :action_target
        return reference('kind', original, 'kind_name' => original, 'candidates' => dictionary.objects_by_kind(original))
      end

      diagnostics.error(line_number, "unknown reference '#{original}': not a defined object and not a known kind")
      reference('unknown', original)
    end

    def diagnose_kind_set_usage(original, line_number, usage)
      kind = original.sub(/\Aevery\s+/, '')
      case usage
      when :event
        diagnostics.error(
          line_number,
          "'#{original}' can be used as an action target after <then>.\n\nWHEN still describes one event Thing."
        )
      when :start
        diagnostics.error(
          line_number,
          "'#{original}' can be used as an action target after <then>.\n\nSTART still describes one Thing at a time."
        )
      when :condition
        diagnostics.error(
          line_number,
          "'#{original}' is not yet supported inside an IF condition.\n\nBASIC# would need to know whether you mean every #{kind} or any #{kind}."
        )
      end
    end

    def diagnose_unbound_single_action(kind, line_number)
      diagnostics.error(
        line_number,
        "BASIC# cannot choose one #{kind} here.\n\nName the #{kind}, use 'that #{kind}' after selecting one in WHEN,\nor use 'every #{kind}' for all #{kind} Things."
      )
    end

    def resolve_definite_reference(original, stripped, line_number)
      return reference('object', original, 'name' => stripped, 'object_kind' => dictionary.object_kind(stripped)) if dictionary.known_object?(stripped)

      if dictionary.known_kind?(stripped)
        candidates = dictionary.objects_by_kind(stripped)
        if candidates.length == 1
          return reference('object', original, 'name' => candidates.first, 'object_kind' => stripped, 'matched_by_kind' => true)
        elsif candidates.length > 1
          diagnostics.error(line_number, "which #{stripped}? found: #{candidates.join(', ')}")
          return reference('ambiguous', original, 'kind_name' => stripped, 'candidates' => candidates)
        end

        diagnostics.warning(line_number, "unresolved definite reference '#{original}': no #{stripped} object was defined")
        return reference('unresolved', original, 'selector' => 'the', 'kind_name' => stripped, 'candidates' => [], 'reason' => 'no_defined_object')
      end

      diagnostics.error(line_number, "unknown reference '#{original}': not a defined object and not a known kind")
      reference('unknown', original)
    end

    def resolve_state_or_phrase(value, line_number)
      normalized = normalize_name(value)
      return { 'kind' => 'state', 'name' => normalized } if dictionary.known_state?(normalized)
      return { 'kind' => 'phrase', 'text' => normalized } if normalized.include?(' ')

      diagnostics.error(line_number, "unknown state '#{normalized}'")
      { 'kind' => 'unknown', 'text' => normalized }
    end

    def reference(type, text, extra = {})
      { 'type' => type, 'text' => text }.merge(extra)
    end

    def normalize_name(value)
      value.to_s.strip.downcase.gsub(/\s+/, ' ')
    end

    def normalize_verb(value)
      raw = normalize_name(value).sub(/\A\(/, '')
      return raw if dictionary.known_action?(raw)

      singular = raw.sub(/s\z/, '')
      dictionary.known_action?(singular) ? singular : raw
    end
  end
end

# frozen_string_literal: true

require_relative 'diagnostics'
require_relative 'dictionary'
require_relative 'dks_ir'

module DKScript
  class SemanticResolver
    RELATIONAL_FACT_PREFIXES = %w[in on].freeze

    attr_reader :program, :dictionary, :diagnostics

    def initialize(program, dictionary:)
      @program = program
      @dictionary = dictionary
      @diagnostics = DiagnosticBag.new
    end

    def resolve
      IR::Document.new(
        version: VERSION,
        objects: resolve_objects,
        facts: program.facts.map { |fact| resolve_fact(fact) },
        events: program.event_rules.map { |rule| resolve_event_rule(rule) },
        if_rules: program.if_rules.map { |rule| resolve_if_rule(rule) },
        diagnostics: program.diagnostics + diagnostics.items
      )
    end

    private

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
      value = normalize_name(fact.value)
      if (match = value.match(/\A(#{RELATIONAL_FACT_PREFIXES.join('|')})\s+(.+)\z/))
        relation = match[1]
        target_text = match[2]
        return {
          'line_number' => fact.line_number,
          'subject' => resolve_reference(fact.subject, fact.line_number),
          'relation' => relation,
          'target' => resolve_reference(target_text, fact.line_number),
          'raw' => fact.to_h
        }
      end

      {
        'line_number' => fact.line_number,
        'subject' => resolve_reference(fact.subject, fact.line_number),
        'relation' => fact.relation,
        'value' => resolve_state_or_phrase(value, fact.line_number),
        'raw' => fact.to_h
      }
    end

    def resolve_event_rule(rule)
      {
        'line_number' => rule.line_number,
        'when' => resolve_event(rule.event, rule.line_number),
        'then' => rule.actions.map { |action| resolve_action(action) }
      }
    end

    def resolve_if_rule(rule)
      condition_fact = parse_condition_fact(rule.condition, rule.line_number)
      {
        'line_number' => rule.line_number,
        'if' => condition_fact,
        'then' => rule.actions.map { |action| resolve_action(action) }
      }
    end

    def resolve_event(text, line_number)
      words = normalize_name(text).split
      verb_index = words.each_index.find do |index|
        index.positive? && dictionary.known_action?(normalize_verb(words[index]))
      end

      unless verb_index
        diagnostics.error(line_number, "event does not contain a known action: '#{text}'")
        return { 'raw' => normalize_name(text), 'actor' => nil, 'action' => nil, 'target' => nil }
      end

      actor_text = words[0...verb_index].join(' ')
      action = normalize_verb(words[verb_index])
      target_text = words[(verb_index + 1)..]&.join(' ') || ''

      {
        'raw' => normalize_name(text),
        'actor' => resolve_reference(actor_text, line_number),
        'action' => action,
        'target' => target_text.empty? ? nil : resolve_reference(target_text, line_number)
      }
    end

    def resolve_action(action)
      diagnostics.error(action.line_number, "unknown action '#{action.verb}'") unless dictionary.known_action?(action.verb)

      resolved = {
        'line_number' => action.line_number,
        'action' => normalize_verb(action.verb),
        'target' => action.target.to_s.empty? ? nil : resolve_reference(action.target, action.line_number)
      }

      if (match = action.tail.to_s.match(/\Ato\s+(.+)\z/))
        resolved['to'] = resolve_state_or_phrase(match[1], action.line_number)
      elsif !action.tail.to_s.empty?
        resolved['tail'] = action.tail
      end

      resolved
    end

    def parse_condition_fact(text, line_number)
      match = normalize_name(text).match(/\A(.+?)\s+(is|isnt)\s+(.+)\z/)
      unless match
        diagnostics.error(line_number, "condition must look like 'subject is state'")
        return { 'raw' => normalize_name(text), 'subject' => nil, 'relation' => nil, 'value' => nil }
      end

      subject = match[1]
      relation = match[2]
      value = match[3]
      if (target_match = value.match(/\A(#{RELATIONAL_FACT_PREFIXES.join('|')})\s+(.+)\z/))
        return {
          'raw' => normalize_name(text),
          'subject' => resolve_reference(subject, line_number),
          'relation' => target_match[1],
          'target' => resolve_reference(target_match[2], line_number)
        }
      end

      {
        'raw' => normalize_name(text),
        'subject' => resolve_reference(subject, line_number),
        'relation' => relation,
        'value' => resolve_state_or_phrase(value, line_number)
      }
    end

    def resolve_reference(text, line_number)
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
        return reference('kind_set', original, 'selector' => 'every', 'kind_name' => kind, 'candidates' => dictionary.objects_by_kind(kind))
      end

      if original.start_with?('a ')
        kind = original.sub(/\Aa\s+/, '')
        diagnostics.error(line_number, "unknown kind '#{kind}'") unless dictionary.known_kind?(kind)
        return reference('kind_one', original, 'selector' => 'a', 'kind_name' => kind, 'candidates' => dictionary.objects_by_kind(kind))
      end

      if original.start_with?('the ')
        stripped = original.sub(/\Athe\s+/, '')
        return resolve_definite_reference(original, stripped, line_number)
      end

      return reference('object', original, 'name' => original, 'object_kind' => dictionary.object_kind(original)) if dictionary.known_object?(original)
      return reference('kind', original, 'kind_name' => original, 'candidates' => dictionary.objects_by_kind(original)) if dictionary.known_kind?(original)

      diagnostics.error(line_number, "unknown object or kind '#{original}'")
      reference('unknown', original)
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

        return reference('kind', original, 'kind_name' => stripped, 'candidates' => [])
      end

      diagnostics.error(line_number, "unknown object or kind '#{original}'")
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

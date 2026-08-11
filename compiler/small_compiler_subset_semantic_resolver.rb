# frozen_string_literal: true

require 'set'
require_relative 'diagnostics'
require_relative 'dictionary'
require_relative 'basic_sharp_ir'
require_relative 'text_literal'

module BasicSharp
  class SmallCompilerSubsetSemanticResolver
    RELATIONAL_FACT_PREFIXES = %w[in on].freeze
    MAX_WHOLE_NUMBER = 2_147_483_647
    VALUE_NAME_PATTERN = /\A[a-z][a-z0-9]*\z/

    attr_reader :program, :dictionary, :diagnostics

    def initialize(program, dictionary:)
      @program = program
      @dictionary = dictionary
      @diagnostics = DiagnosticBag.new
      @starting_value_assignments = Set.new
      @value_types = { 'damage' => 'whole_number' }
    end

    def resolve
      kinds = resolve_kinds
      objects = resolve_objects
      facts = program.facts.map { |fact| resolve_fact(fact) }
      events = program.event_rules.map { |rule| resolve_event_rule(rule) }
      if_rules = program.if_rules.map { |rule| resolve_if_rule(rule) }
      controls = program.controls.map { |entry| resolve_controls(entry) }
      hover_declarations = program.hover_declarations.map { |entry| resolve_hover(entry) }
      context_declarations = program.context_declarations.map { |entry| resolve_context(entry) }

      IR::Document.new(
        version: VERSION,
        meaning_profile: meaning_profile_for(facts, events, if_rules, controls, hover_declarations, context_declarations),
        kinds: kinds,
        objects: objects,
        facts: facts,
        events: events,
        if_rules: if_rules,
        controls: controls,
        hover_declarations: hover_declarations,
        context_declarations: context_declarations,
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
        if fact.value.is_a?(TextLiteral)
          value_name = resolve_value_name(fact.value_name, fact.line_number)
          diagnostics.error(fact.line_number, "damage is a whole-number value and cannot store text") if value_name == 'damage'
          remember_starting_value(subject, value_name, fact.line_number, 'text') if value_name
          return {
            'line_number' => fact.line_number,
            'subject' => subject,
            'relation' => 'has',
            'value_name' => value_name,
            'text_value' => fact.value.value,
            'raw' => canonical_fact_raw(fact)
          }
        end

        amount, value_name = resolve_amount_and_value_name(fact.value, fact.line_number)
        remember_starting_value(subject, value_name, fact.line_number, 'whole_number') if value_name
        return {
          'line_number' => fact.line_number,
          'subject' => subject,
          'relation' => 'has',
          'value_name' => value_name,
          'amount' => amount,
          'raw' => canonical_fact_raw(fact)
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
          'raw' => canonical_fact_raw(fact)
        }
      end

      {
        'line_number' => fact.line_number,
        'subject' => resolve_reference(fact.subject, fact.line_number, usage: :start),
        'relation' => fact.relation,
        'value' => resolve_state_or_phrase(value, fact.line_number),
        'raw' => canonical_fact_raw(fact)
      }
    end

    def remember_starting_value(subject, value_name, line_number, value_type)
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
        remember_value_type(value_name, value_type, line_number, 'Starting value')
      end
    end

    def resolve_event_rule(rule)
      when_event = resolve_event(rule.event, rule.line_number)
      bound_kinds = event_bound_kinds(when_event)
      established_objects = event_established_objects(when_event)
      {
        'line_number' => rule.line_number,
        'when' => when_event,
        'then' => rule.actions.map { |action| resolve_action(action, bound_kinds: bound_kinds, established_objects: established_objects) }
      }
    end

    def resolve_if_rule(rule)
      condition_fact = parse_if_condition(rule.condition, rule.line_number)
      result = {
        'line_number' => rule.line_number,
        'if' => condition_fact,
        'then' => rule.actions.map { |action| resolve_action(action, bound_kinds: []) }
      }
      if rule.otherwise_actions
        result['otherwise_line_number'] = rule.otherwise_line_number
        result['otherwise'] = rule.otherwise_actions.map { |action| resolve_action(action, bound_kinds: []) }
      end
      result
    end

    def parse_if_condition(text, line_number)
      clauses, connectors = split_if_condition(text)
      return parse_condition_fact(text, line_number) if connectors.empty?

      if connectors.uniq.length > 1
        diagnostics.error(line_number, "BASIC# does not mix and and or in one IF yet.\nUse separate IF rules so the meaning stays plain.")
      end
      if clauses.any? { |clause| clause.empty? }
        diagnostics.error(line_number, 'Every and or or in an IF must have a complete condition on both sides.')
      end
      connector = connectors.first
      resolved_clauses = clauses.map { |clause| parse_condition_fact(clause.empty? ? 'missing condition' : clause, line_number) }
      {
        'raw' => resolved_clauses.map { |clause| clause['raw'] }.join(" #{connector} "),
        'connector' => connector,
        'clauses' => resolved_clauses
      }
    end

    def split_if_condition(text)
      source = text.to_s.strip
      clauses = []
      connectors = []
      start = 0
      index = 0
      quoted = false
      while index < source.length
        if source[index] == '"'
          quoted = !quoted
          index += 1
          next
        end
        unless quoted
          remainder = source[index..]
          if (match = remainder.match(/\A(and|or)(?=\s|\z)/i)) && (index.zero? || source[index - 1].match?(/\s/))
            clauses << source[start...index].to_s.strip
            connectors << match[1].downcase
            index += match[1].length
            start = index
            next
          end
        end
        index += 1
      end
      clauses << source[start..].to_s.strip
      [clauses, connectors]
    end

    def resolve_controls(declaration)
      directions = {}
      world_directions = {}
      input_actions = {}
      keys = {}
      instruction_types = declaration.instructions.map { |entry| entry['type'] }
      world_used = instruction_types.include?('world_move')
      platform_jump_used = instruction_types.include?('platform_jump')
      platform_move_used = instruction_types.include?('platform_move')
      platform_used = platform_jump_used || (platform_move_used && !world_used)
      top_down_used = instruction_types.any? { |type| %w[key_move face_pointer right_mouse_move].include?(type) }

      if platform_used && top_down_used
        diagnostics.error(declaration.line_number, 'CONTROLS cannot mix platform movement with top-down movement in one declaration.')
      end
      if world_used && top_down_used
        diagnostics.error(declaration.line_number, '3D CONTROLS cannot mix forward movement with top-down movement in one declaration.')
      end
      if world_used && platform_jump_used
        diagnostics.error(declaration.line_number, '3D CONTROLS cannot declare platform jump movement.')
      end

      instructions = declaration.instructions.map do |instruction|
        resolved = instruction.dup
        resolved['type'] = 'world_move' if world_used && instruction['type'] == 'platform_move'
        type = resolved['type']
        if type == 'input_action'
          action = resolved['action']
          unless %w[jump attack interact pause].include?(action)
            diagnostics.error(resolved['line_number'], "Input action cannot use #{action}; use jump, attack, interact, or pause.")
          end
          if input_actions[action]
            diagnostics.error(resolved['line_number'], "PLAYER already has #{action} input action.")
          else
            input_actions[action] = true
          end
          next resolved
        end

        next resolved unless %w[platform_move platform_jump world_move].include?(type)

        key = resolved['key']
        if keys[key]
          message = type == 'world_move' ? "#{key} already has a 3D movement job in CONTROLS." : "#{key} already has a platform movement job in CONTROLS."
          diagnostics.error(resolved['line_number'], message)
        else
          keys[key] = true
        end

        case type
        when 'world_move'
          direction = resolved['direction']
          unless %w[forward backward left right].include?(direction)
            diagnostics.error(resolved['line_number'], "3D movement cannot use #{direction}; use forward, backward, left, or right.")
          end
          if world_directions[direction]
            diagnostics.error(resolved['line_number'], "PLAYER already has a #{direction} 3D movement control.")
          else
            world_directions[direction] = true
          end
          resolved['speed'] = resolve_whole_number(
            resolved['speed'], resolved['line_number'], minimum: 1, purpose: 'movement speed'
          )
        when 'platform_move'
          direction = resolved['direction']
          if directions[direction]
            diagnostics.error(resolved['line_number'], "PLAYER already has a #{direction} movement control.")
          else
            directions[direction] = true
          end
          resolved['speed'] = resolve_whole_number(
            resolved['speed'], resolved['line_number'], minimum: 1, purpose: 'movement speed'
          )
        when 'platform_jump'
          if directions['jump']
            diagnostics.error(resolved['line_number'], 'PLAYER already has a jump control.')
          else
            directions['jump'] = true
          end
          resolved['speed'] = resolve_whole_number(
            resolved['speed'], resolved['line_number'], minimum: 1, purpose: 'movement speed'
          )
        end
        resolved
      end

      if world_used
        %w[forward backward left right].each do |job|
          diagnostics.error(declaration.line_number, "3D CONTROLS must declare PLAYER #{job} movement.") unless world_directions[job]
        end
      elsif platform_used
        %w[left right jump].each do |job|
          diagnostics.error(declaration.line_number, "Platform CONTROLS must declare PLAYER #{job} movement.") unless directions[job]
        end
      end
      {
        'line_number' => declaration.line_number,
        'subject' => resolve_reference(declaration.subject, declaration.line_number, usage: :control),
        'instructions' => instructions
      }
    end

    def resolve_hover(declaration)
      {
        'line_number' => declaration.line_number,
        'subject' => resolve_declaration_subject(declaration.subject, declaration.line_number, 'HOVER'),
        'fields' => declaration.fields
      }
    end

    def resolve_context(declaration)
      {
        'line_number' => declaration.line_number,
        'subject' => resolve_declaration_subject(declaration.subject, declaration.line_number, 'CONTEXT'),
        'entries' => declaration.entries.map do |entry|
          {
            'line_number' => entry.line_number,
            'label' => entry.label,
            'condition' => resolve_context_condition(entry.condition, entry.line_number),
            'action' => resolve_action(entry.action, bound_kinds: [], context_it_allowed: true)
          }
        end
      }
    end

    def resolve_declaration_subject(text, line_number, label)
      raw = text.to_s.strip
      if raw.start_with?('#')
        kind = normalize_name(raw[1..])
        diagnostics.error(line_number, "#{label} uses unknown Kind '##{kind}'") unless dictionary.known_kind?(kind)
        return reference('kind_declaration', raw, 'kind_name' => kind)
      end
      if raw.start_with?('@')
        name = normalize_name(raw[1..])
        diagnostics.error(line_number, "#{label} uses unknown object '@#{name}'") unless dictionary.known_object?(name)
        return reference('object', raw, 'name' => name, 'object_kind' => dictionary.object_kind(name))
      end
      diagnostics.error(line_number, "#{label} must target a #Kind or @particular object")
      reference('unknown', raw)
    end

    def resolve_context_condition(text, line_number)
      return nil if text.nil? || text.empty?
      if (match = text.match(/\Ait\s+(is|isnt)\s+(.+)\z/i))
        return {
          'subject' => reference('context_it', 'it'),
          'relation' => match[1].downcase,
          'value' => resolve_state_or_phrase(match[2], line_number)
        }
      end
      diagnostics.error(line_number, "Context condition must look like 'it is closed'")
      { 'subject' => reference('context_it', 'it'), 'relation' => nil, 'value' => nil }
    end

    def resolve_event(text, line_number, usage: :event, bound_kinds: [], established_objects: [], context_it_allowed: false)
      words = text.to_s.strip.split
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

      actor = resolve_reference(actor_text, line_number, usage: usage, bound_kinds: bound_kinds, established_objects: established_objects, context_it_allowed: context_it_allowed)
      target = target_text.empty? ? nil : resolve_reference(target_text, line_number, usage: usage, bound_kinds: bound_kinds, established_objects: established_objects, context_it_allowed: context_it_allowed)
      raw = semantic_text(text)
      raw = raw.sub(/\Ait\b/, actor['text']) if normalize_name(actor_text) == 'it' && actor['type'] == 'previous'
      raw = raw.sub(/\bit\z/, target['text']) if normalize_name(target_text) == 'it' && target && target['type'] == 'previous'
      {
        'raw' => raw,
        'actor' => actor,
        'action' => action,
        'target' => target
      }
    end

    def resolve_action(action, bound_kinds:, established_objects: [], context_it_allowed: false)
      verb = normalize_verb(action.verb)
      diagnostics.error(action.line_number, "unknown official word '(#{action.verb}'") unless dictionary.known_action?(action.verb)

      return resolve_damage_action(action, verb, bound_kinds: bound_kinds, established_objects: established_objects, context_it_allowed: context_it_allowed) if verb == 'damage'
      return resolve_change_action(action, verb, bound_kinds: bound_kinds, established_objects: established_objects, context_it_allowed: context_it_allowed) if verb == 'change'
      return resolve_number_change_action(action, verb, bound_kinds: bound_kinds, established_objects: established_objects, context_it_allowed: context_it_allowed) if %w[increase decrease].include?(verb)
      return resolve_cause_action(
        action,
        bound_kinds: bound_kinds,
        established_objects: established_objects,
        context_it_allowed: context_it_allowed
      ) if verb == 'cause'
      return resolve_object_interaction_action(
        action,
        verb,
        bound_kinds: bound_kinds,
        established_objects: established_objects,
        context_it_allowed: context_it_allowed
      ) if %w[open close lock take].include?(verb)

      resolved = {
        'line_number' => action.line_number,
        'action' => verb,
        'target' => action.target.to_s.empty? ? nil : resolve_reference(
          action.target,
          action.line_number,
          usage: :action_target,
          bound_kinds: bound_kinds,
          established_objects: established_objects,
          context_it_allowed: context_it_allowed
        )
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

    def resolve_object_interaction_action(action, verb, bound_kinds:, established_objects:, context_it_allowed:)
      target_text = action.target.to_s.strip
      if target_text.empty?
        diagnostics.error(action.line_number, "(#{verb} must name what to #{verb}.")
      end
      unless action.tail.to_s.empty?
        diagnostics.error(action.line_number, "(#{verb} takes one target and no extra words in this build.")
      end

      target = target_text.empty? ? nil : resolve_reference(
        target_text,
        action.line_number,
        usage: :action_target,
        bound_kinds: bound_kinds,
        established_objects: established_objects,
        context_it_allowed: context_it_allowed
      )

      case verb
      when 'take'
        {
          'line_number' => action.line_number,
          'action' => 'carry',
          'target' => target
        }
      when 'open', 'close', 'lock'
        state = { 'open' => 'open', 'close' => 'closed', 'lock' => 'locked' }.fetch(verb)
        {
          'line_number' => action.line_number,
          'action' => 'change',
          'target' => target,
          'to' => resolve_state_or_phrase(state, action.line_number)
        }
      end
    end

    def resolve_cause_action(action, bound_kinds:, established_objects: [], context_it_allowed: false)
      event_text = action.target.to_s.strip
      if event_text.empty?
        diagnostics.error(action.line_number, "Cause must name an event, such as '(cause henry attacks player'")
        return {
          'line_number' => action.line_number,
          'action' => 'cause',
          'event' => { 'raw' => '', 'actor' => nil, 'action' => nil, 'target' => nil }
        }
      end

      event = resolve_event(
        event_text,
        action.line_number,
        usage: nil,
        bound_kinds: bound_kinds,
        established_objects: established_objects,
        context_it_allowed: context_it_allowed
      )
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

    def event_established_objects(event)
      [event['actor'], event['target']].compact.filter_map do |reference|
        name = normalize_name(reference['name']) if normalize_name(reference['type']) == 'object'
        name unless name.nil? || name == 'player'
      end.uniq
    end

    def validate_caused_event_references(event, bound_kinds, line_number)
      [event['actor'], event['target']].compact.each do |reference|
        type = normalize_name(reference['type'])
        kind = normalize_name(reference['kind_name'])
        text = normalize_name(reference['text'])

        case type
        when 'context_it'
          next
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

    def resolve_damage_action(action, verb, bound_kinds:, established_objects:, context_it_allowed:)
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
        'target' => action.target.to_s.empty? ? nil : resolve_reference(
          action.target,
          action.line_number,
          usage: :action_target,
          bound_kinds: bound_kinds,
          established_objects: established_objects,
          context_it_allowed: context_it_allowed
        ),
        'amount' => amount
      }
    end

    def resolve_change_action(action, verb, bound_kinds:, established_objects:, context_it_allowed:)
      target_text = action.target.to_s.strip
      tail = normalize_name(action.tail)
      numeric_target = target_text.match(/\A([a-z][a-z0-9]*)\s+of\s+(.+)\z/i)
      numeric_amount = tail.match(/\Ato\s+(.+)\z/)

      if action.text_literal
        unless numeric_target
          diagnostics.error(action.line_number, "Text value change must look like '(change title of north gate to \"Open\"'")
          return {
            'line_number' => action.line_number,
            'action' => verb,
            'value_name' => nil,
            'target' => resolve_reference(target_text, action.line_number, usage: :action_target, bound_kinds: bound_kinds, established_objects: established_objects, context_it_allowed: context_it_allowed),
            'to_text' => action.text_literal.value
          }
        end

        value_name = resolve_value_name(numeric_target[1], action.line_number)
        target = resolve_reference(numeric_target[2], action.line_number, usage: :action_target, bound_kinds: bound_kinds, established_objects: established_objects, context_it_allowed: context_it_allowed)
        validate_known_value_type(target, value_name, 'text', action.line_number, 'Text value change')
        return {
          'line_number' => action.line_number,
          'action' => verb,
          'value_name' => value_name,
          'target' => target,
          'to_text' => action.text_literal.value
        }
      end

      if numeric_target && numeric_amount
        value_name = resolve_value_name(numeric_target[1], action.line_number)
        to_amount = resolve_whole_number(numeric_amount[1], action.line_number, minimum: 0, purpose: 'exact value')
        target = resolve_reference(numeric_target[2], action.line_number, usage: :action_target, bound_kinds: bound_kinds, established_objects: established_objects, context_it_allowed: context_it_allowed)
        validate_known_value_type(target, value_name, 'whole_number', action.line_number, 'Whole-number value change')
        return {
          'line_number' => action.line_number,
          'action' => verb,
          'value_name' => value_name,
          'target' => target,
          'to_amount' => to_amount
        }
      end

      resolved = {
        'line_number' => action.line_number,
        'action' => verb,
        'target' => target_text.empty? ? nil : resolve_reference(target_text, action.line_number, usage: :action_target, bound_kinds: bound_kinds, established_objects: established_objects, context_it_allowed: context_it_allowed)
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

    def resolve_number_change_action(action, verb, bound_kinds:, established_objects:, context_it_allowed:)
      target_text = action.target.to_s.strip
      tail = normalize_name(action.tail)
      value_target = target_text.match(/\A([a-z][a-z0-9]*)\s+of\s+(.+)\z/i)
      amount_match = tail.match(/\Aby\s+(.+)\z/)

      unless value_target && amount_match
        diagnostics.error(
          action.line_number,
          "Number change must look like '(#{verb} health of PLAYER by 3'"
        )
      end

      value_name = resolve_value_name(value_target ? value_target[1] : '', action.line_number)
      target_source = value_target ? value_target[2] : target_text
      target = resolve_reference(
        target_source,
        action.line_number,
        usage: :action_target,
        bound_kinds: bound_kinds,
        established_objects: established_objects,
        context_it_allowed: context_it_allowed
      )
      amount = resolve_whole_number(
        amount_match ? amount_match[1] : '', action.line_number,
        minimum: 1, purpose: "#{verb} amount"
      )
      validate_known_value_type(target, value_name, 'whole_number', action.line_number, "#{verb.capitalize} value")

      {
        'line_number' => action.line_number,
        'action' => verb,
        'value_name' => value_name,
        'target' => target,
        'amount' => amount
      }
    end

    def parse_condition_fact(text, line_number)
      supplied = text.to_s.strip
      if (text_match = supplied.match(/\A(.+?)\s+has\s+(.+)\z/i)) && TextLiteral.quote_present?(text_match[2])
        begin
          literal, value_name_text = TextLiteral.parse_assignment(text_match[2].strip)
          value_name = resolve_value_name(value_name_text, line_number)
          subject = resolve_reference(text_match[1], line_number, usage: :condition)
          validate_known_value_type(subject, value_name, 'text', line_number, 'IF text comparison')
          return {
            'raw' => "#{semantic_text(text_match[1])} has #{literal.quoted} #{value_name}",
            'subject' => subject,
            'relation' => 'has',
            'value_name' => value_name,
            'text_value' => literal.value
          }
        rescue TextLiteralError => error
          diagnostics.error(line_number, error.message)
        end
      end

      normalized = semantic_text(supplied)
      if (has_match = supplied.match(/\A(.+?)\s+has\s+(.+)\z/i))
        comparison, amount_text = parse_number_comparison(has_match[2])
        amount, value_name = resolve_amount_and_value_name(amount_text, line_number)
        subject = resolve_reference(has_match[1], line_number, usage: :condition)
        validate_known_value_type(subject, value_name, 'whole_number', line_number, 'IF whole-number comparison')
        result = {
          'raw' => semantic_text(supplied),
          'subject' => subject,
          'relation' => 'has',
          'value_name' => value_name,
          'amount' => amount
        }
        result['comparison'] = comparison unless comparison == 'equals'
        return result
      end

      match = supplied.match(/\A(.+?)\s+(is|isnt)\s+(.+)\z/i)
      unless match
        diagnostics.error(line_number, "condition must look like 'subject is state' or 'subject has 3 damage'")
        return { 'raw' => normalized, 'subject' => nil, 'relation' => nil, 'value' => nil }
      end

      subject = match[1]
      relation = match[2].downcase
      value = match[3]
      if (target_match = value.match(/\A(#{RELATIONAL_FACT_PREFIXES.join('|')})\s+(.+)\z/))
        return {
          'raw' => semantic_text(supplied),
          'subject' => resolve_reference(subject, line_number, usage: :condition),
          'relation' => target_match[1],
          'target' => resolve_reference(target_match[2], line_number, usage: :condition)
        }
      end

      {
        'raw' => semantic_text(supplied),
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

    def parse_number_comparison(text)
      normalized = normalize_name(text)
      prefixes = {
        'at least ' => 'at_least',
        'more than ' => 'more_than',
        'at most ' => 'at_most',
        'less than ' => 'less_than'
      }
      prefix, comparison = prefixes.find { |shown, _kind| normalized.start_with?(shown) }
      return ['equals', normalized] unless prefix

      [comparison, normalized.delete_prefix(prefix)]
    end

    def resolve_value_name(text, line_number)
      normalized = normalize_name(text)
      unless VALUE_NAME_PATTERN.match?(normalized)
        diagnostics.error(line_number, "Value name '#{normalized}' must be one plain word")
        return normalized
      end

      normalized
    end

    def validate_known_value_type(reference, value_name, expected_type, line_number, label)
      return if value_name.nil?

      remember_value_type(value_name, expected_type, line_number, label)
    end

    def remember_value_type(value_name, expected_type, line_number, label)
      actual = @value_types[value_name]
      if actual.nil?
        @value_types[value_name] = expected_type
        return
      end
      return if actual == expected_type

      diagnostics.error(
        line_number,
        "#{label} cannot use #{value_name} because that value is #{actual == 'text' ? 'text' : 'a whole number'}."
      )
    end

    def meaning_profile_for(facts, events, if_rules, controls, hover_declarations, context_declarations)
      return 'bsharp.meaning.v7' if if_rules.any? { |rule| rule.key?('otherwise') }

      compound_conditions_used = if_rules.any? { |rule| rule.fetch('if', {}).key?('connector') }
      return 'bsharp.meaning.v6' if compound_conditions_used

      number_changes_used = events.any? do |event|
        event.fetch('then', []).any? { |action| %w[increase decrease].include?(action['action']) }
      end || if_rules.any? do |rule|
        condition_clauses(rule.fetch('if', {})).any? { |condition| condition.key?('comparison') } ||
          rule.fetch('then', []).any? { |action| %w[increase decrease].include?(action['action']) }
      end
      return 'bsharp.meaning.v5' if number_changes_used

      movement_used = controls.any? do |declaration|
        declaration.fetch('instructions', []).any? do |instruction|
          instruction['type'].to_s.start_with?('platform_') || instruction['type'].to_s == 'world_move'
        end
      end
      return 'bsharp.meaning.v4' if movement_used

      game_used = !controls.empty? || !hover_declarations.empty? || !context_declarations.empty?
      return 'bsharp.meaning.v3' if game_used

      text_used = facts.any? { |fact| fact.key?('text_value') } ||
                  events.any? { |event| event.fetch('then', []).any? { |action| action.key?('to_text') } } ||
                  if_rules.any? do |rule|
                    condition_clauses(rule.fetch('if', {})).any? { |condition| condition.key?('text_value') } ||
                      rule.fetch('then', []).any? { |action| action.key?('to_text') }
                  end
      text_used ? 'bsharp.meaning.v2' : 'bsharp.meaning.v1'
    end

    def condition_clauses(condition)
      condition.key?('connector') ? Array(condition['clauses']) : [condition]
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

    def resolve_reference(text, line_number, usage: nil, bound_kinds: [], established_objects: [], context_it_allowed: false)
      shown = text.to_s.strip
      original = normalize_name(shown)
      return reference('empty', original) if original.empty?

      if shown == 'PLAYER'
        return reference('object', 'player', 'name' => 'player', 'object_kind' => 'person')
      elsif original == 'player'
        diagnostics.error(line_number, 'The built-in human-controlled character must be written as PLAYER')
        return reference('object', 'player', 'name' => 'player', 'object_kind' => 'person')
      end

      if original == 'it'
        if context_it_allowed
          return reference('context_it', 'it')
        end
        if established_objects.length == 1
          name = established_objects.first
          return reference('object', 'it', 'name' => name, 'object_kind' => dictionary.object_kind(name))
        end
        if bound_kinds.length == 1
          return reference('previous', "that #{bound_kinds.first}", 'selector' => 'that', 'kind_name' => bound_kinds.first)
        end
        diagnostics.error(
          line_number,
          bound_kinds.empty? ?
            "'it' has no single object established in this scene. Name the @object." :
            "'it' could mean more than one object here. Name the intended @object."
        )
        return reference('unknown', 'it')
      end

      if original.start_with?('that ')
        diagnostics.error(line_number, "The retired 'that #Kind' form no longer works. Use it after one object is established.")
        kind = normalize_name(original.sub(/\Athat\s+#?/, ''))
        return reference('previous', 'it', 'selector' => 'it', 'kind_name' => kind)
      end

      if (match = shown.match(/\Aevery\s+#(.+)\z/i))
        kind = normalize_name(match[1])
        diagnostics.error(line_number, "unknown Kind '##{kind}'") unless dictionary.known_kind?(kind)
        diagnose_kind_set_usage("every #{kind}", line_number, usage)
        return reference('kind_set', "every #{kind}", 'selector' => 'every', 'kind_name' => kind, 'candidates' => dictionary.objects_by_kind(kind))
      end

      if (match = shown.match(/\Aa[n]?\s+#(.+)\z/i))
        kind = normalize_name(match[1])
        diagnostics.error(line_number, "unknown Kind '##{kind}'") unless dictionary.known_kind?(kind)
        diagnose_unbound_single_action(kind, line_number) if usage == :action_target
        return reference('kind_one', "a #{kind}", 'selector' => 'a', 'kind_name' => kind, 'candidates' => dictionary.objects_by_kind(kind))
      end

      if (match = shown.match(/\Athe\s+#(.+)\z/i))
        kind = normalize_name(match[1])
        return resolve_definite_reference("the #{kind}", kind, line_number)
      end

      if shown.start_with?('@')
        name = normalize_name(shown[1..])
        unless dictionary.known_object?(name)
          diagnostics.error(line_number, "unknown object '@#{name}'")
          return reference('unknown', name)
        end
        return reference('object', name, 'name' => name, 'object_kind' => dictionary.object_kind(name))
      end

      if shown.start_with?('#')
        kind = normalize_name(shown[1..])
        diagnostics.error(line_number, "unknown Kind '##{kind}'") unless dictionary.known_kind?(kind)
        diagnose_unbound_single_action(kind, line_number) if usage == :action_target
        return reference('kind', kind, 'kind_name' => kind, 'candidates' => dictionary.objects_by_kind(kind))
      end

      if dictionary.known_object?(original)
        diagnostics.error(line_number, "Particular object '#{original}' must be written as @#{original}")
        return reference('object', original, 'name' => original, 'object_kind' => dictionary.object_kind(original))
      end
      if dictionary.known_kind?(original) || original.match?(/\A(?:a|an|the|every)\s+/)
        diagnostics.error(line_number, "Kind reference '#{original}' must mark the Kind with #")
        stripped = original.sub(/\A(?:a|an|the|every)\s+/, '')
        return reference('kind', original, 'kind_name' => stripped, 'candidates' => dictionary.objects_by_kind(stripped))
      end

      diagnostics.error(line_number, "unknown reference '#{original}': not a defined @object and not a known #Kind")
      reference('unknown', original)
    end

    def diagnose_kind_set_usage(original, line_number, usage)
      kind = original.sub(/\Aevery\s+/, '')
      case usage
      when :event
        diagnostics.error(
          line_number,
          "'#{original}' can be used as an action target after |then.\n\nWHEN still describes one event Thing."
        )
      when :start
        diagnostics.error(
          line_number,
          "'#{original}' can be used as an action target after |then.\n\nSTART still describes one Thing at a time."
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

    def semantic_text(value)
      value.to_s.gsub(/@(?=[A-Za-z])/, '').gsub(/#(?=[A-Za-z])/, '').gsub(/\bPLAYER\b/, 'player').strip.downcase.gsub(/\s+/, ' ')
    end

    def canonical_fact_raw(fact)
      result = {
        subject: semantic_text(fact.subject),
        relation: fact.relation,
        value: fact.value.respond_to?(:to_h) ? fact.value.to_h : semantic_text(fact.value),
        line_number: fact.line_number
      }
      result[:value_name] = fact.value_name if fact.value_name
      result
    end

    def normalize_verb(value)
      raw = normalize_name(value).sub(/\A\(/, '')
      return raw if dictionary.known_action?(raw)

      singular = raw.sub(/s\z/, '')
      dictionary.known_action?(singular) ? singular : raw
    end
  end
end

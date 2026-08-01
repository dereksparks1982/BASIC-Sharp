# frozen_string_literal: true

require 'json'
require_relative 'ast_nodes'

module BasicSharp
  class AskError < ArgumentError; end

  class Ask
    FORMAT = 'bsharp.ask.json'
    FORMAT_VERSION = 1
    MAX_QUESTIONS = 256
    HUMAN_LIST_LIMIT = 50

    SUPPORTED_QUESTIONS = [
      'what is henry',
      'what Kind is henry',
      'what Things are guards',
      'what happens when player attacks henry',
      'what IF rules are true',
      'what game systems are declared',
      'what is the world',
      'what is the save'
    ].freeze

    def initialize(runtime)
      @runtime = runtime
    end

    def answer_many(questions)
      unless questions.is_a?(Array) && !questions.empty?
        raise AskError, 'BASIC# ASK needs at least one question.'
      end
      if questions.length > MAX_QUESTIONS
        raise AskError, "BASIC# ASK accepts at most #{MAX_QUESTIONS} questions per command."
      end

      questions.map { |question| answer(question) }
    end

    def document(answers)
      {
        'format' => FORMAT,
        'format_version' => FORMAT_VERSION,
        'created_by_basic_sharp' => VERSION,
        'answers' => answers
      }
    end

    def to_json(answers)
      "#{JSON.pretty_generate(document(answers))}\n"
    end

    def report(answers)
      answers.map { |entry| report_answer(entry) }.join("\n\n")
    end

    private

    def answer(question)
      original = question.to_s.strip
      normalized = normalize(original)
      raise AskError, unsupported_question_message if normalized.empty?

      payload =
        case normalized
        when 'what if rules are true'
          answer_true_if_rules
        when 'what is the world'
          answer_world
        when 'what is the save'
          answer_save
        when 'what game systems are declared'
          declarations = @runtime.game_declarations
          { 'type' => 'game_declarations', 'answer' => declarations.merge(
            'control_count' => declarations.fetch('controls').length,
            'hover_count' => declarations.fetch('hover').length,
            'context_count' => declarations.fetch('context').length
          ) }
        else
          parse_named_question(normalized)
        end

      {
        'question' => original,
        'type' => payload.fetch('type'),
        'ok' => true,
        'answer' => payload.fetch('answer')
      }
    end

    def parse_named_question(question)
      if (match = question.match(/\Awhat happens when\s+(.+)\z/))
        return answer_event(match[1])
      end
      if (match = question.match(/\Awhat kind is\s+(.+)\z/))
        return answer_thing_part(match[1], 'kind')
      end
      if (match = question.match(/\Awhat states does\s+(.+?)\s+have\z/))
        return answer_thing_part(match[1], 'states')
      end
      if (match = question.match(/\Awhat values does\s+(.+?)\s+have\z/))
        return answer_thing_part(match[1], 'values')
      end
      if (match = question.match(/\Awhat relationships does\s+(.+?)\s+have\z/))
        return answer_thing_part(match[1], 'relationships')
      end
      if (match = question.match(/\Awhat things are\s+(.+)\z/))
        return answer_kind_membership(match[1])
      end
      if (match = question.match(/\Awhat is thing\s+(.+)\z/))
        return answer_thing(match[1], explicit: true)
      end
      if (match = question.match(/\Awhat is kind\s+(.+)\z/))
        return answer_kind(match[1], explicit: true)
      end
      if (match = question.match(/\Awhat is\s+(.+)\z/))
        return answer_named(match[1])
      end

      raise AskError, unsupported_question_message
    end

    def answer_named(name)
      canonical = normalize(name)
      thing = @runtime.ask_thing(canonical)
      kind = @runtime.ask_kind(canonical)

      if thing && kind
        raise AskError, [
          "'#{canonical}' names both a Thing and a Kind.",
          '',
          'Ask:',
          "  what is Thing #{canonical}",
          'or:',
          "  what is Kind #{canonical}"
        ].join("\n")
      end

      return thing_payload(thing) if thing
      return kind_payload(kind) if kind

      raise AskError, unknown_name_message(canonical)
    end

    def answer_thing(name, explicit: false)
      canonical = normalize(name)
      thing = @runtime.ask_thing(canonical)
      raise AskError, unknown_thing_message(canonical) unless thing

      thing_payload(thing)
    end

    def answer_kind(name, explicit: false)
      canonical = @runtime.ask_resolve_kind(name)
      raise AskError, unknown_kind_message(normalize(name)) unless canonical

      kind_payload(@runtime.ask_kind(canonical))
    end

    def answer_thing_part(name, part)
      canonical = normalize(name)
      thing = @runtime.ask_thing(canonical)
      raise AskError, unknown_thing_message(canonical) unless thing

      answer = { 'name' => thing.fetch('name') }
      case part
      when 'kind'
        answer['kind'] = thing.fetch('kind')
      when 'states'
        answer['states'] = thing.fetch('states')
      when 'values'
        answer['values'] = thing.fetch('values')
      when 'relationships'
        answer['relationships'] = thing.fetch('relations')
      end
      { 'type' => "thing_#{part}", 'answer' => answer }
    end

    def answer_kind_membership(name)
      canonical = @runtime.ask_resolve_kind(name)
      raise AskError, unknown_kind_message(normalize(name)) unless canonical

      members = @runtime.ask_kind_members(canonical)
      {
        'type' => 'kind_membership',
        'answer' => {
          'kind' => canonical,
          'things' => members,
          'count' => members.length
        }
      }
    end

    def answer_event(event_text)
      event = normalize(event_text)
      inspection = @runtime.ask_event_match(event)
      {
        'type' => 'event_match',
        'answer' => inspection.merge('event' => event)
      }
    end

    def answer_true_if_rules
      rules = @runtime.ask_if_rules
      true_rules = rules.select { |rule| rule.fetch('true') }
      {
        'type' => 'if_rules_true',
        'answer' => {
          'rules' => true_rules,
          'true_count' => true_rules.length,
          'total_count' => rules.length
        }
      }
    end

    def answer_world
      { 'type' => 'world', 'answer' => @runtime.ask_world_summary }
    end

    def answer_save
      { 'type' => 'save', 'answer' => @runtime.ask_save_summary }
    end

    def thing_payload(thing)
      { 'type' => 'thing', 'answer' => thing }
    end

    def kind_payload(kind)
      { 'type' => 'kind', 'answer' => kind }
    end

    def report_answer(entry)
      question = entry.fetch('question')
      answer = entry.fetch('answer')
      lines = ["ASK: #{question}", '']

      case entry.fetch('type')
      when 'thing'
        append_thing(lines, answer)
      when 'kind'
        append_kind(lines, answer)
      when 'thing_kind'
        lines << "#{answer.fetch('name')} is a #{answer.fetch('kind')}."
      when 'thing_states'
        append_named_list(lines, "#{answer.fetch('name')} currently has these states:", answer.fetch('states'))
      when 'thing_values'
        append_named_hash(lines, "#{answer.fetch('name')} currently has these values:", answer.fetch('values'))
      when 'thing_relationships'
        append_named_hash(lines, "#{answer.fetch('name')} currently has these relationships:", answer.fetch('relationships'))
      when 'kind_membership'
        append_kind_membership(lines, answer)
      when 'event_match'
        append_event_match(lines, answer)
      when 'if_rules_true'
        append_if_rules(lines, answer)
      when 'world'
        append_world(lines, answer)
      when 'save'
        append_save(lines, answer)
      when 'game_declarations'
        lines << "CONTROLS declarations: #{answer.fetch('control_count')}"
        lines << "HOVER declarations: #{answer.fetch('hover_count')}"
        lines << "CONTEXT declarations: #{answer.fetch('context_count')}"
      else
        raise AskError, unsupported_question_message
      end

      lines.join("\n").rstrip
    end

    def append_thing(lines, thing)
      lines << "#{thing.fetch('name')} is a #{thing.fetch('kind')}."
      lines << ''
      append_named_list(lines, 'current states:', thing.fetch('states'))
      lines << ''
      append_named_hash(lines, 'current values:', thing.fetch('values'))
      lines << ''
      append_named_hash(lines, 'current relationships:', thing.fetch('relations'))
    end

    def append_kind(lines, kind)
      lines << "#{kind.fetch('name')} is a Kind."
      lines << ''
      parent = kind['parent']
      lines << "parent Kind: #{parent || 'none'}"
      lines << "current Things: #{kind.fetch('thing_count')}"
    end

    def append_kind_membership(lines, answer)
      kind = answer.fetch('kind')
      members = answer.fetch('things')
      lines << "#{kind} currently includes:"
      if members.empty?
        lines << '  none'
      else
        shown, remaining = bounded(members)
        shown.each do |member|
          suffix = member.fetch('inherited') ? ", through #{member.fetch('kind')}" : ''
          lines << "  #{member.fetch('name')}#{suffix}"
        end
        lines << "  ...and #{remaining} more Things." if remaining.positive?
        lines << '  Use --ask-json for the complete result.' if remaining.positive?
      end
      lines << ''
      lines << "#{answer.fetch('count')} Things found."
    end

    def append_event_match(lines, answer)
      unless answer.fetch('matched')
        lines << 'BASIC# would not choose a WHEN rule.'
        lines << "reason: #{answer.fetch('error')}" if answer['error']
        lines << ''
        lines << 'ASK did not run this event or change the world.'
        return
      end

      lines << 'BASIC# would choose:'
      lines << ''
      lines << "  #{answer.fetch('matched_when')}"
      unless answer.fetch('understood').empty?
        lines << ''
        lines << 'what it understands:'
        answer.fetch('understood').each { |line| lines << "  #{line}" }
      end
      lines << ''
      lines << 'actions:'
      answer.fetch('actions').each { |action| lines << "  #{action}" }
      lines << ''
      lines << 'ASK did not run this event or change the world.'
    end

    def append_if_rules(lines, answer)
      rules = answer.fetch('rules')
      if rules.empty?
        lines << 'No IF rules are currently true.'
      else
        shown, remaining = bounded(rules)
        shown.each_with_index do |rule, display_index|
          lines << "IF rule #{rule.fetch('index') + 1}:"
          lines << "  #{rule.fetch('condition')}"
          lines << '  currently true'
          lines << "  active: #{rule.fetch('active') ? 'yes' : 'no'}"
          lines << '' unless display_index == shown.length - 1 && remaining.zero?
        end
        if remaining.positive?
          lines << "...and #{remaining} more IF rules."
          lines << 'Use --ask-json for the complete result.'
        end
      end
      lines << ''
      lines << "#{answer.fetch('true_count')} of #{answer.fetch('total_count')} IF rules are currently true."
    end

    def append_world(lines, answer)
      lines << "origin: #{answer.fetch('origin')}"
      lines << "settled: #{answer.fetch('settled') ? 'yes' : 'no'}"
      lines << "Things: #{answer.fetch('things')}"
      lines << "Kinds used: #{answer.fetch('kinds_used')}"
      lines << "true IF rules: #{answer.fetch('true_if_rules')} of #{answer.fetch('if_rules')}"
      lines << "whole-number values: #{answer.fetch('whole_number_values')}"
      lines << "text values: #{answer.fetch('text_values')}" if answer.key?('text_values')
    end

    def append_save(lines, answer)
      unless answer.fetch('loaded')
        lines << 'No BSharp Save is loaded.'
        lines << 'This world was built from START.'
        return
      end

      lines << 'format: BSharp Save'
      lines << "format version: #{answer.fetch('format_version')}"
      lines << "settled: #{answer.fetch('settled') ? 'yes' : 'no'}"
      lines << "Things: #{answer.fetch('things')}"
      lines << 'program fingerprint: matched'
    end

    def append_named_list(lines, heading, entries)
      lines << heading
      if entries.empty?
        lines << '  none'
      else
        entries.each { |entry| lines << "  #{entry}" }
      end
    end

    def append_named_hash(lines, heading, entries)
      lines << heading
      if entries.empty?
        lines << '  none'
      else
        entries.each do |key, value|
          shown = value.is_a?(String) ? %Q{"#{value}"} : value
          lines << "  #{key}: #{shown}"
        end
      end
    end

    def bounded(entries)
      shown = entries.first(HUMAN_LIST_LIMIT)
      [shown, entries.length - shown.length]
    end

    def unknown_name_message(name)
      "BASIC# ASK does not know a Thing or Kind named '#{name}'."
    end

    def unknown_thing_message(name)
      "BASIC# ASK does not know a Thing named '#{name}'."
    end

    def unknown_kind_message(name)
      "BASIC# ASK does not know a Kind named '#{name}'."
    end

    def unsupported_question_message
      [
        'BASIC# ASK does not understand that question yet.',
        '',
        'Supported questions include:',
        *SUPPORTED_QUESTIONS.map { |question| "  #{question}" }
      ].join("\n")
    end

    def normalize(value)
      value.to_s.strip.downcase.gsub(/\s+/, ' ')
    end
  end
end

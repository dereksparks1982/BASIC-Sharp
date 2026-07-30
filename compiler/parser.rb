# frozen_string_literal: true

require_relative 'ast_nodes'
require_relative 'diagnostics'
require_relative 'dictionary'
require_relative 'lexer'

module DKScript
  class Parser
    STATEMENT_STARTERS = %w[START DEFINE WORLD STATES RELATIONS ACTIONS WHEN IF WHILE OTHERWISE].freeze
    LINE_COMMAND_ALIASES = { 'than' => 'then', 'then' => 'then' }.freeze

    attr_reader :dictionary, :diagnostics

    def initialize(source, dictionary: CoreDictionary.new)
      @source = source
      @dictionary = dictionary
      @diagnostics = DiagnosticBag.new
    end

    def parse
      statements = parse_statements
      definitions = []
      facts = []
      event_rules = []
      if_rules = []

      statements.each do |statement|
        case statement.starter
        when 'DEFINE'
          definitions.concat(parse_definitions(statement))
        when 'START'
          facts.concat(parse_start_facts(statement))
        when 'WHEN'
          rule = parse_when(statement)
          event_rules << rule if rule
        when 'IF'
          rule = parse_if(statement)
          if_rules << rule if rule
        end
      end

      Program.new(
        statements: statements,
        definitions: definitions,
        facts: facts,
        event_rules: event_rules,
        if_rules: if_rules,
        diagnostics: diagnostics.items
      )
    end

    private

    def parse_statements
      lexer = Lexer.new(@source)
      current = nil
      statements = []

      lexer.lines.each do |line|
        text = line.text

        if STATEMENT_STARTERS.include?(text)
          current = Statement.new(starter: text, children: [], line_number: line.number)
          statements << current
          next
        end

        unless current
          diagnostics.error(line.number, 'expected a statement starter before child lines')
          next
        end

        unless text.start_with?('<')
          diagnostics.error(line.number, 'child lines must start with <')
          next
        end

        current.children << parse_child_line(line)
      end

      statements.each do |statement|
        if statement.children.empty? && statement.starter != 'OTHERWISE'
          diagnostics.warning(statement.line_number, "#{statement.starter} has no child lines")
        end
      end

      statements
    end

    def parse_child_line(line)
      terminal = line.text.end_with?('.')
      body = line.text[1..]&.strip || ''
      body = body[0...-1].strip if terminal

      line_command = nil
      action = nil

      # A child line starts with '<'. A command line such as '<then> (damage henry'
      # is therefore parsed after the child marker as 'then> (damage henry'.
      if (match = body.match(/\A([a-z]+)>\s*(.*)\z/))
        raw_command = match[1].strip.downcase
        body = match[2].strip
        line_command = LINE_COMMAND_ALIASES[raw_command]
        unless line_command
          diagnostics.error(line.number, "unknown line command '<#{raw_command}>'; did you mean <then>?")
          # Recover as <then> when the rest of the line is clearly an action.
          # This avoids a second, confusing "missing <then>" cascade error.
          line_command = body.start_with?('(') ? 'then' : raw_command
        end
      elsif body.start_with?('<')
        diagnostics.error(line.number, 'line command tags must look like <then>')
      end

      if body.start_with?('(')
        match = body.match(/\A\((\w+)\b\s*(.*)\z/)
        if match
          action = match[1].downcase
        else
          diagnostics.error(line.number, 'action markers must look like (damage target')
        end
      end

      ChildLine.new(raw: line.text, body: body, line_command: line_command, action: action, line_number: line.number, terminal: terminal)
    end

    def parse_definitions(statement)
      statement.children.filter_map do |child|
        match = child.body.match(/\Aa\s+(\w+)\s+named\s+(.+)\z/)
        unless match
          diagnostics.error(child.line_number, "DEFINE child must look like 'a door named north door'")
          next
        end

        kind = match[1].downcase
        name = match[2].strip.downcase
        dictionary.add_object(name, kind)
        Definition.new(kind: kind, name: name, line_number: child.line_number)
      end
    end

    def parse_start_facts(statement)
      statement.children.filter_map do |child|
        parse_fact(child)
      end
    end

    def parse_fact(child)
      text = child.body
      match = text.match(/\A(.+?)\s+(is|isnt)\s+(.+)\z/)
      unless match
        diagnostics.error(child.line_number, "fact must look like 'subject is state'")
        return nil
      end

      subject = match[1].strip.downcase
      relation = match[2].downcase
      value = match[3].strip.downcase
      Fact.new(subject: subject, relation: relation, value: value, line_number: child.line_number)
    end

    def parse_when(statement)
      event_line = statement.children.find { |child| child.line_command.nil? }
      action_lines = statement.children.select { |child| child.line_command == 'then' }
      diagnostics.error(statement.line_number, 'WHEN needs one event child line') unless event_line
      diagnostics.error(statement.line_number, 'WHEN needs at least one <then> action line') if action_lines.empty?
      return nil unless event_line

      EventRule.new(event: event_line.body, actions: action_lines.map { |child| parse_action(child) }.compact, line_number: statement.line_number)
    end

    def parse_if(statement)
      condition_line = statement.children.find { |child| child.line_command.nil? }
      action_lines = statement.children.select { |child| child.line_command == 'then' }
      diagnostics.error(statement.line_number, 'IF needs one condition child line') unless condition_line
      diagnostics.error(statement.line_number, 'IF needs at least one <then> action line') if action_lines.empty?
      return nil unless condition_line

      parse_fact(condition_line)
      IfRule.new(condition: condition_line.body, actions: action_lines.map { |child| parse_action(child) }.compact, line_number: statement.line_number)
    end

    def parse_action(child)
      text = child.body
      match = text.match(/\A\((\w+)\b\s*(.*)\z/)
      unless match
        diagnostics.error(child.line_number, 'action lines should start with an action marker, such as (damage henry')
        return nil
      end

      verb = match[1].downcase
      rest = match[2].strip.downcase
      target, tail = split_action_rest(rest)
      ActionCall.new(verb: verb, target: target, tail: tail, line_number: child.line_number)
    end

    def split_action_rest(rest)
      return ['', ''] if rest.empty?
      if rest.include?(' to ')
        target, tail = rest.split(' to ', 2)
        [target.strip, "to #{tail.strip}"]
      else
        [rest.strip, '']
      end
    end

  end
end

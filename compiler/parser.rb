# frozen_string_literal: true

require_relative 'ast_nodes'
require_relative 'diagnostics'
require_relative 'dictionary'
require_relative 'lexer'
require_relative 'text_literal'

module BasicSharp
  class Parser
    # Profile 1 Head identities are language semantics; documentation-only builds do not alter them.
    STATEMENT_STARTERS = %w[KINDS DEFINE START WHEN IF].freeze
    DORMANT_HEADS = %w[WORLD STATES RELATIONS ACTIONS WHILE OTHERWISE].freeze
    RESULT_ALIASES = { 'than' => 'then', 'then' => 'then' }.freeze

    attr_reader :dictionary, :diagnostics

    def initialize(source, dictionary: CoreDictionary.new)
      @source = source
      @dictionary = dictionary
      @diagnostics = DiagnosticBag.new
    end

    def parse
      statements = parse_statements
      kind_definitions = parse_kind_definitions(statements)
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
        kind_definitions: kind_definitions,
        definitions: definitions,
        facts: facts,
        event_rules: event_rules,
        if_rules: if_rules,
        diagnostics: diagnostics.items
      )
    end

    private

    def parse_statements
      lines = Lexer.new(@source).lines
      statements = []
      current = nil
      body_open = false

      lines.each do |line|
        text = line.text

        if STATEMENT_STARTERS.include?(text) || DORMANT_HEADS.include?(text)
          if current && body_open
            diagnostics.error(current.line_number, "#{current.starter} Body is missing its End ].")
          end
          if DORMANT_HEADS.include?(text)
            diagnostics.error(line.number, unsupported_head_message(text))
          end
          current = Statement.new(starter: text, children: [], line_number: line.number)
          statements << current
          body_open = false
          next
        end

        unless current
          diagnostics.error(line.number, 'expected a Head before the Body')
          next
        end

        unless body_open
          unless text.start_with?('[')
            if text.start_with?('<')
              diagnostics.error(line.number, 'old child-line structure no longer works; start the Body with [')
            else
              diagnostics.error(line.number, "#{current.starter} Body must start with [")
            end
            next
          end
          body_open = true
          text = text[1..].to_s.strip
        end

        terminal = text.end_with?('].')
        if terminal
          text = text[0...-2].strip
          body_open = false
        elsif text.end_with?(']')
          diagnostics.error(line.number, 'End must be ].')
          text = text[0...-1].strip
          body_open = false
        end

        current.children << parse_body_item(line, text, terminal: terminal) unless text.empty?
        current = nil unless body_open
      end

      if current && body_open
        diagnostics.error(current.line_number, "#{current.starter} Body is missing its End ].")
      end

      statements.each do |statement|
        if statement.children.empty? && statement.starter != 'OTHERWISE'
          diagnostics.warning(statement.line_number, "#{statement.starter} Body is empty")
        end
      end

      statements
    end


    def unsupported_head_message(head)
      [
        "BASIC# does not have a #{head} Head.",
        '',
        'Current Heads are:',
        *STATEMENT_STARTERS.map { |name| "  #{name}" }
      ].join("\n")
    end

    def parse_body_item(line, text, terminal:)
      result = nil
      action = nil
      body = text

      if (match = body.match(/\A<([a-z]+)>\s*(.*)\z/))
        raw_result = match[1].downcase
        body = match[2].strip
        result = RESULT_ALIASES[raw_result]
        unless result
          diagnostics.error(line.number, "unknown Connector '<#{raw_result}>'; did you mean <then>?")
          result = body.start_with?('(') ? 'then' : raw_result
        end
      elsif body.start_with?('<')
        diagnostics.error(line.number, 'Connectors must look like <then>')
      end

      if body.start_with?('(')
        match = body.match(/\A\((\w+)\b\s*(.*)\z/)
        if match
          action = match[1].downcase
        else
          diagnostics.error(line.number, 'Official words must look like (damage')
        end
      end

      ChildLine.new(
        raw: line.text,
        body: body,
        line_command: result,
        action: action,
        line_number: line.number,
        terminal: terminal
      )
    end

    def parse_kind_definitions(statements)
      definitions = []
      statements.select { |statement| statement.starter == 'KINDS' }.each do |statement|
        statement.children.each do |child|
          match = child.body.match(/\A(\w+)\s+is\s+a\s+(\w+)\z/)
          unless match
            diagnostics.error(child.line_number, "Kind must look like 'dragon is a creature'")
            next
          end

          name = match[1].downcase
          parent = match[2].downcase
          unless dictionary.known_kind?(parent)
            diagnostics.error(child.line_number, "unknown parent kind '#{parent}'")
            next
          end

          existing_parent = dictionary.kind_parent(name)
          if existing_parent
            diagnostics.error(child.line_number, "kind '#{name}' already has parent '#{existing_parent}'")
            next
          end

          cycle = dictionary.kind_cycle_with(name, parent)
          if cycle
            diagnostics.error(child.line_number, "Kind family has a loop: #{cycle.join(' -> ')}")
            next
          end

          dictionary.add_kind(name, parent)
          definitions << KindDefinition.new(name: name, parent: parent, line_number: child.line_number)
        end
      end
      definitions
    end

    def parse_definitions(statement)
      statement.children.filter_map do |child|
        match = child.body.match(/\Aa\s+(\w+)\s+named\s+(.+)\z/)
        unless match
          diagnostics.error(child.line_number, "Thing must look like 'a door named north door'")
          next
        end

        kind = match[1].downcase
        name = match[2].strip.downcase
        dictionary.add_object(name, kind)
        Definition.new(kind: kind, name: name, line_number: child.line_number)
      end
    end

    def parse_start_facts(statement)
      statement.children.filter_map { |child| parse_fact(child) }
    end

    def parse_fact(child)
      match = child.body.match(/\A(.+?)\s+(is|isnt|has)\s+(.+)\z/)
      unless match
        diagnostics.error(child.line_number, "Fact must look like 'subject is state' or 'subject has 10 health'")
        return nil
      end

      relation = match[2].downcase
      supplied_value = match[3].strip
      literal = nil
      value_name = nil
      if relation == 'has' && TextLiteral.quote_present?(supplied_value)
        begin
          literal, value_name = TextLiteral.parse_assignment(supplied_value)
        rescue TextLiteralError => error
          diagnostics.error(child.line_number, error.message)
        end
      end

      Fact.new(
        subject: match[1].strip.downcase,
        relation: relation,
        value: literal || supplied_value.downcase,
        value_name: value_name,
        line_number: child.line_number
      )
    end

    def parse_when(statement)
      trigger = statement.children.find { |child| child.line_command.nil? }
      results = statement.children.select { |child| child.line_command == 'then' }
      diagnostics.error(statement.line_number, 'WHEN needs one Trigger') unless trigger
      diagnostics.error(statement.line_number, 'WHEN needs at least one Connector followed by an official word') if results.empty?
      return nil unless trigger

      EventRule.new(event: trigger.body, actions: results.map { |child| parse_order(child) }.compact, line_number: statement.line_number)
    end

    def parse_if(statement)
      condition = statement.children.find { |child| child.line_command.nil? }
      results = statement.children.select { |child| child.line_command == 'then' }
      diagnostics.error(statement.line_number, 'IF needs one Fact to check') unless condition
      diagnostics.error(statement.line_number, 'IF needs at least one Connector followed by an official word') if results.empty?
      return nil unless condition

      parse_fact(condition)
      IfRule.new(condition: condition.body, actions: results.map { |child| parse_order(child) }.compact, line_number: statement.line_number)
    end

    def parse_order(child)
      match = child.body.match(/\A\((\w+)\b\s*(.*)\z/)
      unless match
        diagnostics.error(child.line_number, 'Connector must be followed by an official word such as (damage')
        return nil
      end

      verb = match[1].downcase
      rest = match[2].strip
      target, tail = if verb == 'cause'
                       [rest.downcase, '']
                     else
                       split_order_rest(rest)
                     end
      text_literal = nil
      if verb == 'change' && (to_match = tail.match(/\Ato\s+(.+)\z/i)) && TextLiteral.quote_present?(to_match[1])
        begin
          text_literal = TextLiteral.parse_token(to_match[1])
        rescue TextLiteralError => error
          diagnostics.error(child.line_number, error.message)
        end
      end
      ActionCall.new(
        verb: verb,
        target: target.downcase,
        tail: text_literal ? 'to <text>' : tail.downcase,
        text_literal: text_literal,
        line_number: child.line_number
      )
    end

    def split_order_rest(rest)
      return ['', ''] if rest.empty?

      if (match = rest.match(/\A(.+?)\s+to\s+(.+)\z/i))
        target, tail = match[1], match[2]
        [target.strip, "to #{tail.strip}"]
      elsif (match = rest.match(/\A(.+?)\s+by\s+(.+)\z/i))
        target = match && match[1]
        tail = match && match[2]
        [target.to_s.strip, "by #{tail.to_s.strip}"]
      else
        [rest.strip, '']
      end
    end
  end
end

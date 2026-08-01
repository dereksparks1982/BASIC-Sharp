# frozen_string_literal: true

require_relative 'ast_nodes'
require_relative 'diagnostics'
require_relative 'dictionary'
require_relative 'lexer'
require_relative 'text_literal'

module BasicSharp
  class Parser
    BLOCK_HEADS = %w[KINDS DEFINE START WHEN IF OTHERWISE CONTROLS HOVER CONTEXT].freeze
    STATEMENT_STARTERS = BLOCK_HEADS
    DORMANT_HEADS = %w[WORLD STATES RELATIONS ACTIONS WHILE].freeze
    HOVER_FIELDS = %w[name kind state description].freeze

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
      controls = []
      hover_declarations = []
      context_declarations = []

      statements.each_with_index do |statement, index|
        case statement.starter
        when 'DEFINE' then definitions.concat(parse_definitions(statement))
        when 'START' then facts.concat(parse_start_facts(statement))
        when 'WHEN'
          rule = parse_when(statement)
          event_rules << rule if rule
        when 'IF'
          rule = parse_if(statement)
          if_rules << rule if rule
        when 'OTHERWISE'
          previous = index.positive? ? statements[index - 1] : nil
          if previous&.starter == 'IF' && if_rules.last&.line_number == previous.line_number && if_rules.last.otherwise_actions.nil?
            actions = parse_otherwise(statement)
            if_rules.last.otherwise_actions = actions
            if_rules.last.otherwise_line_number = statement.line_number
          elsif previous&.starter == 'OTHERWISE'
            diagnostics.error(statement.line_number, 'An IF can have only one OTHERWISE Body.')
            parse_otherwise(statement)
          else
            diagnostics.error(statement.line_number, 'OTHERWISE must directly follow the IF Body it belongs to.')
            parse_otherwise(statement)
          end
        when 'CONTROLS'
          declaration = parse_controls(statement)
          controls << declaration if declaration
        when 'HOVER'
          declaration = parse_hover(statement)
          hover_declarations << declaration if declaration
        when 'CONTEXT'
          declaration = parse_context(statement)
          context_declarations << declaration if declaration
        end
      end

      Program.new(
        statements: statements,
        kind_definitions: kind_definitions,
        definitions: definitions,
        facts: facts,
        event_rules: event_rules,
        if_rules: if_rules,
        controls: controls,
        hover_declarations: hover_declarations,
        context_declarations: context_declarations,
        diagnostics: diagnostics.items
      )
    end

    private

    def parse_statements
      lexer = Lexer.new(@source)
      lines = lexer.lines
      lexer.issues.each { |issue| diagnostics.error(issue.line_number, issue.message) }
      statements = []
      current = nil
      expecting_body = false

      lines.each do |line|
        text = line.text

        if current.nil?
          head = parse_head(line)
          next unless head

          current = Statement.new(starter: head.fetch(:starter), head: head[:detail], children: [], line_number: line.number)
          statements << current
          expecting_body = true
          next
        end

        if expecting_body
          if text == '['
            expecting_body = false
            next
          end

          if text.start_with?('<')
            diagnostics.error(line.number, 'old child-line structure no longer works; start the Body with [')
          elsif text.start_with?('[')
            diagnostics.error(line.number, "#{current.starter} Body must place [ on its own line")
          else
            diagnostics.error(line.number, "#{current.starter} Body must start with [ on the next line")
          end
          current = nil
          expecting_body = false
          redo
        end

        if text == '].'
          if current.children.empty?
            diagnostics.warning(current.line_number, "#{current.starter} Body is empty")
          end
          current = nil
          next
        end

        if text == ']'
          diagnostics.error(line.number, 'A Body must close with ].')
          current = nil
          next
        end

        if head_line?(text)
          diagnostics.error(current.line_number, "#{current.starter} Body is missing its End ].")
          current = nil
          redo
        end

        if text.end_with?('].')
          diagnostics.error(line.number, 'The final instruction and ]. must be on separate lines')
          body = text[0...-2].strip
          current.children << parse_body_item(line, body) unless body.empty?
          current = nil
          next
        end

        diagnostics.error(line.number, 'Internal instructions do not end with a period; only ]. closes the Body') if text.end_with?('.')
        current.children << parse_body_item(line, text)
      end

      if current
        message = expecting_body ? "#{current.starter} Body must start with [" : "#{current.starter} Body is missing its End ]."
        diagnostics.error(current.line_number, message)
      end

      statements
    end

    def parse_head(line)
      text = line.text
      if text == 'ELSE' || text.start_with?('ELSE ')
        diagnostics.error(line.number, 'BASIC# uses OTHERWISE instead of ELSE.')
        return { starter: 'ELSE', detail: text.delete_prefix('ELSE').strip }
      end
      if text.start_with?('OTHERWISE ')
        diagnostics.error(line.number, 'OTHERWISE stands alone on its Head line. Put no condition after it.')
        return { starter: 'OTHERWISE', detail: text.delete_prefix('OTHERWISE').strip }
      end
      return dormant_head(line, text) if DORMANT_HEADS.include?(text)
      return { starter: text, detail: nil } if %w[KINDS DEFINE START OTHERWISE].include?(text)

      if (match = text.match(/\A(WHEN|IF)\s+(.+)\z/))
        return { starter: match[1], detail: match[2].strip }
      end
      if %w[WHEN IF].include?(text)
        diagnostics.error(line.number, "#{text} must put its #{text == 'WHEN' ? 'event' : 'condition'} on the Head line")
        return { starter: text, detail: nil }
      end

      if (match = text.match(/\A(CONTROLS|HOVER|CONTEXT)\s+for\s+(.+)\z/))
        return { starter: match[1], detail: match[2].strip }
      end

      if text.start_with?(':')
        diagnostics.error(line.number, 'Game-system Heads do not begin with a colon. Write CONTROLS, HOVER, or CONTEXT directly.')
        return nil
      end

      diagnostics.error(line.number, 'expected a Head before the Body')
      nil
    end

    def dormant_head(line, text)
      diagnostics.error(line.number, unsupported_head_message(text))
      { starter: text, detail: nil }
    end

    def head_line?(text)
      BLOCK_HEADS.any? { |head| text == head || text.start_with?("#{head} ") } || DORMANT_HEADS.include?(text) || text == 'ELSE' || text.start_with?('ELSE ')
    end

    def unsupported_head_message(head)
      [
        "BASIC# does not have a #{head} Head.",
        '',
        'Current Heads are:',
        *BLOCK_HEADS.map { |name| "  #{name}" }
      ].join("\n")
    end

    def parse_body_item(line, text)
      result = nil
      action = nil
      body = text

      if body.start_with?('|then')
        unless body.match?(/\A\|then(?:\s|$)/)
          diagnostics.error(line.number, 'The result marker must be lowercase |then followed by a space')
        end
        body = body.sub(/\A\|then\b/, '').strip
        result = 'then'
      elsif body.match?(/\A<(?:then|than)>/i)
        diagnostics.error(line.number, 'The retired <then> and <than> markers no longer work. Use |then.')
        body = body.sub(/\A<[^>]+>\s*/, '')
        result = 'then'
      elsif body.match?(/\A<[^>]+>/)
        marker = body[/\A<[^>]+>/]
        diagnostics.error(line.number, "Unknown retired result marker '#{marker}'. Use |then.")
        body = body.sub(/\A<[^>]+>\s*/, '')
        result = 'then'
      elsif body.start_with?('|')
        diagnostics.error(line.number, 'Result instructions must begin with |then')
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
        terminal: false
      )
    end

    def parse_kind_definitions(statements)
      definitions = []
      statements.select { |statement| statement.starter == 'KINDS' }.each do |statement|
        statement.children.each do |child|
          if !child.body.match?(/\s+is\s+/i) && (root = child.body.match(/\A#(.+)\z/))
            name = normalized_name(root[1])
            unless name == 'thing'
              diagnostics.error(child.line_number, "Kind must name its parent, such as '#door is a #thing'")
            end
            next
          end

          match = child.body.match(/\A#(.+?)\s+is\s+a\s+#(.+)\z/i)
          unless match
            diagnostics.error(child.line_number, "Kind must look like '#dragon is a #creature'")
            next
          end

          name = normalized_name(match[1])
          parent = normalized_name(match[2])
          unless dictionary.known_kind?(parent)
            diagnostics.error(child.line_number, "unknown parent Kind '#{parent}'; mark every Kind with #")
            next
          end
          if (existing_parent = dictionary.kind_parent(name))
            diagnostics.error(child.line_number, "kind '#{name}' already has parent '#{existing_parent}'")
            next
          end
          if (cycle = dictionary.kind_cycle_with(name, parent))
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
        match = child.body.match(/\A@(.+?)\s+is\s+an?\s+#(.+)\z/i)
        unless match
          diagnostics.error(child.line_number, "Thing must look like '@north door is a #door'")
          next
        end
        name = normalized_name(match[1])
        kind = normalized_name(match[2])
        dictionary.add_object(name, kind)
        Definition.new(kind: kind, name: name, line_number: child.line_number)
      end
    end

    def parse_start_facts(statement)
      statement.children.filter_map { |child| parse_fact(child) }
    end

    def parse_fact(child)
      match = child.body.match(/\A(.+?)\s+(is|isnt|has)\s+(.+)\z/i)
      unless match
        diagnostics.error(child.line_number, "Fact must look like '@door is closed' or 'PLAYER has 3 speed'")
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
        subject: match[1].strip,
        relation: relation,
        value: literal || supplied_value,
        value_name: value_name,
        line_number: child.line_number
      )
    end

    def parse_when(statement)
      diagnostics.error(statement.line_number, 'WHEN needs an event on its Head line') if statement.head.to_s.empty?
      invalid = statement.children.reject { |child| child.line_command == 'then' }
      invalid.each { |child| diagnostics.error(child.line_number, 'Every WHEN Body instruction must begin with |then') }
      results = statement.children.select { |child| child.line_command == 'then' }
      diagnostics.error(statement.line_number, 'WHEN needs at least one |then followed by an official word') if results.empty?
      return nil if statement.head.to_s.empty?

      EventRule.new(event: statement.head, actions: results.map { |child| parse_order(child) }.compact, line_number: statement.line_number)
    end

    def parse_if(statement)
      diagnostics.error(statement.line_number, 'IF needs a condition on its Head line') if statement.head.to_s.empty?
      invalid = statement.children.reject { |child| child.line_command == 'then' }
      invalid.each { |child| diagnostics.error(child.line_number, 'Every IF Body instruction must begin with |then') }
      results = statement.children.select { |child| child.line_command == 'then' }
      diagnostics.error(statement.line_number, 'IF needs at least one |then followed by an official word') if results.empty?
      return nil if statement.head.to_s.empty?

      IfRule.new(
        condition: statement.head,
        actions: results.map { |child| parse_order(child) }.compact,
        otherwise_actions: nil,
        line_number: statement.line_number,
        otherwise_line_number: nil
      )
    end

    def parse_otherwise(statement)
      invalid = statement.children.reject { |child| child.line_command == 'then' }
      invalid.each { |child| diagnostics.error(child.line_number, 'Every OTHERWISE Body instruction must begin with |then') }
      results = statement.children.select { |child| child.line_command == 'then' }
      diagnostics.error(statement.line_number, 'OTHERWISE needs at least one |then followed by an official word') if results.empty?
      results.map { |child| parse_order(child) }.compact
    end

    def parse_controls(statement)
      unless statement.head == 'PLAYER'
        diagnostics.error(statement.line_number, 'CONTROLS currently belongs to the built-in PLAYER')
      end
      instructions = statement.children.filter_map do |child|
        text = child.body
        if (match = text.match(/\A([WASD])\s+moves\s+PLAYER\s+(north|south|west|east)\z/))
          { 'type' => 'key_move', 'key' => match[1], 'direction' => match[2], 'line_number' => child.line_number }
        elsif (match = text.match(/\A([A-Z][A-Z0-9]*)\s+moves\s+PLAYER\s+(left|right)\s+at\s+(.+?)\s+speed\z/))
          {
            'type' => 'platform_move', 'key' => match[1], 'direction' => match[2],
            'speed' => match[3].strip, 'line_number' => child.line_number
          }
        elsif (match = text.match(/\A([A-Z][A-Z0-9]*)\s+makes\s+PLAYER\s+jump\s+at\s+(.+?)\s+speed\z/))
          {
            'type' => 'platform_jump', 'key' => match[1],
            'speed' => match[2].strip, 'line_number' => child.line_number
          }
        elsif text == 'PLAYER faces mouse pointer'
          { 'type' => 'face_pointer', 'line_number' => child.line_number }
        elsif text == 'holding right mouse moves PLAYER toward mouse pointer'
          { 'type' => 'right_mouse_move', 'line_number' => child.line_number }
        else
          diagnostics.error(child.line_number, "Unknown CONTROLS instruction '#{text}'")
          nil
        end
      end
      ControlDeclaration.new(subject: 'PLAYER', instructions: instructions, line_number: statement.line_number)
    end

    def parse_hover(statement)
      fields = statement.children.filter_map do |child|
        field = child.body.downcase
        unless HOVER_FIELDS.include?(field)
          diagnostics.error(child.line_number, "HOVER information must be name, kind, state, or description")
          next
        end
        { 'name' => field, 'line_number' => child.line_number }
      end
      HoverDeclaration.new(subject: statement.head, fields: fields, line_number: statement.line_number)
    end

    def parse_context(statement)
      entries = statement.children.filter_map do |child|
        match = child.body.match(/\A("[^"]*")(?:\s+when\s+(.+?))?\s+(\(\w+\b.*)\z/)
        unless match
          diagnostics.error(child.line_number, 'CONTEXT entry must look like "Open" when it is closed (change it to open')
          next
        end
        begin
          label = TextLiteral.parse_token(match[1]).value
        rescue TextLiteralError => error
          diagnostics.error(child.line_number, error.message)
          next
        end
        action_child = ChildLine.new(body: match[3], line_number: child.line_number)
        ContextEntry.new(
          label: label,
          condition: match[2]&.strip,
          action: parse_order(action_child),
          line_number: child.line_number
        )
      end
      ContextDeclaration.new(subject: statement.head, entries: entries, line_number: statement.line_number)
    end

    def parse_order(child)
      match = child.body.match(/\A\((\w+)\b\s*(.*)\z/)
      unless match
        diagnostics.error(child.line_number, 'Result must be followed by an official word such as (damage')
        return nil
      end

      verb = match[1].downcase
      rest = match[2].strip
      target, tail = verb == 'cause' ? [rest, ''] : split_order_rest(rest)
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
        target: target,
        tail: text_literal ? 'to <text>' : tail,
        text_literal: text_literal,
        line_number: child.line_number
      )
    end

    def split_order_rest(rest)
      return ['', ''] if rest.empty?
      if (match = rest.match(/\A(.+?)\s+to\s+(.+)\z/i))
        [match[1].strip, "to #{match[2].strip}"]
      elsif (match = rest.match(/\A(.+?)\s+by\s+(.+)\z/i))
        [match[1].strip, "by #{match[2].strip}"]
      else
        [rest.strip, '']
      end
    end

    def normalized_name(value)
      value.to_s.strip.downcase.gsub(/\s+/, ' ')
    end
  end
end

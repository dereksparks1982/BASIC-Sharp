# frozen_string_literal: true

require_relative 'diagnostics'
require_relative 'dictionary'
require_relative 'parser'
require_relative 'resolver'
require_relative 'small_compiler_subset_parser'
require_relative 'text_literal'

module BasicSharp
  class SmallCompilerSubsetIREmitter
    FORMAT = 'bsharp.small_compiler_subset.ir_emitter.record'
    STATUS = 'ir_emitter_under_ruby_referee'
    HOVER_FIELDS = Parser::HOVER_FIELDS

    attr_reader :subset_parser, :dictionary, :diagnostics

    def initialize(source)
      @source = source
      @subset_parser = SmallCompilerSubsetParser.new(source)
      @dictionary = CoreDictionary.new
      @diagnostics = DiagnosticBag.new
      @program = nil
      @document = nil
      @ruby_referee_document = nil
    end

    def program
      @program ||= build_program
    end

    def document
      @document ||= SemanticResolver.new(program, dictionary: dictionary).resolve
    end

    def bsharp_ir
      document.to_h
    end

    def ruby_referee_bsharp_ir
      ruby_referee_document.to_h
    end

    def parser_matches_ruby_referee?
      subset_parser.parser_matches_ruby_referee?
    end

    def ir_matches_ruby_referee?
      bsharp_ir == ruby_referee_bsharp_ir
    end

    def to_h
      {
        format: FORMAT,
        version: BasicSharp::VERSION,
        status: STATUS,
        parser_ruby_referee_matches: parser_matches_ruby_referee?,
        ruby_referee_matches: ir_matches_ruby_referee?,
        bsharp_ir: bsharp_ir
      }
    end

    private

    def ruby_referee_document
      return @ruby_referee_document if @ruby_referee_document

      parser = Parser.new(@source)
      ruby_program = parser.parse
      @ruby_referee_document = SemanticResolver.new(ruby_program, dictionary: parser.dictionary).resolve
    end

    def build_program
      statements = subset_parser.statements.map { |statement| statement_to_ast(statement) }
      subset_parser.issues.each { |issue| diagnostics.error(issue.line_number, issue.message) }

      kind_definitions = []
      definitions = []
      facts = []
      event_rules = []
      if_rules = []
      controls = []
      hover_declarations = []
      context_declarations = []

      statements.select { |statement| statement.starter == 'KINDS' }.each do |statement|
        kind_definitions.concat(parse_kind_definitions(statement))
      end

      statements.each_with_index do |statement, index|
        case statement.starter
        when 'DEFINE' then definitions.concat(parse_definitions(statement))
        when 'START' then facts.concat(statement.children.filter_map { |child| parse_fact(child) })
        when 'WHEN'
          rule = parse_when(statement)
          event_rules << rule if rule
        when 'IF'
          rule = parse_if(statement)
          if_rules << rule if rule
        when 'OTHERWISE'
          previous = index.positive? ? statements[index - 1] : nil
          if previous&.starter == 'IF' && if_rules.last&.line_number == previous.line_number && if_rules.last.otherwise_actions.nil?
            if_rules.last.otherwise_actions = parse_otherwise(statement)
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

    def statement_to_ast(statement)
      Statement.new(
        starter: statement.starter,
        head: statement.head,
        line_number: statement.line_number,
        children: statement.children.map { |child| child_to_ast(child) }
      )
    end

    def child_to_ast(child)
      ChildLine.new(
        raw: child.result_marker ? "|then #{child.body}" : child.body,
        body: child.body,
        line_command: child.result_marker,
        action: child.action,
        line_number: child.line_number,
        terminal: false
      )
    end

    def parse_kind_definitions(statement)
      definitions = []
      statement.children.each do |child|
        if !child.body.match?(/\s+is\s+/i) && (root = child.body.match(/\A#(.+)\z/))
          name = normalized_name(root[1])
          diagnostics.error(child.line_number, "Kind must name its parent, such as '#door is a #thing'") unless name == 'thing'
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
      diagnostics.error(statement.line_number, 'CONTROLS currently belongs to the built-in PLAYER') unless statement.head == 'PLAYER'
      instructions = statement.children.filter_map do |child|
        text = child.body
        if (match = text.match(/\A([WASD])\s+moves\s+PLAYER\s+(north|south|west|east)\z/))
          { 'type' => 'key_move', 'key' => match[1], 'direction' => match[2], 'line_number' => child.line_number }
        elsif (match = text.match(/\A([A-Z][A-Z0-9]*)\s+moves\s+PLAYER\s+(left|right)\s+at\s+(.+?)\s+speed\z/))
          { 'type' => 'platform_move', 'key' => match[1], 'direction' => match[2], 'speed' => match[3].strip, 'line_number' => child.line_number }
        elsif (match = text.match(/\A([A-Z][A-Z0-9]*)\s+makes\s+PLAYER\s+jump\s+at\s+(.+?)\s+speed\z/))
          { 'type' => 'platform_jump', 'key' => match[1], 'speed' => match[2].strip, 'line_number' => child.line_number }
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
          diagnostics.error(child.line_number, 'HOVER information must be name, kind, state, or description')
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

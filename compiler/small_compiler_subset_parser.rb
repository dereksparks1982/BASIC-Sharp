# frozen_string_literal: true

require_relative 'parser'
require_relative 'tokenizer_reader'
require_relative 'small_compiler_subset_native_dispatch'

module BasicSharp
  class SmallCompilerSubsetParser
    SubsetChild = Struct.new(:body, :result_marker, :action, :line_number, keyword_init: true) do
      def to_h
        result = { body: body, line_number: line_number }
        result[:result_marker] = result_marker if result_marker
        result[:action] = action if action
        result
      end
    end

    SubsetStatement = Struct.new(:starter, :head, :children, :line_number, :body_open_line, :body_close_line, keyword_init: true) do
      def to_h
        result = {
          starter: starter,
          head: head,
          line_number: line_number,
          children: children.map(&:to_h)
        }
        result[:body_open_line] = body_open_line if body_open_line
        result[:body_close_line] = body_close_line if body_close_line
        result
      end
    end

    IssueRecord = Struct.new(:line_number, :message, keyword_init: true) do
      def to_h
        { line_number: line_number, message: message }
      end
    end

    FORMAT = 'bsharp.small_compiler_subset.parser.record'
    STATUS = 'implementation_under_ruby_referee'

    attr_reader :reader, :issues, :native_dispatcher

    def initialize(source, native_dispatcher: nil)
      @source = source
      @reader = TokenizerReader.new(source)
      @native_dispatcher = native_dispatcher || SmallCompilerSubsetNativeDispatch.new
      @issues = []
      @statements = nil
      @ruby_referee_program = nil
    end

    def statements
      @statements ||= parse_reader_records
    end

    def ruby_referee_statements
      ruby_referee_program.statements.map { |statement| statement_to_subset_hash(statement) }
    end

    def parser_matches_ruby_referee?
      statements.map { |statement| comparison_statement_hash(statement) } == ruby_referee_statements
    end

    def to_h
      {
        format: FORMAT,
        version: BasicSharp::VERSION,
        status: STATUS,
        statements: statements.map(&:to_h),
        issues: issues.map(&:to_h),
        ruby_referee_matches: parser_matches_ruby_referee?
      }
    end

    private

    def ruby_referee_program
      @ruby_referee_program ||= Parser.new(@source).parse
    end

    def parse_reader_records
      result = []
      current = nil
      expecting_body = false

      reader.reader_records.each do |record|
        text = record.text

        if current.nil?
          head = parse_head(text)
          unless head
            @issues << IssueRecord.new(line_number: record.number, message: 'expected a Head before the Body')
            next
          end

          current = SubsetStatement.new(
            starter: head.fetch(:starter),
            head: head[:detail],
            children: [],
            line_number: record.number
          )
          result << current
          expecting_body = true
          next
        end

        if expecting_body
          if text == '['
            current.body_open_line = record.number
            expecting_body = false
            next
          end

          @issues << IssueRecord.new(line_number: record.number, message: "#{current.starter} Body must start with [ on the next line")
          current = nil
          expecting_body = false
          redo
        end

        if text == '].'
          current.body_close_line = record.number
          current = nil
          next
        end

        if text == ']'
          @issues << IssueRecord.new(line_number: record.number, message: 'A Body must close with ].')
          current = nil
          next
        end

        if head_line?(text)
          @issues << IssueRecord.new(line_number: current.line_number, message: "#{current.starter} Body is missing its End ].")
          current = nil
          redo
        end

        current.children << parse_child(record, text)
      end

      if current
        message = expecting_body ? "#{current.starter} Body must start with [" : "#{current.starter} Body is missing its End ]."
        @issues << IssueRecord.new(line_number: current.line_number, message: message)
      end

      result
    end

    def parse_head(text)
      dispatch = native_dispatcher.dispatch(text)
      return nil unless dispatch

      starter = dispatch.head_word
      case dispatch.decision
      when 'parse-kind-section', 'parse-definition-section', 'parse-startup-section', 'parse-alternate-branch'
        return { starter: starter, detail: nil } if text == starter
      when 'parse-event-rule', 'parse-condition-rule'
        match = text.match(/\A#{Regexp.escape(starter)}\s+(.+)\z/)
        return { starter: starter, detail: match[1].strip } if match
      when 'parse-controls-section', 'parse-hover-section', 'parse-context-section'
        match = text.match(/\A#{Regexp.escape(starter)}\s+for\s+(.+)\z/)
        return { starter: starter, detail: match[1].strip } if match
      else
        raise SmallCompilerSubsetNativeDispatchError,
              "BASIC# native parser dispatch returned unknown decision '#{dispatch.decision}' for #{starter}."
      end

      nil
    end

    def head_line?(text)
      !native_dispatcher.dispatch(text).nil?
    end

    def parse_child(record, text)
      body = text
      result_marker = nil

      if body.start_with?('|then')
        body = body.sub(/\A\|then\b/, '').strip
        result_marker = 'then'
      end

      action = nil
      if (match = body.match(/\A\((\w+)\b/))
        action = match[1].downcase
      end

      SubsetChild.new(body: body, result_marker: result_marker, action: action, line_number: record.number)
    end

    def comparison_statement_hash(statement)
      {
        starter: statement.starter,
        head: statement.head,
        line_number: statement.line_number,
        children: statement.children.map { |child| child_to_subset_hash(child) }
      }
    end

    def statement_to_subset_hash(statement)
      result = {
        starter: statement.starter,
        head: statement.head,
        line_number: statement.line_number,
        children: statement.children.map { |child| child_to_subset_hash(child) }
      }
      result
    end

    def child_to_subset_hash(child)
      result = { body: child.body, line_number: child.line_number }
      marker = child.respond_to?(:line_command) ? child.line_command : child.result_marker
      result[:result_marker] = marker if marker
      result[:action] = child.action if child.action
      result
    end
  end
end

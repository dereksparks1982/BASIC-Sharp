# frozen_string_literal: true

require_relative 'lexer'
require_relative 'parser'

module BasicSharp
  class TokenizerReader
    ReaderRecord = Struct.new(:number, :raw, :text, keyword_init: true) do
      def to_h
        { number: number, raw: raw, text: text }
      end
    end

    IssueRecord = Struct.new(:line_number, :column, :message, keyword_init: true) do
      def to_h
        { line_number: line_number, column: column, message: message }
      end
    end

    TokenRecord = Struct.new(:kind, :line, :column, :text, :normalized, keyword_init: true) do
      def to_h
        result = { kind: kind, line: line, column: column, text: text }
        result[:normalized] = normalized if normalized
        result
      end
    end

    HEAD_WORDS = Parser::BLOCK_HEADS.freeze
    RESULT_MARKER = '|then'

    def initialize(source)
      @source = source
      @reader_records = nil
      @issues = nil
      @token_records = nil
    end

    def reader_records
      @reader_records ||= independent_lines
    end

    def issues
      reader_records
      @issues
    end

    def token_records
      @token_records ||= reader_records.flat_map { |record| tokens_for(record) }
    end

    def ruby_referee_reader_records
      ruby_referee_lines.map { |line| { number: line.number, raw: line.raw, text: line.text } }
    end

    def reader_matches_ruby_referee?
      reader_records.map(&:to_h) == ruby_referee_reader_records
    end

    def to_h
      {
        format: 'bsharp.tokenizer_reader.implementation.record',
        version: BasicSharp::VERSION,
        reader_records: reader_records.map(&:to_h),
        token_records: token_records.map(&:to_h),
        issues: issues.map(&:to_h)
      }
    end

    private

    def independent_lines
      stripped_source = independent_remove_comments
      stripped_source.each_line.with_index(1).filter_map do |raw, index|
        text = raw.strip
        next if text.empty?

        ReaderRecord.new(number: index, raw: raw.chomp, text: text)
      end
    end

    def independent_remove_comments
      output = +''
      @issues = []
      in_comment = false
      in_quote = false
      comment_line = nil
      comment_column = nil
      line = 1
      column = 1
      index = 0

      while index < @source.length
        pair = @source[index, 2]
        character = @source[index]

        if in_comment
          if pair == '/.'
            in_comment = false
            output << '  '
            index += 2
            column += 2
          elsif pair == '//'
            @issues << IssueRecord.new(
              line_number: line,
              column: column,
              message: 'Comments cannot begin inside another comment. Close the current comment with /.'
            )
            output << '  '
            index += 2
            column += 2
          else
            output << (character == "\n" ? "\n" : ' ')
            if character == "\n"
              line += 1
              column = 1
            else
              column += 1
            end
            index += 1
          end
          next
        end

        if pair == '/.' && !in_quote
          @issues << IssueRecord.new(
            line_number: line,
            column: column,
            message: 'This comment closing marker has no opening //. Remove /. or open the comment with //.'
          )
          output << '  '
          index += 2
          column += 2
          next
        end

        if pair == '//' && !in_quote
          in_comment = true
          comment_line = line
          comment_column = column
          output << '  '
          index += 2
          column += 2
          next
        end

        in_quote = !in_quote if character == '"'
        output << character
        if character == "\n"
          line += 1
          column = 1
          in_quote = false
        else
          column += 1
        end
        index += 1
      end

      if in_comment
        @issues << IssueRecord.new(
          line_number: comment_line,
          column: comment_column,
          message: [
            'This comment was opened with // but was never closed.',
            '',
            "The comment begins on line #{comment_line}, column #{comment_column}.",
            '',
            'Close the comment by adding /.'
          ].join("\n")
        )
      end

      output
    end

    def ruby_referee_lines
      return @ruby_referee_lines if @ruby_referee_lines

      lexer = Lexer.new(@source)
      @ruby_referee_lines = lexer.lines
      @issues = lexer.issues.map do |issue|
        IssueRecord.new(line_number: issue.line_number, column: issue.column, message: issue.message)
      end
      @ruby_referee_lines
    end

    def tokens_for(record)
      text = record.text
      tokens = []
      add_primary_token(tokens, record, text)
      add_result_token(tokens, record, text)
      add_action_tokens(tokens, record, text)
      add_quoted_text_tokens(tokens, record, text)
      tokens
    end

    def add_primary_token(tokens, record, text)
      if text == '['
        tokens << token(record, 'body_open', text, text, '[')
      elsif text == '].' || text == ']'
        tokens << token(record, 'body_close', text, text, text)
      elsif (head = head_word_for(text))
        tokens << token(record, 'head', text, head, head)
      elsif text.start_with?(RESULT_MARKER)
        tokens << token(record, 'result_line', text, RESULT_MARKER, RESULT_MARKER)
      else
        tokens << token(record, 'body_line', text, text, nil)
      end
    end

    def add_result_token(tokens, record, text)
      return unless text.start_with?(RESULT_MARKER)

      tokens << token(record, 'result_marker', text, RESULT_MARKER, RESULT_MARKER)
    end

    def add_action_tokens(tokens, record, text)
      scan_unquoted(text) do |segment, offset|
        segment.to_enum(:scan, /\((\w+)\b/).each do
          match = Regexp.last_match
          tokens << TokenRecord.new(
            kind: 'action_word',
            line: record.number,
            column: column_for(record, offset + match.begin(0)),
            text: match[0],
            normalized: match[1].downcase
          )
        end
      end
    end

    def add_quoted_text_tokens(tokens, record, text)
      index = 0
      while index < text.length
        if text[index] == '"'
          close = text.index('"', index + 1)
          break unless close

          literal = text[index..close]
          tokens << TokenRecord.new(
            kind: 'quoted_text',
            line: record.number,
            column: column_for(record, index),
            text: literal,
            normalized: nil
          )
          index = close + 1
        else
          index += 1
        end
      end
    end

    def scan_unquoted(text)
      index = 0
      start = 0
      in_quote = false
      while index < text.length
        if text[index] == '"'
          unless in_quote
            yield text[start...index], start if start < index
            in_quote = true
          else
            in_quote = false
            start = index + 1
          end
        end
        index += 1
      end
      yield text[start..] || '', start unless in_quote
    end

    def head_word_for(text)
      HEAD_WORDS.find { |head| text == head || text.start_with?("#{head} ") }
    end

    def token(record, kind, full_text, token_text, normalized)
      TokenRecord.new(kind: kind, line: record.number, column: column_for(record, full_text.index(token_text) || 0), text: token_text, normalized: normalized)
    end

    def column_for(record, text_offset)
      raw_index = record.raw.index(record.text) || 0
      raw_index + text_offset + 1
    end
  end
end

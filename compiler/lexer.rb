# frozen_string_literal: true

module BasicSharp
  class Lexer
    Line = Struct.new(:number, :raw, :text, keyword_init: true)
    Issue = Struct.new(:line_number, :column, :message, keyword_init: true)

    attr_reader :issues

    def initialize(source)
      @source = source
      @issues = []
    end

    def lines
      stripped_source = remove_comments
      stripped_source.each_line.with_index(1).filter_map do |raw, index|
        text = raw.strip
        next if text.empty?

        Line.new(number: index, raw: raw.chomp, text: text)
      end
    end

    private

    def remove_comments
      output = +''
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
            @issues << Issue.new(
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
          @issues << Issue.new(
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
        @issues << Issue.new(
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
  end
end

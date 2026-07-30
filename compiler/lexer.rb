# frozen_string_literal: true

module BasicSharp
  class Lexer
    Line = Struct.new(:number, :raw, :text, keyword_init: true)

    def initialize(source)
      @source = source
    end

    def lines
      @source.each_line.with_index(1).filter_map do |raw, index|
        text = raw.strip
        next if text.empty?
        next if text.start_with?('#')

        Line.new(number: index, raw: raw.chomp, text: text)
      end
    end
  end
end

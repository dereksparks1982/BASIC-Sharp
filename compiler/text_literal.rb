# frozen_string_literal: true

module BasicSharp
  class TextLiteralError < ArgumentError; end

  # One creator-facing text value exactly as it appeared between straight quotes.
  # Identifier normalization must never pass through this value object.
  class TextLiteral
    CURLY_QUOTES = ["\u201C", "\u201D", "\u201E", "\u201F"].freeze

    attr_reader :value

    def initialize(value)
      unless value.is_a?(String) && value.encoding == Encoding::UTF_8 && value.valid_encoding?
        raise TextLiteralError, 'Text inside quotes must be valid UTF-8.'
      end
      raise TextLiteralError, 'Text values must stay on one line.' if value.include?("\n") || value.include?("\r")
      raise TextLiteralError, 'Text values do not use backslash escape sequences yet.' if value.include?('\\')
      raise TextLiteralError, 'Text interpolation is not supported yet.' if value.include?('#{')
      if value.include?('"')
        raise TextLiteralError, 'Text values cannot contain another straight double quote until escape sequences are supported.'
      end

      @value = value.freeze
      freeze
    end

    def self.quote_present?(text)
      supplied = text.to_s
      supplied.include?('"') || CURLY_QUOTES.any? { |quote| supplied.include?(quote) }
    end

    def self.parse_token(text)
      supplied = text.to_s
      if supplied.start_with?(*CURLY_QUOTES)
        raise TextLiteralError, 'Text values use straight double quotes, such as "North Gate".'
      end
      unless supplied.start_with?('"')
        raise TextLiteralError, 'Text values must begin with a straight double quote.'
      end

      closing = supplied.index('"', 1)
      raise TextLiteralError, 'Text value is missing its closing straight double quote.' unless closing

      remainder = supplied[(closing + 1)..].to_s
      unless remainder.empty?
        if remainder.lstrip.start_with?('+') || remainder.include?('"')
          raise TextLiteralError, 'Text concatenation is not supported yet. Use one quoted text value.'
        end
        raise TextLiteralError, 'Nothing may follow a quoted text value here.'
      end

      new(supplied[1...closing])
    end

    def self.parse_assignment(text)
      supplied = text.to_s
      if supplied.start_with?(*CURLY_QUOTES)
        raise TextLiteralError, 'Text values use straight double quotes, such as "North Gate".'
      end
      unless supplied.start_with?('"')
        raise TextLiteralError, 'A creator-facing text value must begin with a straight double quote.'
      end

      closing = supplied.index('"', 1)
      raise TextLiteralError, 'Text value is missing its closing straight double quote.' unless closing

      literal = new(supplied[1...closing])
      remainder = supplied[(closing + 1)..].to_s
      if remainder.lstrip.start_with?('+') || remainder.include?('"')
        raise TextLiteralError, 'Text concatenation is not supported yet. Use one quoted text value.'
      end

      value_name = remainder.strip
      if value_name.empty?
        raise TextLiteralError, 'Text value needs one value name after its closing quote, such as "North Gate" title.'
      end
      unless value_name.match?(/\A[a-zA-Z][a-zA-Z0-9]*\z/)
        raise TextLiteralError, 'Text value name must be one plain word after the closing quote.'
      end

      [literal, value_name.downcase]
    end

    def to_h
      { 'kind' => 'text', 'value' => value }
    end

    def quoted
      %Q{"#{value}"}
    end
  end
end

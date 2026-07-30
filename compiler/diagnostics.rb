# frozen_string_literal: true

module BasicSharp
  Diagnostic = Struct.new(:severity, :line_number, :message, keyword_init: true) do
    def key
      [severity, line_number, message]
    end

    def to_h
      { severity: severity, line_number: line_number, message: message }
    end

    def to_s
      line = line_number ? "line #{line_number}: " : ''
      "#{severity.upcase}: #{line}#{message}"
    end
  end

  class DiagnosticBag
    attr_reader :items

    def initialize
      @items = []
      @seen = {}
    end

    def error(line_number, message)
      add('error', line_number, message)
    end

    def warning(line_number, message)
      add('warning', line_number, message)
    end

    def any_errors?
      @items.any? { |d| d.severity == 'error' }
    end

    def to_h
      ordered_items.map(&:to_h)
    end

    private

    def add(severity, line_number, message)
      diagnostic = Diagnostic.new(severity: severity, line_number: line_number, message: message)
      return if @seen[diagnostic.key]

      @seen[diagnostic.key] = true
      @items << diagnostic
    end

    def ordered_items
      @items.sort_by do |diagnostic|
        [diagnostic.line_number || 0, diagnostic.severity == 'error' ? 0 : 1, diagnostic.message]
      end
    end
  end
end

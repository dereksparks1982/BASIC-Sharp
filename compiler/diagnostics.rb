# frozen_string_literal: true

module DKScript
  Diagnostic = Struct.new(:severity, :line_number, :message, keyword_init: true) do
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
    end

    def error(line_number, message)
      @items << Diagnostic.new(severity: 'error', line_number: line_number, message: message)
    end

    def warning(line_number, message)
      @items << Diagnostic.new(severity: 'warning', line_number: line_number, message: message)
    end

    def any_errors?
      @items.any? { |d| d.severity == 'error' }
    end

    def to_h
      @items.map(&:to_h)
    end
  end
end

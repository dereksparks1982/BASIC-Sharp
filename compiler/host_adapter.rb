# frozen_string_literal: true

module BasicSharp
  class HostAdapter
    attr_reader :commands

    def initialize
      @commands = []
    end

    def emit(command, details = {})
      entry = { 'command' => command.to_s }.merge(stringify_keys(details))
      @commands << entry.freeze
      entry
    end

    def drain
      drained = @commands.dup
      @commands.clear
      drained
    end

    private

    def stringify_keys(value)
      case value
      when Hash
        value.each_with_object({}) { |(key, entry), result| result[key.to_s] = stringify_keys(entry) }
      when Array
        value.map { |entry| stringify_keys(entry) }
      else
        value
      end
    end
  end
end

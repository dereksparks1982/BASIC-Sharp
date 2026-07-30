# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'basic_sharp_ir'

module BasicSharp
  class IREmitter
    def initialize(document)
      @document = document
    end

    def to_json
      JSON.pretty_generate(@document.to_h)
    end

    def write(path)
      dir = File.dirname(path)
      FileUtils.mkdir_p(dir) unless dir == '.' || Dir.exist?(dir)
      File.write(path, "#{to_json}\n")
      puts "wrote: #{path}"
    end
  end
end

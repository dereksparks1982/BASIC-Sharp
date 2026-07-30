# frozen_string_literal: true

require 'json'
require_relative 'dks_ir'

module DKScript
  class IREmitter
    def initialize(document)
      @document = document
    end

    def to_json
      JSON.pretty_generate(@document.to_h)
    end

    def write(path)
      File.write(path, "#{to_json}\n")
    end
  end
end

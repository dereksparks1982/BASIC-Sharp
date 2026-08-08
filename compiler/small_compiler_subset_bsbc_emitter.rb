# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'small_compiler_subset_ir_emitter'
require_relative 'bytecode_emitter'
require_relative 'bytecode_loader'

module BasicSharp
  class SmallCompilerSubsetBSBCEmitter
    FORMAT = 'bsharp.small_compiler_subset.bsbc_emitter.record'
    STATUS = 'bsbc_emission_under_ruby_referee'

    attr_reader :source, :ir_emitter, :bytecode_emitter, :bytecode_loader

    def initialize(source)
      @source = source
      @ir_emitter = SmallCompilerSubsetIREmitter.new(source)
      @bytecode_emitter = BytecodeEmitter.new(ir_emitter.bsharp_ir)
      @bytecode_loader = BytecodeLoader.new(binary, expected_fingerprint: bytecode_emitter.fingerprint)
    end

    def bsharp_ir
      ir_emitter.bsharp_ir
    end

    def binary
      bytecode_emitter.binary
    end

    def disassembly
      bytecode_emitter.disassembly
    end

    def profile
      bytecode_emitter.profile
    end

    def loader_summary
      stringify_keys(bytecode_loader.summary)
    end

    def to_h
      {
        format: FORMAT,
        version: BasicSharp::VERSION,
        status: STATUS,
        parser_ruby_referee_matches: ir_emitter.parser_matches_ruby_referee?,
        ir_ruby_referee_matches: ir_emitter.ir_matches_ruby_referee?,
        bsharp_ir_sha256: self.class.digest_json(bsharp_ir),
        profile: profile,
        binary_format: BytecodeContract::BINARY_FORMAT,
        binary_sha256: self.class.digest_binary(binary),
        binary_bytes: binary.bytesize,
        disassembly_sha256: self.class.digest_text(disassembly),
        fingerprint: bytecode_emitter.fingerprint,
        loader_summary: loader_summary,
        loader_summary_sha256: self.class.digest_json(loader_summary)
      }
    end

    def self.digest_binary(bytes)
      Digest::SHA256.hexdigest(bytes.b)
    end

    def self.digest_text(text)
      Digest::SHA256.hexdigest(text.to_s.encode('UTF-8'))
    end

    def self.digest_json(value)
      Digest::SHA256.hexdigest(JSON.generate(normalize(value)))
    end

    def self.normalize(value)
      case value
      when Hash
        value.each_with_object({}) { |(key, child), result| result[key.to_s] = normalize(child) }.sort.to_h
      when Array
        value.map { |child| normalize(child) }
      else
        value
      end
    end

    private

    def stringify_keys(value)
      case value
      when Hash
        value.each_with_object({}) { |(key, child), result| result[key.to_s] = stringify_keys(child) }
      when Array
        value.map { |child| stringify_keys(child) }
      else
        value
      end
    end
  end
end

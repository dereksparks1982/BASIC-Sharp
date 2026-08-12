# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'small_compiler_subset_ir_emitter'
require_relative 'small_compiler_subset_bsbc_encoder'
require_relative 'small_compiler_subset_bsbc_loader'
require_relative 'small_compiler_subset_bsbc_virtual_machine'
require_relative 'world_save'

module BasicSharp
  class SmallCompilerSubsetPipeline
    FORMAT = 'bsharp.small_compiler_subset.pipeline.record'
    STATUS = 'integrated_independent_pipeline_under_ruby_referee'

    attr_reader :source, :ir_emitter, :encoder, :loader, :virtual_machine

    def initialize(source)
      @source = source
      @ir_emitter = SmallCompilerSubsetIREmitter.new(source)
      @encoder = SmallCompilerSubsetBSBCEncoder.new(ir_emitter.bsharp_ir)
      @loader = SmallCompilerSubsetBSBCLoader.new(
        encoder.binary,
        expected_fingerprint: encoder.fingerprint
      )
      @virtual_machine = SmallCompilerSubsetBSBCVirtualMachine.new(loader)
    end

    def reader
      ir_emitter.subset_parser.reader
    end

    def parser
      ir_emitter.subset_parser
    end

    def native_dispatcher
      parser.native_dispatcher
    end

    def native_dispatch_invocation_count
      native_dispatcher.invocation_count
    end

    def native_semantic_router
      ir_emitter.native_semantic_router
    end

    def native_semantic_invocation_count
      native_semantic_router.invocation_count
    end

    def semantic_document
      ir_emitter.document
    end

    def bsharp_ir
      ir_emitter.bsharp_ir
    end

    def binary
      encoder.binary
    end

    def disassembly
      encoder.disassembly
    end

    def fingerprint
      encoder.fingerprint
    end

    def profile
      encoder.profile
    end

    def loader_summary
      stringify_keys(loader.summary)
    end

    def run_event(text)
      virtual_machine.run_event(text)
    end

    def snapshot
      virtual_machine.snapshot
    end

    def save_document
      WorldSave.document_for(virtual_machine)
    end

    def compile_record
      {
        format: FORMAT,
        version: BasicSharp::VERSION,
        status: STATUS,
        profile: profile,
        reader_record_count: reader.reader_records.length,
        statement_count: parser.statements.length,
        bsharp_ir_sha256: self.class.digest_json(bsharp_ir),
        binary_bytes: binary.bytesize,
        binary_sha256: self.class.digest_binary(binary),
        disassembly_sha256: self.class.digest_text(disassembly),
        fingerprint: fingerprint,
        loader_summary_sha256: self.class.digest_json(loader_summary)
      }
    end

    def self.digest_binary(value)
      Digest::SHA256.hexdigest(value.b)
    end

    def self.digest_text(value)
      Digest::SHA256.hexdigest(value.to_s.encode('UTF-8'))
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

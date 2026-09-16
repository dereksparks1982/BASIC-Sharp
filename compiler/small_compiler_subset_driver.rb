# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'small_compiler_subset_pipeline'
require_relative 'small_compiler_subset_bsbc_loader'
require_relative 'small_compiler_subset_bsbc_virtual_machine'

module BasicSharp
  class SmallCompilerSubsetDriverError < ArgumentError; end

  # Bounded Subset 0 compiler driver.
  #
  # The primary path is intentionally limited to the already-independent
  # SmallCompilerSubsetPipeline and its independent BSBC loader / VM. Production
  # compiler components remain separate referees in validation only.
  class SmallCompilerSubsetDriver
    FORMAT = 'bsharp.small_compiler_subset.driver.record'
    STATUS = 'independent_driver_and_artifact_round_trip_under_ruby_referee'

    attr_reader :source, :source_label, :pipeline, :artifact_path, :disassembly_path

    def self.from_file(path)
      expanded = File.expand_path(path)
      raise SmallCompilerSubsetDriverError, "BASIC# source file not found: #{path}" unless File.file?(expanded)

      source = File.read(expanded, encoding: 'UTF-8')
      new(source, source_label: expanded)
    rescue SystemCallError, EncodingError => error
      raise SmallCompilerSubsetDriverError, "BASIC# source could not be read: #{error.message}"
    end

    def initialize(source, source_label: '(memory)')
      unless source.is_a?(String)
        raise SmallCompilerSubsetDriverError, 'The independent BASIC# compiler driver requires BASIC# source text.'
      end

      @source = source.dup.freeze
      @source_label = source_label.to_s.freeze
      @pipeline = SmallCompilerSubsetPipeline.new(@source)
      @artifact_path = nil
      @disassembly_path = nil
    end

    def compile_to(path)
      destination = File.expand_path(path)
      unless destination.end_with?(BytecodeContract::EXTENSION)
        raise SmallCompilerSubsetDriverError,
              "Compiled BASIC# output must end with #{BytecodeContract::EXTENSION}."
      end

      written = pipeline.encoder.write(destination)
      @artifact_path, @disassembly_path = written.map { |entry| File.expand_path(entry) }
      verify_written_artifact!
      self
    rescue SmallCompilerSubsetDriverError
      raise
    rescue StandardError => error
      raise SmallCompilerSubsetDriverError, "Compiled BASIC# artifact was not written: #{error.message}"
    end

    def compiled?
      !artifact_path.nil? && File.file?(artifact_path)
    end

    def artifact_bytes
      ensure_compiled!
      File.binread(artifact_path)
    rescue SystemCallError => error
      raise SmallCompilerSubsetDriverError, "Compiled BASIC# artifact could not be read: #{error.message}"
    end

    def artifact_sha256
      Digest::SHA256.hexdigest(artifact_bytes.b)
    end

    def native_dispatcher
      pipeline.native_dispatcher
    end

    def native_dispatch_invocation_count
      pipeline.native_dispatch_invocation_count
    end

    def native_semantic_router
      pipeline.native_semantic_router
    end

    def native_semantic_invocation_count
      pipeline.native_semantic_invocation_count
    end

    def native_symbol_resolver
      pipeline.native_symbol_resolver
    end

    def native_symbol_invocation_count
      pipeline.native_symbol_invocation_count
    end


    def native_action_router
      pipeline.native_action_router
    end

    def native_action_invocation_count
      pipeline.native_action_invocation_count
    end

    def artifact_loader
      ensure_compiled!
      SmallCompilerSubsetBSBCLoader.read(
        artifact_path,
        expected_fingerprint: pipeline.fingerprint
      )
    end

    def artifact_virtual_machine
      SmallCompilerSubsetBSBCVirtualMachine.new(artifact_loader)
    end

    def fresh_in_memory_virtual_machine
      loader = SmallCompilerSubsetBSBCLoader.new(
        pipeline.binary,
        expected_fingerprint: pipeline.fingerprint
      )
      SmallCompilerSubsetBSBCVirtualMachine.new(loader)
    end

    def execute_in_memory(events)
      execute(fresh_in_memory_virtual_machine, events)
    end

    def execute_artifact(events)
      execute(artifact_virtual_machine, events)
    end

    def driver_record
      {
        format: FORMAT,
        version: BasicSharp::VERSION,
        status: STATUS,
        source_label: source_label,
        profile: pipeline.profile,
        fingerprint: pipeline.fingerprint,
        source_sha256: self.class.digest_text(source),
        bsharp_ir_sha256: self.class.digest_json(pipeline.bsharp_ir),
        binary_bytes: pipeline.binary.bytesize,
        binary_sha256: self.class.digest_binary(pipeline.binary),
        disassembly_sha256: self.class.digest_text(pipeline.disassembly),
        compiled: compiled?,
        artifact_sha256: compiled? ? artifact_sha256 : nil
      }
    end

    def self.digest_binary(value)
      Digest::SHA256.hexdigest(value.b)
    end

    def self.digest_text(value)
      Digest::SHA256.hexdigest(value.to_s.encode('UTF-8'))
    end

    def self.digest_json(value)
      Digest::SHA256.hexdigest(JSON.generate(SmallCompilerSubsetPipeline.normalize(value)))
    end

    private

    def ensure_compiled!
      return if compiled?

      raise SmallCompilerSubsetDriverError, 'Compile the BASIC# source to a .bsbc artifact before loading it.'
    end

    def verify_written_artifact!
      unless File.file?(artifact_path) && File.file?(disassembly_path)
        raise SmallCompilerSubsetDriverError, 'The independent compiler did not produce both BSBC and readable disassembly artifacts.'
      end
      unless artifact_bytes == pipeline.binary
        raise SmallCompilerSubsetDriverError, 'The saved BSBC artifact differs from the independently compiled in-memory bytes.'
      end
      unless File.read(disassembly_path, encoding: 'UTF-8') == pipeline.disassembly
        raise SmallCompilerSubsetDriverError, 'The saved BSBC disassembly differs from the independently compiled disassembly.'
      end

      true
    end

    def execute(machine, events)
      results = Array(events).map { |event| machine.run_event(event) }
      {
        'events' => results,
        'snapshot' => machine.snapshot,
        'save' => WorldSave.document_for(machine)
      }
    end
  end
end

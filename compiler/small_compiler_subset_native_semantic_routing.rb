# frozen_string_literal: true

require_relative 'small_compiler_subset_bsbc_loader'
require_relative 'small_compiler_subset_bsbc_virtual_machine'

module BasicSharp
  class SmallCompilerSubsetNativeSemanticRoutingError < ArgumentError; end

  # Executes the checked-in BASIC#-authored semantic routing component and
  # returns the resolver route selected by that persisted BSBC artifact.
  #
  # Ruby derives only the neutral semantic input name from the AST class name.
  # It must not maintain a second AST-type-to-route answer table or silently
  # fall back when the native artifact does not recognize an input.
  class SmallCompilerSubsetNativeSemanticRouting
    DEFAULT_ARTIFACT_PATH = File.expand_path('native/first_bsharp_semantic_router.bsbc', __dir__).freeze
    DECISION_OBJECT = 'semantic decision'
    DECISION_VALUE = 'classification'
    THREAD_ARTIFACT_KEY = :basic_sharp_small_compiler_subset_native_semantic_routing_artifact

    Route = Struct.new(:semantic_name, :decision, :event_result, keyword_init: true) do
      def to_h
        {
          semantic_name: semantic_name,
          decision: decision,
          matched: event_result.fetch('matched')
        }
      end
    end

    attr_reader :artifact_path, :loader, :invocation_count, :matched_count, :rejected_count

    def self.current_artifact_path
      Thread.current[THREAD_ARTIFACT_KEY] || DEFAULT_ARTIFACT_PATH
    end

    def self.with_artifact_path(path)
      previous = Thread.current[THREAD_ARTIFACT_KEY]
      Thread.current[THREAD_ARTIFACT_KEY] = File.expand_path(path)
      yield
    ensure
      Thread.current[THREAD_ARTIFACT_KEY] = previous
    end

    def initialize(artifact_path: self.class.current_artifact_path)
      @artifact_path = File.expand_path(artifact_path)
      @loader = SmallCompilerSubsetBSBCLoader.read(@artifact_path)
      @invocation_count = 0
      @matched_count = 0
      @rejected_count = 0
    rescue SmallCompilerSubsetBSBCLoaderError => error
      raise SmallCompilerSubsetNativeSemanticRoutingError,
            "BASIC# native semantic routing artifact could not be loaded: #{error.message}"
    end

    def route(entry)
      semantic_name = semantic_name_for(entry)
      return reject unless semantic_name

      @invocation_count += 1
      machine = SmallCompilerSubsetBSBCVirtualMachine.new(loader)
      result = machine.run_event("player examines #{semantic_name} semantic")
      return reject unless result.fetch('matched')

      decision = decision_from(machine)
      if decision.to_s.empty? || decision == 'unclassified'
        raise SmallCompilerSubsetNativeSemanticRoutingError,
              "BASIC# native semantic routing matched #{semantic_name} without returning a resolver decision."
      end

      @matched_count += 1
      Route.new(semantic_name: semantic_name, decision: decision, event_result: result)
    rescue SmallCompilerSubsetBSBCVirtualMachineError => error
      raise SmallCompilerSubsetNativeSemanticRoutingError,
            "BASIC# native semantic routing could not execute: #{error.message}"
    end

    def to_h
      {
        artifact_path: artifact_path,
        fingerprint: loader.fingerprint,
        invocation_count: invocation_count,
        matched_count: matched_count,
        rejected_count: rejected_count
      }
    end

    private

    def semantic_name_for(entry)
      class_name = entry.class.name.to_s.split('::').last
      return nil if class_name.empty?

      class_name
        .gsub(/([a-z0-9])([A-Z])/, '\\1 \\2')
        .downcase
    end

    def reject
      @rejected_count += 1
      nil
    end

    def decision_from(machine)
      object = machine.snapshot.find { |entry| entry.fetch('name') == DECISION_OBJECT }
      unless object
        raise SmallCompilerSubsetNativeSemanticRoutingError,
              "BASIC# native semantic routing object is missing: #{DECISION_OBJECT}"
      end

      object.fetch('values').fetch(DECISION_VALUE)
    rescue KeyError
      raise SmallCompilerSubsetNativeSemanticRoutingError,
            "BASIC# native semantic routing value is missing: #{DECISION_VALUE}"
    end
  end
end

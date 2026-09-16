# frozen_string_literal: true

require_relative 'small_compiler_subset_bsbc_loader'
require_relative 'small_compiler_subset_bsbc_virtual_machine'

module BasicSharp
  class SmallCompilerSubsetNativeActionRoutingError < ArgumentError; end

  # Executes the checked-in BASIC#-authored action routing component.
  # Ruby supplies only the normalized action word as a neutral observation;
  # the BASIC# BSBC artifact chooses the action-family resolver route.
  class SmallCompilerSubsetNativeActionRouting
    DEFAULT_ARTIFACT_PATH = File.expand_path('native/first_bsharp_action_router.bsbc', __dir__).freeze
    DECISION_OBJECT = 'action decision'
    DECISION_VALUE = 'classification'
    THREAD_ARTIFACT_KEY = :basic_sharp_small_compiler_subset_native_action_routing_artifact

    Route = Struct.new(:verb, :decision, :event_result, keyword_init: true) do
      def to_h
        { verb: verb, decision: decision, matched: event_result.fetch('matched') }
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
      raise SmallCompilerSubsetNativeActionRoutingError,
            "BASIC# native action routing artifact could not be loaded: #{error.message}"
    end

    def route(action)
      verb = normalize_verb(action.verb)
      @invocation_count += 1
      machine = SmallCompilerSubsetBSBCVirtualMachine.new(loader)
      result = machine.run_event("player examines #{verb} action")
      unless result.fetch('matched')
        @rejected_count += 1
        return nil
      end

      decision = decision_from(machine)
      if decision.to_s.empty? || decision == 'unclassified'
        raise SmallCompilerSubsetNativeActionRoutingError,
              "BASIC# native action routing matched #{verb} without returning a resolver decision."
      end

      @matched_count += 1
      Route.new(verb: verb, decision: decision, event_result: result)
    rescue SmallCompilerSubsetBSBCVirtualMachineError => error
      raise SmallCompilerSubsetNativeActionRoutingError,
            "BASIC# native action routing could not execute: #{error.message}"
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

    def normalize_verb(value)
      value.to_s.strip.downcase.sub(/^\(/, '')
    end

    def decision_from(machine)
      object = machine.snapshot.find { |entry| entry.fetch('name') == DECISION_OBJECT }
      raise SmallCompilerSubsetNativeActionRoutingError, "BASIC# native action routing object is missing: #{DECISION_OBJECT}" unless object

      object.fetch('values').fetch(DECISION_VALUE)
    rescue KeyError
      raise SmallCompilerSubsetNativeActionRoutingError, "BASIC# native action routing value is missing: #{DECISION_VALUE}"
    end
  end
end

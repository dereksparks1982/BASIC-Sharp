# frozen_string_literal: true

require_relative 'small_compiler_subset_bsbc_loader'
require_relative 'small_compiler_subset_bsbc_virtual_machine'

module BasicSharp
  class SmallCompilerSubsetNativeSymbolResolutionError < ArgumentError; end

  # Executes the checked-in BASIC#-authored symbol decision component.
  #
  # Ruby may provide neutral observations already available at this bounded
  # bootstrap stage (known/unknown, unique/duplicate, valid/invalid link). The
  # BASIC# artifact must participate in the final symbol decision and every
  # observation/decision mismatch fails closed. No caller may silently replace
  # a missing or wrong native decision with a Ruby answer.
  class SmallCompilerSubsetNativeSymbolResolution
    DEFAULT_ARTIFACT_PATH = File.expand_path('native/first_bsharp_symbol_resolver.bsbc', __dir__).freeze
    DECISION_OBJECT = 'symbol decision'
    DECISION_VALUE = 'classification'
    THREAD_ARTIFACT_KEY = :basic_sharp_small_compiler_subset_native_symbol_resolution_artifact

    PROBES = {
      known_kind: ['known kind symbol', 'resolve-known-kind'],
      unknown_kind: ['unknown kind symbol', 'reject-unknown-kind'],
      unique_kind: ['unique kind symbol', 'accept-unique-kind'],
      duplicate_kind: ['duplicate kind symbol', 'reject-duplicate-kind'],
      valid_kind_link: ['valid kind link symbol', 'accept-kind-link'],
      invalid_kind_link: ['invalid kind link symbol', 'reject-kind-link'],
      known_thing: ['known thing symbol', 'resolve-known-thing'],
      unknown_thing: ['unknown thing symbol', 'reject-unknown-thing'],
      unique_thing: ['unique thing symbol', 'accept-unique-thing'],
      duplicate_thing: ['duplicate thing symbol', 'reject-duplicate-thing'],
      builtin_player: ['builtin player symbol', 'resolve-builtin-player'],
      known_action: ['known action symbol', 'resolve-known-action'],
      unknown_action: ['unknown action symbol', 'reject-unknown-action'],
      valid_value: ['valid value symbol', 'resolve-value'],
      invalid_value: ['invalid value symbol', 'reject-invalid-value']
    }.freeze

    Decision = Struct.new(:probe, :decision, :event_result, keyword_init: true) do
      def to_h
        { probe: probe.to_s, decision: decision, matched: event_result.fetch('matched') }
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
      @machine = SmallCompilerSubsetBSBCVirtualMachine.new(loader)
    rescue SmallCompilerSubsetBSBCLoaderError => error
      raise SmallCompilerSubsetNativeSymbolResolutionError,
            "BASIC# native symbol artifact could not be loaded: #{error.message}"
    end

    def decide(probe)
      probe = probe.to_sym
      protocol = PROBES[probe]
      return reject(probe) unless protocol

      target_name, expected_decision = protocol
      @invocation_count += 1
      result = @machine.run_event("player examines #{target_name}")
      return reject(probe) unless result.fetch('matched')

      decision = decision_from(@machine)
      if decision.to_s.empty? || decision == 'unclassified'
        raise SmallCompilerSubsetNativeSymbolResolutionError,
              "BASIC# native symbol decision matched #{probe} without returning a decision."
      end
      unless decision == expected_decision
        raise SmallCompilerSubsetNativeSymbolResolutionError,
              "BASIC# native symbol decision for #{probe} returned '#{decision}'; expected '#{expected_decision}'."
      end

      @matched_count += 1
      Decision.new(probe: probe, decision: decision, event_result: result)
    rescue SmallCompilerSubsetBSBCVirtualMachineError => error
      raise SmallCompilerSubsetNativeSymbolResolutionError,
            "BASIC# native symbol decision could not execute: #{error.message}"
    end

    def known_kind?(known)
      decide(known ? :known_kind : :unknown_kind)
      !!known
    end

    def unique_kind?(duplicate)
      decide(duplicate ? :duplicate_kind : :unique_kind)
      !duplicate
    end

    def valid_kind_link?(valid)
      decide(valid ? :valid_kind_link : :invalid_kind_link)
      !!valid
    end

    def known_thing?(known)
      decide(known ? :known_thing : :unknown_thing)
      !!known
    end

    def unique_thing?(duplicate)
      decide(duplicate ? :duplicate_thing : :unique_thing)
      !duplicate
    end

    def builtin_player!
      decide(:builtin_player)
      true
    end

    def known_action?(known)
      decide(known ? :known_action : :unknown_action)
      !!known
    end

    def valid_value?(valid)
      decide(valid ? :valid_value : :invalid_value)
      !!valid
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

    def reject(probe)
      @rejected_count += 1
      raise SmallCompilerSubsetNativeSymbolResolutionError,
            "BASIC# native symbol decision does not recognize probe '#{probe}'."
    end

    def decision_from(machine)
      object = machine.snapshot.find { |entry| entry.fetch('name') == DECISION_OBJECT }
      unless object
        raise SmallCompilerSubsetNativeSymbolResolutionError,
              "BASIC# native symbol decision object is missing: #{DECISION_OBJECT}"
      end
      object.fetch('values').fetch(DECISION_VALUE)
    rescue KeyError
      raise SmallCompilerSubsetNativeSymbolResolutionError,
            "BASIC# native symbol decision value is missing: #{DECISION_VALUE}"
    end
  end
end

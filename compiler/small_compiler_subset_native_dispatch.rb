# frozen_string_literal: true

require_relative 'small_compiler_subset_bsbc_loader'
require_relative 'small_compiler_subset_bsbc_virtual_machine'

module BasicSharp
  class SmallCompilerSubsetNativeDispatchError < ArgumentError; end

  # Executes the checked-in BASIC#-authored compiler decision component and
  # returns the parser route selected by that persisted BSBC artifact.
  #
  # The Ruby parser may validate the shape required by a returned route, but it
  # must not maintain a second accepted-head-to-route table or silently fall
  # back when the native artifact does not recognize a head.
  class SmallCompilerSubsetNativeDispatch
    DEFAULT_ARTIFACT_PATH = File.expand_path('native/first_bsharp_compiler_component.bsbc', __dir__).freeze
    DECISION_OBJECT = 'compiler decision'
    DECISION_VALUE = 'classification'
    THREAD_ARTIFACT_KEY = :basic_sharp_small_compiler_subset_native_dispatch_artifact

    Dispatch = Struct.new(:head_word, :decision, :event_result, keyword_init: true) do
      def to_h
        {
          head_word: head_word,
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
      raise SmallCompilerSubsetNativeDispatchError,
            "BASIC# native parser dispatch artifact could not be loaded: #{error.message}"
    end

    def dispatch(text)
      head_word = extract_head_word(text)
      return reject unless head_word

      @invocation_count += 1
      machine = SmallCompilerSubsetBSBCVirtualMachine.new(loader)
      result = machine.run_event("player examines #{head_word.downcase} head")
      return reject unless result.fetch('matched')

      decision = decision_from(machine)
      if decision.to_s.empty? || decision == 'unclassified'
        raise SmallCompilerSubsetNativeDispatchError,
              "BASIC# native parser dispatch matched #{head_word} without returning a parser decision."
      end

      @matched_count += 1
      Dispatch.new(head_word: head_word, decision: decision, event_result: result)
    rescue SmallCompilerSubsetBSBCVirtualMachineError => error
      raise SmallCompilerSubsetNativeDispatchError,
            "BASIC# native parser dispatch could not execute: #{error.message}"
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

    def extract_head_word(text)
      text.to_s[/\A([A-Z]+)\b/, 1]
    end

    def reject
      @rejected_count += 1
      nil
    end

    def decision_from(machine)
      object = machine.snapshot.find { |entry| entry.fetch('name') == DECISION_OBJECT }
      unless object
        raise SmallCompilerSubsetNativeDispatchError,
              "BASIC# native parser dispatch object is missing: #{DECISION_OBJECT}"
      end

      object.fetch('values').fetch(DECISION_VALUE)
    rescue KeyError
      raise SmallCompilerSubsetNativeDispatchError,
            "BASIC# native parser dispatch value is missing: #{DECISION_VALUE}"
    end
  end
end

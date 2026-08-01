# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'runtime'
require_relative 'world_save'
require_relative 'bytecode_emitter'
require_relative 'bytecode_loader'
require_relative 'bytecode_virtual_machine'

module BasicSharp
  class RuntimeTransitionError < ArgumentError; end

  # Routes resolved BASIC# source or saved BSIR, including Profile 6 compound
  # IF conditions, through the preferred BSharp VM.
  # The reference Ruby runtime remains available only by explicit request or as
  # a shadow oracle for deterministic parity verification.
  class RuntimeTransition
    MODES = %i[preferred reference verify].freeze
    PARITY_IGNORED_KEYS = %w[line_number caused_by_line].freeze

    attr_reader :mode, :loader

    def initialize(document, world_save: nil, mode: :preferred)
      @document = document
      validate_document_identity!
      @mode = mode.to_sym
      unless MODES.include?(@mode)
        raise RuntimeTransitionError, "Unknown BASIC# runtime mode: #{@mode}"
      end

      @base_world_save = deep_copy(world_save)
      @event_history = []
      build_initial_machines!
    end

    def preferred?
      mode == :preferred || mode == :verify
    end

    def reference?
      mode == :reference
    end

    def verifying?
      mode == :verify
    end

    def startup_ran
      active_machine.startup_ran
    end

    def startup_if_rules
      active_machine.startup_if_rules
    end

    def startup_if_error
      active_machine.startup_if_error
    end

    def startup_follow_up_events
      active_machine.startup_follow_up_events
    end

    def run_event(text)
      return active_machine.run_event(text) unless verifying?

      preferred, reference, loader = replay_verified_pair
      preferred_result = preferred.run_event(text)
      reference_result = reference.run_event(text)
      verify_equal!('event result', semantic_result(reference_result), semantic_result(preferred_result))
      verify_machine_state!(preferred, reference, area: 'world after event')

      @preferred_machine = preferred
      @reference_machine = reference
      @loader = loader
      @event_history << text.to_s
      preferred_result
    end

    def snapshot
      verified_call('world snapshot', :snapshot)
    end

    def program_fingerprint
      verified_call('program fingerprint', :program_fingerprint)
    end

    def meaning_profile
      verified_call('meaning profile', :meaning_profile)
    end

    def save_ready?
      verified_call('save readiness', :save_ready?)
    end

    def world_save_state
      verified_call('BSharp Save world state', :world_save_state)
    end

    def write_world_save(path)
      WorldSave.write(path, self)
    end

    def restore_world_save!(document)
      unless verifying?
        active_machine.restore_world_save!(document)
        @base_world_save = deep_copy(document)
        @event_history.clear
        return self
      end

      preferred, reference, loader = build_pair(world_save: document)
      verify_machine_state!(preferred, reference, area: 'restored world')
      @preferred_machine = preferred
      @reference_machine = reference
      @loader = loader
      @base_world_save = deep_copy(document)
      @event_history.clear
      self
    end

    def ask_thing(name)
      verified_call('ASK Thing answer', :ask_thing, name)
    end

    def ask_kind(name)
      verified_call('ASK Kind answer', :ask_kind, name)
    end

    def ask_resolve_kind(text)
      verified_call('ASK Kind resolution', :ask_resolve_kind, text)
    end

    def ask_kind_members(kind_text)
      verified_call('ASK Kind membership', :ask_kind_members, kind_text)
    end

    def ask_event_match(event_text)
      verified_call('ASK event match', :ask_event_match, event_text)
    end

    def ask_if_rules
      verified_call('ASK IF rules', :ask_if_rules)
    end

    def game_declarations
      verified_call('ASK game declarations', :game_declarations)
    end

    def ask_world_summary
      verified_call('ASK world summary', :ask_world_summary)
    end

    def ask_save_summary
      verified_call('ASK save summary', :ask_save_summary)
    end

    def report(event_result)
      active_machine.report(event_result)
    end

    private


    def validate_document_identity!
      raw = @document.respond_to?(:to_h) ? @document.to_h : @document
      return unless raw.is_a?(Hash)

      format = raw['format'] || raw[:format]
      normalized = format.to_s.strip.downcase
      raise RetiredDKIRFormatError, Runtime::RETIRED_DKIR_MESSAGE if normalized == 'dkir.debug.json'
    end

    def build_initial_machines!
      if reference?
        @reference_machine = Runtime.new(@document, world_save: deep_copy(@base_world_save))
        @preferred_machine = nil
        @loader = nil
      elsif verifying?
        @preferred_machine, @reference_machine, @loader = build_pair(world_save: @base_world_save)
        verify_machine_state!(@preferred_machine, @reference_machine, area: 'startup world')
      else
        @preferred_machine, @loader = build_preferred(world_save: @base_world_save)
        @reference_machine = nil
      end
    end

    def active_machine
      reference? ? @reference_machine : @preferred_machine
    end

    def build_preferred(world_save: nil)
      emitter = BytecodeEmitter.new(@document)
      loader = BytecodeLoader.new(
        emitter.binary,
        source_label: '(in-memory preferred runtime bytecode)',
        expected_fingerprint: emitter.fingerprint
      )
      [BytecodeVirtualMachine.new(loader, world_save: deep_copy(world_save)), loader]
    end

    def build_pair(world_save: nil)
      preferred, loader = build_preferred(world_save: world_save)
      reference = Runtime.new(@document, world_save: deep_copy(world_save))
      [preferred, reference, loader]
    end

    def replay_verified_pair
      preferred, reference, loader = build_pair(world_save: @base_world_save)
      verify_machine_state!(preferred, reference, area: 'startup world')
      @event_history.each_with_index do |event, index|
        preferred_result = preferred.run_event(event)
        reference_result = reference.run_event(event)
        verify_equal!("replayed event #{index + 1}", semantic_result(reference_result), semantic_result(preferred_result))
        verify_machine_state!(preferred, reference, area: "world after replayed event #{index + 1}")
      end
      [preferred, reference, loader]
    end

    def verify_machine_state!(preferred, reference, area:)
      verify_equal!(area, reference.snapshot, preferred.snapshot)
      verify_equal!('startup actions', parity_value(reference.startup_ran), parity_value(preferred.startup_ran))
      verify_equal!('startup IF rules', parity_value(reference.startup_if_rules), parity_value(preferred.startup_if_rules))
      verify_equal!('startup IF error', reference.startup_if_error, preferred.startup_if_error)
      verify_equal!(
        'startup follow-up events',
        parity_value(reference.startup_follow_up_events),
        parity_value(preferred.startup_follow_up_events)
      )
      verify_equal!('IF truth and active state', reference.ask_if_rules, preferred.ask_if_rules)
      verify_equal!('save readiness', reference.save_ready?, preferred.save_ready?)
      verify_equal!('program fingerprint', reference.program_fingerprint, preferred.program_fingerprint)
    end

    def verified_call(area, method, *arguments)
      preferred_value = @preferred_machine.public_send(method, *arguments) if @preferred_machine
      reference_value = @reference_machine.public_send(method, *arguments) if @reference_machine
      return reference_value if reference?
      return preferred_value unless verifying?

      verify_equal!(area, parity_value(reference_value), parity_value(preferred_value))
      preferred_value
    end

    def semantic_result(result)
      value = parity_value(result)
      return value unless value.is_a?(Hash)

      value.reject { |key, _| key == 'state' }.merge('state' => value['state'])
    end

    def parity_value(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, entry), result|
          key = key.to_s
          next if PARITY_IGNORED_KEYS.include?(key)

          result[key] = parity_value(entry)
        end
      when Array
        value.map { |entry| parity_value(entry) }
      when Symbol
        value.to_s
      else
        value
      end
    end

    def verify_equal!(area, reference_value, preferred_value)
      return true if reference_value == preferred_value

      reference_hash = digest(reference_value)
      preferred_hash = digest(preferred_value)
      raise RuntimeTransitionError,
            "BASIC# stopped because the BSharp VM and reference runtime disagreed.\n" \
            "Area: #{area}\n" \
            "Reference result: #{reference_hash}\n" \
            "BSharp VM result: #{preferred_hash}\n" \
            'The program was not allowed to continue in parity-verification mode.'
    end

    def digest(value)
      Digest::SHA256.hexdigest(JSON.generate(value))[0, 16]
    end

    def deep_copy(value)
      return nil if value.nil?

      JSON.parse(JSON.generate(value))
    end
  end
end

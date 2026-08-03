# frozen_string_literal: true

require 'benchmark'
require 'digest'
require 'json'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/world_save'
require_relative '../compiler/ask'
require_relative '../compiler/game_input'

module BasicSharp
  module TrialByFire
    ROOT = File.expand_path('..', __dir__)
    DEFAULT_SEED = 0xB5_01_40
    MAX_WHOLE_NUMBER = 2_147_483_647
    PROFILE_PAIRS = (1..7).to_h do |number|
      [number, ["bsharp.meaning.v#{number}", "bsharp.bytecode.v#{number}"]]
    end.freeze
    PRINCIPAL_SOURCE = File.join(ROOT, 'samples/trial_by_fire.bsharp')
    GOLDEN_TRACE = File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_GOLDEN_TRACE_v1.json')
    COVERAGE_MATRIX = File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_COVERAGE_MATRIX_v1.json')
    VALIDATION_INVENTORY = File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json')

    CAMPAIGN_EVENTS = [
      'player attacks mara',
      'player sounds brass bell',
      'player opens north gate',
      'player sounds brass bell',
      'player sounds brass bell',
      'player closes north gate',
      'player takes iron key'
    ].freeze
    ASK_QUESTIONS = [
      'what is player',
      'what is mara',
      'what Things are guards',
      'what happens when player attacks mara',
      'what IF rules are true',
      'what IF rules are false',
      'what game systems are declared',
      'what is the world'
    ].freeze
    PROFILE_ARTIFACT_NAMES = %w[
      first_room text_values demon_killer_controls platform_movement
      number_changes compound_if_conditions otherwise_branches
    ].freeze

    module_function

    def assert!(condition, message)
      raise "TRIAL BY FIRE: #{message}" unless condition
    end

    def env_count(name, default, minimum: 1)
      value = Integer(ENV.fetch(name, default.to_s), 10)
      raise ArgumentError, "#{name} must be at least #{minimum}" if value < minimum
      value
    rescue ArgumentError
      raise ArgumentError, "#{name} must be a whole number at least #{minimum}"
    end

    def source
      File.binread(PRINCIPAL_SOURCE).force_encoding(Encoding::UTF_8)
    end

    def resolve_source(source_text)
      raise ArgumentError, 'BASIC# source is not valid UTF-8' unless source_text.valid_encoding?
      parser = Parser.new(source_text)
      document = SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
      diagnostics = document.diagnostics.select { |entry| %w[error warning].include?(entry.severity) }
      raise ArgumentError, diagnostics.map(&:message).join("\n") unless diagnostics.empty?
      document
    end

    def document
      @document ||= resolve_source(source)
    end

    def saved_bsir(document_value = document)
      JSON.parse(canonical_json(document_value.to_h))
    end

    def canonical_json(value)
      "#{JSON.pretty_generate(value)}\n"
    end

    def semantic_result(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, entry), result|
          next if %w[line_number caused_by_line raw created_by_basic_sharp version].include?(key.to_s)
          result[key.to_s] = semantic_result(entry)
        end
      when Array then value.map { |entry| semantic_result(entry) }
      when Symbol then value.to_s
      else value
      end
    end

    def semantic_sha256(value)
      Digest::SHA256.hexdigest(JSON.generate(semantic_result(value)))
    end

    def compact_world(snapshot)
      snapshot.map do |thing|
        entry = {
          'name' => thing.fetch('name'),
          'kind' => thing.fetch('kind'),
          'states' => thing.fetch('states'),
          'relations' => thing.fetch('relations'),
          'values' => thing.fetch('values')
        }
        entry
      end
    end

    def campaign_trace(document_value = document)
      reference = Runtime.new(document_value)
      bsir_runtime = Runtime.new(saved_bsir(document_value))
      emitter = BytecodeEmitter.new(document_value)
      loader = BytecodeLoader.new(emitter.binary, expected_fingerprint: emitter.fingerprint)
      machine = BytecodeVirtualMachine.new(loader)
      event_trace = CAMPAIGN_EVENTS.map do |event|
        reference_result = reference.run_event(event)
        bsir_result = bsir_runtime.run_event(event)
        machine_result = machine.run_event(event)
        normalized = semantic_result(machine_result)
        assert!(semantic_result(reference_result) == normalized, "source/reference parity changed during '#{event}'")
        assert!(semantic_result(bsir_result) == normalized, "saved-BSIR parity changed during '#{event}'")
        {
          'input' => event,
          'matched' => normalized.fetch('matched'),
          'matched_when' => normalized['matched_when'],
          'if_conditions' => normalized.fetch('if_rules', []).map { |entry| entry['condition'] },
          'follow_ups' => normalized.fetch('follow_up_events', []).map do |entry|
            {
              'event' => entry['event'],
              'matched' => entry['matched'],
              'matched_when' => entry['matched_when']
            }
          end,
          'error' => normalized['error'],
          'world' => compact_world(machine.snapshot)
        }
      end

      reference_answers = Ask.new(reference).answer_many(ASK_QUESTIONS)
      bsir_answers = Ask.new(bsir_runtime).answer_many(ASK_QUESTIONS)
      machine_answers = Ask.new(machine).answer_many(ASK_QUESTIONS)
      assert!(reference_answers == machine_answers, 'reference ASK parity changed')
      assert!(bsir_answers == machine_answers, 'saved-BSIR ASK parity changed')
      before_ask = machine.snapshot
      Ask.new(machine).answer_many(ASK_QUESTIONS)
      assert!(machine.snapshot == before_ask, 'ASK mutated the principal world')

      save = WorldSave.document_for(machine)
      restored = BytecodeVirtualMachine.new(loader, world_save: save)
      assert!(restored.snapshot == machine.snapshot, 'Save restore changed the final world')
      assert!(restored.ask_if_rules == machine.ask_if_rules, 'Save restore changed reactive branch state')

      {
        'format' => 'bsharp.trial_by_fire.trace.json',
        'format_version' => 1,
        'meaning_profile' => document_value.meaning_profile,
        'bytecode_profile' => loader.model.fetch(:profile),
        'events' => event_trace,
        'ask_questions' => ASK_QUESTIONS,
        'ask_sha256' => semantic_sha256(machine_answers),
        'final_world' => compact_world(machine.snapshot),
        'final_if_rules' => semantic_result(machine.ask_if_rules),
        'save_sha256' => semantic_sha256(save),
        'bytecode_sha256' => Digest::SHA256.hexdigest(emitter.binary),
        'disassembly_sha256' => Digest::SHA256.hexdigest(emitter.disassembly)
      }
    end

    def verify_golden_trace!
      expected = JSON.parse(File.read(GOLDEN_TRACE))
      actual = campaign_trace
      assert!(actual == expected, 'principal campaign no longer matches the independently locked golden trace')
      actual
    end

    def generated_profile(index)
      (Integer(index) % 7) + 1
    end

    def generated_parameters(index, seed: DEFAULT_SEED)
      number = Integer(index)
      raise ArgumentError, 'program index must be from 0 through 255' unless number.between?(0, 255)
      salt = ((Integer(seed) ^ (number * 1_103_515_245)) + 12_345) & 0x7fff_ffff
      {
        number: number,
        profile: generated_profile(number),
        salt: salt,
        kind_depth: 2 + (salt % 4),
        object_count: 1 + ((salt >> 3) % 5),
        score: 1 + ((salt >> 7) % 9),
        damage: 1 + ((salt >> 11) % 3),
        left_speed: 2 + ((salt >> 13) % 8),
        right_speed: 2 + ((salt >> 17) % 8),
        jump_speed: 5 + ((salt >> 21) % 10),
        connector: ((salt >> 25) & 1).zero? ? 'and' : 'or'
      }
    end

    def generated_source(index, seed: DEFAULT_SEED)
      p = generated_parameters(index, seed: seed)
      n = format('%03d', p.fetch(:number))
      root_kind = "trialguard#{n}level0"
      kinds = p.fetch(:kind_depth).times.map do |depth|
        parent = depth.zero? ? 'guard' : "trialguard#{n}level#{depth - 1}"
        "    #trialguard#{n}level#{depth} is a ##{parent}"
      end
      deepest_kind = "trialguard#{n}level#{p.fetch(:kind_depth) - 1}"
      objects = p.fetch(:object_count).times.map do |object_index|
        "    @trialguard#{n}thing#{object_index} is a ##{deepest_kind}"
      end
      objects << "    @trialswitch#{n} is a #device"
      start = [
        "    PLAYER has #{p.fetch(:score)} score",
        '    PLAYER has 0 wins',
        '    PLAYER has 0 losses'
      ]
      p.fetch(:object_count).times { |object_index| start << "    @trialguard#{n}thing#{object_index} is calm" }
      start << "    PLAYER has \"Seed #{seed}; case #{n}; exact text.\" label" if p.fetch(:profile) >= 2

      controls = case p.fetch(:profile)
                 when 3
                   <<~CONTROL
                     CONTROLS for PLAYER
                     [
                         W moves PLAYER north
                         S moves PLAYER south
                         A moves PLAYER west
                         D moves PLAYER east
                     ].
                   CONTROL
                 when 4..7
                   <<~CONTROL
                     CONTROLS for PLAYER
                     [
                         A moves PLAYER left at #{p.fetch(:left_speed)} speed
                         D moves PLAYER right at #{p.fetch(:right_speed)} speed
                         SPACE makes PLAYER jump at #{p.fetch(:jump_speed)} speed
                     ].
                   CONTROL
                 else ''
                 end

      exact_actions = ["    |then (change every ##{root_kind} to angry"]
      exact_actions << "    |then (damage every ##{root_kind} by #{p.fetch(:damage)}"
      case p.fetch(:profile)
      when 1
        exact_actions << "    |then (change score of PLAYER to #{p.fetch(:score) + 1}"
      when 2
        exact_actions << "    |then (change label of PLAYER to \"Case #{n} changed; spaces stay exact.\""
      when 3, 4
        exact_actions << '    |then (change PLAYER to on'
      else
        exact_actions << '    |then (increase score of PLAYER by 1'
      end

      condition = if p.fetch(:profile) >= 6
                    comparison = p.fetch(:connector) == 'and' ? "at least #{p.fetch(:score) + 1}" : "more than #{p.fetch(:score) + 8}"
                    "IF PLAYER has #{comparison} score #{p.fetch(:connector)} @trialguard#{n}thing0 is angry"
                  elsif p.fetch(:profile) == 5
                    "IF PLAYER has at least #{p.fetch(:score) + 1} score"
                  end
      reactive = if condition
                   branch = <<~RULE
                     #{condition}
                     [
                         |then (increase wins of PLAYER by 1
                     ].
                   RULE
                   if p.fetch(:profile) == 7
                     branch + <<~BRANCH_TEXT
                       OTHERWISE
                       [
                           |then (increase losses of PLAYER by 1
                       ].
                     BRANCH_TEXT
                   else
                     branch
                   end
                 else ''
                 end

      <<~BSHARP
        //Deterministic BASIC# v#{BasicSharp::VERSION} seed #{seed}, program #{n}, Profile #{p.fetch(:profile)}./.
        KINDS
        [
        #{kinds.join("\n")}
        ].
        DEFINE
        [
        #{objects.join("\n")}
        ].
        START
        [
        #{start.join("\n")}
        ].
        #{controls}
        WHEN PLAYER attacks a #device
        [
            |then (damage PLAYER
        ].
        WHEN PLAYER attacks @trialswitch#{n}
        [
        #{exact_actions.join("\n")}
        ].
        #{reactive}
      BSHARP
    end

    def generated_event(index)
      "player attacks trialswitch #{format('%03d', Integer(index))}"
    end

    def coverage_for(index, seed: DEFAULT_SEED)
      p = generated_parameters(index, seed: seed)
      tags = %w[kind_ancestry inherited_selection exact_event_priority source_order action_order]
      tags << 'text_boundaries' if p.fetch(:profile) >= 2
      tags << 'controls' if p.fetch(:profile) >= 3
      tags << 'platform_movement' if p.fetch(:profile) >= 4
      tags << 'number_change' if p.fetch(:profile) >= 5
      tags << "compound_#{p.fetch(:connector)}" if p.fetch(:profile) >= 6
      tags << 'otherwise_branch' if p.fetch(:profile) >= 7
      {
        'index' => p.fetch(:number),
        'profile' => p.fetch(:profile),
        'kind_depth' => p.fetch(:kind_depth),
        'object_count' => p.fetch(:object_count) + 1,
        'connector' => p.fetch(:profile) >= 6 ? p.fetch(:connector) : nil,
        'tags' => tags
      }
    end

    def verify_generated_program(index, seed: DEFAULT_SEED)
      source_text = generated_source(index, seed: seed)
      assert!(source_text == generated_source(index, seed: seed), "case #{index} source was not reproducible")
      resolved_a = resolve_source(source_text)
      resolved_b = resolve_source(source_text.dup)
      expected_meaning, expected_bytecode = PROFILE_PAIRS.fetch(generated_profile(index))
      assert!(resolved_a.meaning_profile == expected_meaning, "case #{index} selected #{resolved_a.meaning_profile}, expected #{expected_meaning}")

      saved = JSON.parse(canonical_json(resolved_a.to_h))
      emitter_a = BytecodeEmitter.new(resolved_a)
      emitter_b = BytecodeEmitter.new(resolved_b)
      emitter_saved = BytecodeEmitter.new(saved)
      assert!(emitter_a.binary == emitter_b.binary, "case #{index} repeat BSBC was not byte-identical")
      assert!(emitter_a.binary == emitter_saved.binary, "case #{index} source-to-BSIR BSBC changed")
      assert!(emitter_a.disassembly == emitter_b.disassembly, "case #{index} repeat disassembly changed")
      assert!(emitter_a.disassembly == emitter_saved.disassembly, "case #{index} source-to-BSIR disassembly changed")

      loader = BytecodeLoader.new(emitter_a.binary, expected_fingerprint: emitter_a.fingerprint)
      assert!(loader.model.fetch(:profile) == expected_bytecode, "case #{index} selected #{loader.model.fetch(:profile)}, expected #{expected_bytecode}")
      source_runtime = Runtime.new(resolved_a)
      bsir_runtime = Runtime.new(saved)
      machine = BytecodeVirtualMachine.new(loader)
      assert!(source_runtime.snapshot == bsir_runtime.snapshot, "case #{index} initial source/BSIR worlds differ")
      assert!(source_runtime.snapshot == machine.snapshot, "case #{index} initial source/VM worlds differ")
      event = generated_event(index)
      source_result = semantic_result(source_runtime.run_event(event))
      bsir_result = semantic_result(bsir_runtime.run_event(event))
      machine_result = semantic_result(machine.run_event(event))
      assert!(source_result == bsir_result, "case #{index} source/BSIR event results differ")
      assert!(source_result == machine_result, "case #{index} source/VM event results differ")
      {
        'index' => Integer(index),
        'meaning_profile' => expected_meaning,
        'bytecode_profile' => expected_bytecode,
        'source_sha256' => Digest::SHA256.hexdigest(source_text),
        'bsir_sha256' => Digest::SHA256.hexdigest(canonical_json(saved)),
        'bytecode_sha256' => Digest::SHA256.hexdigest(emitter_a.binary),
        'disassembly_sha256' => Digest::SHA256.hexdigest(emitter_a.disassembly),
        'final_world_sha256' => semantic_sha256(machine.snapshot),
        'coverage' => coverage_for(index, seed: seed)
      }
    end

    def deep_copy(value)
      Marshal.load(Marshal.dump(value))
    end

    def rejection(artifact, index, phase, error, location: nil)
      {
        'artifact' => artifact,
        'mutation' => Integer(index),
        'phase' => phase,
        'location' => location,
        'reason' => error.message.to_s.lines.first.to_s.strip
      }
    end

    def mutated_source(index)
      number = Integer(index)
      value = source.dup
      case number % 12
      when 0 then value.sub('OTHERWISE', 'ELSE')
      when 1 then "OTHERWISE\n[\n    |then (change PLAYER to alive\n].\n#{value}"
      when 2 then value.sub('KINDS', 'WORLD')
      when 3 then value.sub('].', ']')
      when 4 then value.sub('|then (damage', '|broken (damage')
      when 5 then value.sub('@mara is a #captain', "@mara is a #missingkind#{number}")
      when 6 then value.sub('(increase score of PLAYER by 1', '(increase score of PLAYER by -1')
      when 7 then "BROKEN HEAD #{number}\n[\n].\n#{value}"
      when 8 then value.sub('and @north gate is open', 'xor @north gate is open')
      when 9 then value.sub('CONTROLS for PLAYER', 'CONTROLS for @mara')
      when 10 then value.sub('].', '].\n].')
      else
        bytes = value.b
        bytes.setbyte([bytes.bytesize - 1, 24 + number % [bytes.bytesize - 24, 1].max].min, 0xff)
        bytes.force_encoding(Encoding::UTF_8)
      end
    end

    def reject_source_mutation!(index)
      resolve_source(mutated_source(index))
      raise "TRIAL BY FIRE: source mutation #{index} was accepted"
    rescue StandardError => error
      raise if error.message.start_with?('TRIAL BY FIRE: source mutation')
      assert!(!error.message.to_s.empty?, "source mutation #{index} failed without an explanation")
      rejection('BASIC# source', index, 'parse/resolve', error)
    end

    def mutate_bsir(base, index)
      value = deep_copy(base)
      number = Integer(index)
      case number % 12
      when 0 then value.delete('format')
      when 1 then value['meaning_profile'] = 'bsharp.meaning.v99'
      when 2 then value['objects'] = 'not a list'
      when 3 then value['events'] = [nil]
      when 4 then value['if_rules'].first['otherwise'] = []
      when 5 then value['diagnostics'] = [{ 'severity' => 'error', 'message' => "mutation #{number}" }]
      when 6 then value['facts'].first['subject'] = { 'type' => 'object', 'name' => "missing#{number}", 'text' => "missing#{number}" }
      when 7 then value['if_rules'].first['if']['connector'] = 'xor'
      when 8 then value['objects'].reverse!
      when 9 then value['events'].reverse!
      when 10 then value['meaning_profile'] = 'bsharp.meaning.v1'
      else value['objects'] << deep_copy(value['objects'].first)
      end
      value
    end

    def reject_bsir_mutation!(base, expected_fingerprint, index)
      mutated = mutate_bsir(base, index)
      begin
        Runtime.new(mutated)
        emitter = BytecodeEmitter.new(mutated)
        assert!(emitter.fingerprint != expected_fingerprint, "BSIR mutation #{index} preserved the locked meaning fingerprint")
        return rejection('saved BSIR', index, 'meaning comparison', ArgumentError.new('meaning fingerprint does not match the locked source'))
      rescue StandardError => error
        raise if error.message.include?('preserved the locked meaning fingerprint')
        assert!(!error.message.to_s.empty?, "BSIR mutation #{index} failed without an explanation")
        return rejection('saved BSIR', index, 'load/validate', error)
      end
    end

    def mutate_save(base, index)
      value = deep_copy(base)
      number = Integer(index)
      case number % 12
      when 0 then value.delete('format')
      when 1 then value['format_version'] = 99
      when 2 then value['program_fingerprint']['value'] = Digest::SHA256.hexdigest(number.to_s)
      when 3 then value['world']['settled'] = false
      when 4 then value['world']['things'] = 'not a list'
      when 5 then value['world']['things'].first['name'] = "missing#{number}"
      when 6 then value['world']['if_rules'].first['active'] = 'yes'
      when 7 then value['world']['if_rules'].first['branch'] = 'ELSE'
      when 8 then value['world']['things'].reverse!
      when 9 then value['world']['things'] << deep_copy(value['world']['things'].first)
      when 10 then value['program_fingerprint'].delete('algorithm')
      else value['world'].delete('if_rules')
      end
      value
    end

    def reject_save_mutation!(loader, base, index)
      machine = BytecodeVirtualMachine.new(loader)
      snapshot = machine.snapshot
      begin
        machine.restore_world_save!(mutate_save(base, index))
      rescue StandardError => error
        assert!(!error.message.to_s.empty?, "Save mutation #{index} failed without an explanation")
        assert!(machine.snapshot == snapshot, "Save mutation #{index} partially changed the world")
        return rejection('BSharp Save', index, 'restore validation', error)
      end
      raise "TRIAL BY FIRE: Save mutation #{index} was accepted"
    end

    def write_u16(bytes, offset, value)
      bytes[offset, 2] = [value].pack('v')
    end

    def write_u32(bytes, offset, value)
      bytes[offset, 4] = [value].pack('V')
    end

    def bytecode_entries(bytes)
      count = bytes.byteslice(12, 4).unpack1('V')
      count.times.map do |index|
        at = 32 + index * 16
        id, offset, length, records = bytes.byteslice(at, 16).unpack('a4V3')
        { id: id, offset: offset, length: length, count: records, at: at }
      end
    end

    def mutate_bytecode(base, index)
      bytes = base.dup.b
      number = Integer(index)
      entries = bytecode_entries(bytes)
      case number % 12
      when 0 then bytes = bytes.byteslice(0, number % bytes.bytesize)
      when 1 then bytes[0, 4] = 'FAIL'
      when 2 then write_u16(bytes, 4, 99)
      when 3 then write_u32(bytes, 8, 0)
      when 4 then write_u32(bytes, 24, bytes.bytesize + number + 1)
      when 5 then write_u32(bytes, 28, 1)
      when 6 then bytes[32, 4] = 'NOPE'
      when 7 then bytes[48, 4] = bytes.byteslice(32, 4)
      when 8 then write_u32(bytes, entries.fetch(1).fetch(:at) + 4, entries.fetch(1).fetch(:offset) + 1)
      when 9 then write_u32(bytes, entries.fetch(1).fetch(:at) + 4, entries.fetch(0).fetch(:offset))
      when 10 then write_u32(bytes, entries.fetch(-1).fetch(:at) + 8, bytes.bytesize)
      else bytes << "\x00"
      end
      bytes
    end

    def reject_bytecode_mutation!(base, index)
      BytecodeLoader.new(mutate_bytecode(base, index))
      raise "TRIAL BY FIRE: BSBC mutation #{index} was accepted"
    rescue StandardError => error
      raise if error.message.start_with?('TRIAL BY FIRE: BSBC mutation')
      assert!(!error.message.to_s.empty?, "BSBC mutation #{index} failed without an explanation")
      rejection('BSharp Bytecode', index, 'binary load/validate', error)
    end

    def verify_every_truncated_prefix!(binary)
      binary.bytesize.times do |length|
        begin
          BytecodeLoader.new(binary.byteslice(0, length))
          raise "TRIAL BY FIRE: truncated BSBC prefix #{length} was accepted"
        rescue BytecodeLoaderError, ArgumentError, KeyError, TypeError
          nil
        end
      end
      binary.bytesize
    end

    def profile_artifact_paths
      PROFILE_ARTIFACT_NAMES.flat_map { |name| ["samples/#{name}.bsbc", "samples/#{name}.bsbc.txt"] }
    end

    def artifact_hashes
      profile_artifact_paths.to_h do |path|
        [path, Digest::SHA256.hexdigest(File.binread(File.join(ROOT, path)))]
      end
    end

    def finite_follow_up_source(length)
      count = Integer(length)
      definitions = ['    @masterbell is a #device'] + count.times.map { |i| "    @chainbell#{i} is a #device" }
      rules = count.times.map do |i|
        action = i + 1 < count ? "(cause PLAYER sounds @chainbell#{i + 1}" : '(damage PLAYER'
        <<~RULE
          WHEN PLAYER sounds @chainbell#{i}
          [
              |then #{action}
          ].
        RULE
      end
      <<~BSHARP
        DEFINE
        [
        #{definitions.join("\n")}
        ].
        WHEN PLAYER sounds @masterbell
        [
            |then (cause PLAYER sounds @chainbell0
        ].
        #{rules.join("\n")}
      BSHARP
    end

    def verify_follow_up_boundaries!
      [1_023, 1_024, 1_025].each_with_object({}) do |count, result|
        resolved = resolve_source(finite_follow_up_source(count))
        emitter = BytecodeEmitter.new(resolved)
        reference_result = Runtime.new(resolved).run_event('player sounds masterbell')
        machine_result = BytecodeVirtualMachine.new(BytecodeLoader.new(emitter.binary)).run_event('player sounds masterbell')
        assert!(semantic_result(reference_result) == semantic_result(machine_result), "follow-up boundary #{count} VM/reference parity changed")
        observed = machine_result.fetch('follow_up_events').length
        expected = [count, 1_024].min
        assert!(observed == expected, "follow-up boundary #{count} stopped at #{observed}, expected #{expected}")
        if count <= 1_024
          assert!(machine_result['error'].nil?, "follow-up boundary #{count} failed unexpectedly")
        else
          assert!(machine_result['error'] == BytecodeVirtualMachine::EVENT_CHAIN_LIMIT_MESSAGE, 'above-limit follow-up explanation changed')
        end
        result[count.to_s] = { 'observed' => observed, 'error' => machine_result['error'] }
      end
    end

    def principal_bytecode
      emitter = BytecodeEmitter.new(document)
      [emitter, BytecodeLoader.new(emitter.binary, expected_fingerprint: emitter.fingerprint)]
    end

    def verify_profile_artifacts!(expected = nil)
      actual = artifact_hashes
      assert!(actual == expected, 'a protected Profile 1–7 BSBC or disassembly artifact changed') if expected
      actual
    end

    def verify_event_paths!(count)
      total = Integer(count)
      event = 'player sounds brass bell'
      emitter, loader = principal_bytecode
      source_runtime = Runtime.new(document)
      bsir_runtime = Runtime.new(saved_bsir)
      machine = BytecodeVirtualMachine.new(loader)
      total.times do
        source_runtime.run_event(event)
        bsir_runtime.run_event(event)
        machine.run_event(event)
      end
      source_hash = semantic_sha256(source_runtime.snapshot)
      bsir_hash = semantic_sha256(bsir_runtime.snapshot)
      machine_hash = semantic_sha256(machine.snapshot)
      assert!(source_hash == bsir_hash, '100,000-event source/saved-BSIR parity changed')
      assert!(source_hash == machine_hash, '100,000-event source/VM parity changed')

      repeated = BytecodeVirtualMachine.new(loader)
      total.times { repeated.run_event(event) }
      repeated_hash = semantic_sha256(repeated.snapshot)
      assert!(repeated_hash == machine_hash, 'repeated complete VM run produced a different final hash')
      {
        'events_per_path' => total,
        'source_sha256' => source_hash,
        'saved_bsir_sha256' => bsir_hash,
        'vm_sha256' => machine_hash,
        'repeated_vm_sha256' => repeated_hash,
        'bytecode_sha256' => Digest::SHA256.hexdigest(emitter.binary)
      }
    end

    def verify_platform_frames!(count)
      source_path = File.join(ROOT, 'samples/platform_movement.bsharp')
      resolved = resolve_source(File.read(source_path, encoding: Encoding::UTF_8))
      input = GameInput.new(resolved)
      input.process('type' => 'key_down', 'key' => 'D')
      digest = Digest::SHA256.new
      Integer(count).times do |index|
        input.process('type' => 'key_down', 'key' => 'SPACE') if (index % 250).zero?
        command = input.process(
          'type' => 'frame', 'time_ms' => index * 16,
          'grounded' => (index % 250).zero?, 'hit_right' => (index % 997).zero?
        ).fetch(0)
        assert!(command.fetch('command') == 'move_with_collisions', "movement frame #{index} emitted the wrong host command")
        assert!(command.fetch('velocity_x').abs <= 6.0, "movement frame #{index} exceeded declared horizontal speed")
        assert!(command.fetch('delta_seconds') <= 0.25, "movement frame #{index} exceeded the frame safety cap")
        digest << JSON.generate(command)
        input.process('type' => 'key_up', 'key' => 'SPACE') if (index % 250) == 1
      end
      { 'frames' => Integer(count), 'commands_sha256' => digest.hexdigest }
    end

    def verify_ask_questions!(count)
      total = Integer(count)
      _emitter, loader = principal_bytecode
      machine = BytecodeVirtualMachine.new(loader)
      before = machine.snapshot
      digest = Digest::SHA256.new
      answered = 0
      while answered < total
        batch_size = [Ask::MAX_QUESTIONS, total - answered].min
        questions = Array.new(batch_size) { |offset| ASK_QUESTIONS[(answered + offset) % ASK_QUESTIONS.length] }
        digest << JSON.generate(Ask.new(machine).answer_many(questions))
        answered += batch_size
      end
      assert!(machine.snapshot == before, 'read-only ASK campaign changed the world')
      { 'questions' => total, 'answers_sha256' => digest.hexdigest }
    end

    def verify_save_checkpoints!(count)
      _emitter, loader = principal_bytecode
      machine = BytecodeVirtualMachine.new(loader)
      digest = Digest::SHA256.new
      Integer(count).times do |index|
        machine.run_event('player sounds brass bell')
        save = WorldSave.document_for(machine)
        restored = BytecodeVirtualMachine.new(loader, world_save: save)
        assert!(restored.snapshot == machine.snapshot, "Save checkpoint #{index} changed the world")
        assert!(restored.ask_if_rules == machine.ask_if_rules, "Save checkpoint #{index} changed reactive state")
        digest << semantic_sha256(save)
        machine = restored
      end
      { 'checkpoints' => Integer(count), 'saves_sha256' => digest.hexdigest, 'final_world_sha256' => semantic_sha256(machine.snapshot) }
    end

    def verify_isolated_worlds!(count)
      _emitter, loader = principal_bytecode
      total = Integer(count)
      machines = Array.new(total) { BytecodeVirtualMachine.new(loader) }
      baseline = machines.fetch(1, machines.first).snapshot
      machines.first.run_event('player sounds brass bell')
      assert!(machines.first.snapshot != baseline, 'first isolated world did not change')
      machines.drop(1).each_with_index do |machine, index|
        assert!(machine.snapshot == baseline, "isolated world #{index + 1} was changed by another world")
      end
      digest = semantic_sha256(machines.map(&:snapshot))
      { 'simultaneous_worlds' => total, 'worlds_sha256' => digest }
    end

    def run_generator_campaign(count:, seed: DEFAULT_SEED, progress: nil)
      total = Integer(count)
      results = total.times.map do |index|
        result = verify_generated_program(index, seed: seed)
        progress.call(index + 1, total) if progress
        result
      end
      {
        'seed' => Integer(seed),
        'programs' => total,
        'profile_counts' => results.group_by { |entry| entry.fetch('meaning_profile') }.transform_values(&:length),
        'results_sha256' => semantic_sha256(results),
        'results' => results
      }
    end

    def run_mutation_campaign(count:, progress: nil, include_prefixes: true)
      total = Integer(count)
      emitter, loader = principal_bytecode
      machine = BytecodeVirtualMachine.new(loader)
      CAMPAIGN_EVENTS.each { |event| machine.run_event(event) }
      save = WorldSave.document_for(machine)
      base_bsir = saved_bsir
      rejections = []
      total.times do |index|
        rejections << reject_source_mutation!(index)
        rejections << reject_bsir_mutation!(base_bsir, emitter.fingerprint, index)
        rejections << reject_save_mutation!(loader, save, index)
        rejections << reject_bytecode_mutation!(emitter.binary, index)
        progress.call(index + 1, total) if progress
      end
      prefix_count = include_prefixes ? verify_every_truncated_prefix!(emitter.binary) : 0
      {
        'mutations_per_boundary' => total,
        'hostile_artifacts' => total * 4,
        'truncated_prefixes' => prefix_count,
        'rejections_sha256' => semantic_sha256(rejections),
        'rejections' => rejections
      }
    end

    def timed_phase(name, maximum_seconds: nil)
      value = nil
      seconds = Benchmark.realtime { value = yield }
      if maximum_seconds && seconds > maximum_seconds
        raise "TRIAL BY FIRE: #{name} exceeded #{maximum_seconds} seconds (#{format('%.3f', seconds)})"
      end
      [value, seconds]
    end
  end
end

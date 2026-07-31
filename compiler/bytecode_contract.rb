# frozen_string_literal: true

require 'digest'
require 'json'

module BasicSharp
  class BytecodeContractError < ArgumentError; end

  module BytecodeContract
    ARTIFACT_NAME = 'BSharp Bytecode'
    SHORT_NAME = 'BSBC'
    EXTENSION = '.bsbc'
    BINARY_FORMAT = 'bsharp.bytecode.bin'
    BINARY_FORMAT_VERSION = 1
    PROFILE = 'bsharp.bytecode.v1'
    MEANING_PROFILE = 'bsharp.meaning.v1'
    MAGIC = 'BSBC'
    BYTE_ORDER = 'little-endian'
    TEXT_ENCODING = 'UTF-8'
    ALIGNMENT_BYTES = 4
    HEADER_SIZE_BYTES = 32
    DIRECTORY_ENTRY_SIZE_BYTES = 16
    SECTION_ORDER = %w[STRS META KIND THNG STRT EVNT IFRL CODE].freeze
    SELECTORS = {
      'EXACT_THING' => 0x01,
      'ONE_KIND' => 0x02,
      'BOUND_THAT_KIND' => 0x03,
      'EVERY_KIND' => 0x04,
      'NO_REFERENCE' => 0xFF
    }.freeze
    INSTRUCTIONS = {
      'START_STATE' => 0x10,
      'START_RELATION' => 0x11,
      'START_VALUE' => 0x12,
      'DAMAGE' => 0x20,
      'CHANGE_STATE' => 0x21,
      'CHANGE_VALUE' => 0x22,
      'CARRY' => 0x23,
      'UNLOCK' => 0x24,
      'CAUSE_EVENT' => 0x25
    }.freeze
    CONDITIONS = {
      'STATE_IS' => 0x30,
      'STATE_ISNT' => 0x31,
      'RELATION_EXISTS' => 0x32,
      'VALUE_EQUALS' => 0x33
    }.freeze
    WHOLE_NUMBER_RANGE = (0..2_147_483_647)
    NO_REFERENCE_U32 = 0xFFFF_FFFF
    REQUIRED_MALFORMED_RULES = [
      'wrong magic bytes', 'unsupported binary format version', 'unsupported bytecode profile',
      'meaning-profile mismatch', 'meaning-fingerprint mismatch', 'wrong header size',
      'nonzero reserved field', 'missing required section', 'duplicate section',
      'wrong section order', 'overlapping section data', 'out-of-range section offset',
      'out-of-range section length', 'misaligned section data', 'file-size mismatch',
      'truncated header', 'truncated section directory', 'truncated section record',
      'trailing unexplained data', 'invalid UTF-8', 'duplicate deterministic string entry',
      'invalid string index', 'invalid Kind parent index', 'Kind ancestry circle',
      'invalid Thing Kind index', 'invalid selector code', 'selector not allowed in context',
      'invalid Thing reference', 'invalid Kind reference', 'invalid code-block reference',
      'unknown instruction code', 'reserved instruction code', 'wrong instruction operand count',
      'nonzero instruction reserved field', 'unknown condition code', 'reserved condition code',
      'wrong condition operand count', 'whole number outside 0 through 2147483647',
      'duplicate block identifier', 'overlapping code blocks', 'instruction crossing block boundary'
    ].freeze
    FORBIDDEN_SERIALIZED_TERMS = %w[BasicSharp RubyVM ObjectSpace Marshal Struct].freeze

    module_function

    def load_profile(path)
      JSON.parse(File.read(path, encoding: 'UTF-8'))
    end

    def validate_profile!(profile, root:)
      raise BytecodeContractError, 'Bytecode contract must be a JSON object.' unless profile.is_a?(Hash)
      unless profile['format'] == 'bsharp.bytecode.contract.json' && profile['format_version'] == 1
        raise BytecodeContractError, 'Bytecode contract format is not supported.'
      end

      validate_artifact!(profile.fetch('artifact'))
      validate_container!(profile.fetch('container'))
      validate_sections!(profile.fetch('sections'))
      validate_identities!(profile)
      validate_reserved_ranges!(profile)
      validate_coverage!(profile.fetch('meaning_case_coverage'), root: root)
      validate_disassembly!(profile.fetch('disassembly'))
      validate_emission!(profile.fetch('emission'))
      validate_loading!(profile.fetch('loading'))
      validate_malformed_rules!(profile.fetch('malformed_rejection_rules'))

      text = canonical_json(profile)
      if forbidden_serialized_data?(text)
        raise BytecodeContractError, 'Bytecode contract contains implementation-specific or nondeterministic serialized data.'
      end
      true
    end

    def validate_artifact!(artifact)
      expected = {
        'name' => ARTIFACT_NAME,
        'short_name' => SHORT_NAME,
        'extension' => EXTENSION,
        'binary_format' => BINARY_FORMAT,
        'binary_format_version' => BINARY_FORMAT_VERSION,
        'profile' => PROFILE,
        'required_meaning_profile' => MEANING_PROFILE,
        'magic_ascii' => MAGIC,
        'byte_order' => BYTE_ORDER,
        'text_encoding' => TEXT_ENCODING,
        'alignment_bytes' => ALIGNMENT_BYTES,
        'no_reference_u32' => NO_REFERENCE_U32,
        'whole_number_min' => WHOLE_NUMBER_RANGE.begin,
        'whole_number_max' => WHOLE_NUMBER_RANGE.end,
        'meaning_fingerprint_algorithm' => 'sha256-bsir-meaning-v1'
      }
      expected.each do |key, value|
        actual = artifact[key]
        raise BytecodeContractError, "Bytecode artifact #{key} must be #{value.inspect}." unless actual == value
      end
      unless artifact['magic_hex'] == MAGIC.bytes.map { |byte| format('%02X', byte) }.join(' ')
        raise BytecodeContractError, 'Bytecode magic hex does not match BSBC.'
      end
    end

    def validate_container!(container)
      raise BytecodeContractError, 'Bytecode header must be 32 bytes.' unless container['header_size_bytes'] == HEADER_SIZE_BYTES
      fields = container.fetch('header_fields')
      validate_packed_fields!(fields, total_size: HEADER_SIZE_BYTES, label: 'header')
      raise BytecodeContractError, 'Bytecode section count must be eight.' unless field_value(fields, 'section_count') == SECTION_ORDER.length
      raise BytecodeContractError, 'Bytecode directory must begin immediately after the header.' unless field_value(fields, 'section_directory_offset') == HEADER_SIZE_BYTES
      unless container['section_directory_entry_size_bytes'] == DIRECTORY_ENTRY_SIZE_BYTES
        raise BytecodeContractError, 'Bytecode section-directory entry must be 16 bytes.'
      end
      validate_packed_fields!(container.fetch('section_directory_fields'), total_size: DIRECTORY_ENTRY_SIZE_BYTES, label: 'section directory')
      raise BytecodeContractError, 'Bytecode section order is not canonical.' unless container['section_order'] == SECTION_ORDER
      expected_minimum = HEADER_SIZE_BYTES + (SECTION_ORDER.length * DIRECTORY_ENTRY_SIZE_BYTES)
      raise BytecodeContractError, 'Bytecode section data minimum offset is inconsistent.' unless container['section_data_minimum_offset'] == expected_minimum
      raise BytecodeContractError, 'Trailing unexplained bytes must be forbidden.' unless container['trailing_unexplained_bytes'] == 'forbidden'
    end

    def validate_sections!(sections)
      ids = sections.map { |entry| entry['id'] }
      raise BytecodeContractError, 'Bytecode sections must be unique and complete.' unless ids == SECTION_ORDER && ids.uniq.length == ids.length
      sections.each do |entry|
        raise BytecodeContractError, "Section #{entry['id']} needs a name." if entry['name'].to_s.empty?
        raise BytecodeContractError, "Section #{entry['id']} needs record-count meaning." if entry['record_count_means'].to_s.empty?
      end
    end

    def validate_identities!(profile)
      validate_named_codes!(profile.fetch('selectors'), SELECTORS, 'selector')
      validate_named_codes!(profile.fetch('instructions'), INSTRUCTIONS, 'instruction')
      validate_named_codes!(profile.fetch('conditions'), CONDITIONS, 'condition')

      profile.fetch('instructions').each do |entry|
        operands = entry['operands']
        raise BytecodeContractError, "Instruction #{entry['name']} needs a fixed operand list." unless operands.is_a?(Array) && !operands.empty?
        expected_hex = format('0x%02X', entry['code'])
        raise BytecodeContractError, "Instruction #{entry['name']} hex is inconsistent." unless entry['hex'] == expected_hex
      end
      profile.fetch('conditions').each do |entry|
        operands = entry['operands']
        raise BytecodeContractError, "Condition #{entry['name']} needs a fixed operand list." unless operands.is_a?(Array) && !operands.empty?
      end
      selector_names = profile.fetch('selectors').map { |entry| entry['name'] }
      raise BytecodeContractError, 'Selector contexts are incomplete.' unless selector_names == SELECTORS.keys
    end

    def validate_reserved_ranges!(profile)
      validate_ranges!(profile.fetch('instruction_reserved_ranges'), INSTRUCTIONS.values, 'instruction')
      validate_ranges!(profile.fetch('condition_reserved_ranges'), CONDITIONS.values, 'condition')
      validate_ranges!(profile.fetch('selector_reserved_ranges'), SELECTORS.values, 'selector')
    end

    def validate_coverage!(coverage, root:)
      meaning_path = File.join(root, 'spec/meaning_v1/BASIC_SHARP_MEANING_PROFILE_v1.json')
      meaning = JSON.parse(File.read(meaning_path, encoding: 'UTF-8'))
      expected_ids = meaning.fetch('cases').map { |entry| entry.fetch('id') }
      actual_ids = coverage.map { |entry| entry['case_id'] }
      raise BytecodeContractError, 'Bytecode coverage must name all 13 Meaning Profile cases in order.' unless actual_ids == expected_ids && actual_ids.length == 13
      coverage.each do |entry|
        requirements = entry['requires']
        raise BytecodeContractError, "Meaning case #{entry['case_id']} has no bytecode coverage." unless requirements.is_a?(Array) && !requirements.empty?
      end
    end

    def validate_disassembly!(disassembly)
      required = ['diagnostic only', 'BLOCK <block_id>', '<MNEMONIC>', 'END', 'WHEN actor=']
      text = disassembly.values.join('\n')
      missing = required.reject { |entry| text.include?(entry) }
      raise BytecodeContractError, "Readable disassembly grammar is incomplete: #{missing.join(', ')}" unless missing.empty?
    end

    def validate_emission!(emission)
      expected_prefix = [PROFILE, MEANING_PROFILE, 'sha256-bsir-meaning-v1']
      unless emission['mandatory_string_prefix'] == expected_prefix
        raise BytecodeContractError, 'Bytecode emission mandatory string prefix is inconsistent.'
      end
      unless emission['source_inputs'] == ['.bsharp', '.bsir.json']
        raise BytecodeContractError, 'Bytecode emitter source inputs are inconsistent.'
      end
      unless emission['output_binary_extension'] == EXTENSION && emission['output_disassembly_suffix'] == '.bsbc.txt'
        raise BytecodeContractError, 'Bytecode emitter output identities are inconsistent.'
      end
      required = ['zero-based', 'zero-filled', 'byte-identical', '32 raw SHA-256 bytes', 'failed emission leaves no partial pair']
      text = emission.values.flatten.join("\n")
      missing = required.reject { |entry| text.include?(entry) }
      raise BytecodeContractError, "Bytecode emission rules are incomplete: #{missing.join(', ')}" unless missing.empty?
    end

    def validate_loading!(loading)
      unless loading['status'] == 'implemented by BASIC# v0.1.28'
        raise BytecodeContractError, 'Bytecode loader implementation status is inconsistent.'
      end
      unless loading['source_inputs'] == ['.bsbc']
        raise BytecodeContractError, 'Bytecode loader input identity is inconsistent.'
      end
      required = [
        'complete structural validation', 'trusted in-memory model', 'deeply frozen',
        'no partial model', '--against', '.bsharp', '.bsir.json',
        'diagnostic disassembly', 'non-executing', '41'
      ]
      text = loading.values.flatten.join("
")
      missing = required.reject { |entry| text.include?(entry) }
      raise BytecodeContractError, "Bytecode loading rules are incomplete: #{missing.join(', ')}" unless missing.empty?
    end

    def validate_malformed_rules!(rules)
      missing = REQUIRED_MALFORMED_RULES - rules
      raise BytecodeContractError, "Malformed-bytecode rules are incomplete: #{missing.join(', ')}" unless missing.empty?
      raise BytecodeContractError, 'Malformed-bytecode rules must be unique.' unless rules.uniq.length == rules.length
    end

    def validate_packed_fields!(fields, total_size:, label:)
      occupied = []
      fields.each do |field|
        offset = field['offset']
        bytes = field['bytes']
        unless offset.is_a?(Integer) && bytes.is_a?(Integer) && offset >= 0 && bytes.positive?
          raise BytecodeContractError, "Invalid #{label} field geometry."
        end
        occupied.concat((offset...(offset + bytes)).to_a)
      end
      raise BytecodeContractError, "#{label.capitalize} fields overlap." unless occupied.uniq.length == occupied.length
      raise BytecodeContractError, "#{label.capitalize} fields do not fill exactly #{total_size} bytes." unless occupied.sort == (0...total_size).to_a
    end

    def validate_named_codes!(entries, expected, label)
      names = entries.map { |entry| entry['name'] }
      codes = entries.map { |entry| entry['code'] }
      raise BytecodeContractError, "#{label.capitalize} names are incomplete or out of order." unless names == expected.keys
      raise BytecodeContractError, "#{label.capitalize} codes are not unique." unless codes.uniq.length == codes.length
      expected.each do |name, code|
        entry = entries.find { |candidate| candidate['name'] == name }
        raise BytecodeContractError, "#{label.capitalize} #{name} must use #{code}." unless entry && entry['code'] == code
      end
    end

    def validate_ranges!(ranges, active_codes, label)
      covered = []
      ranges.each do |range|
        first = range['start']
        last = range['end']
        unless first.is_a?(Integer) && last.is_a?(Integer) && first.between?(0, 255) && last.between?(0, 255) && first <= last
          raise BytecodeContractError, "Invalid reserved #{label} range."
        end
        covered.concat((first..last).to_a)
      end
      raise BytecodeContractError, "Reserved #{label} ranges overlap." unless covered.uniq.length == covered.length
      overlap = covered & active_codes
      raise BytecodeContractError, "Reserved #{label} range contains active code: #{overlap.join(', ')}" unless overlap.empty?
      expected_reserved = (0..255).to_a - active_codes
      raise BytecodeContractError, "Reserved #{label} ranges do not cover every inactive code." unless covered.sort == expected_reserved
    end

    def field_value(fields, name)
      fields.find { |entry| entry['name'] == name }&.fetch('value', nil)
    end

    def canonical_json(value)
      "#{JSON.pretty_generate(canonicalize(value))}\n"
    end

    def canonicalize(value)
      case value
      when Hash
        value.keys.map(&:to_s).sort.each_with_object({}) do |key, result|
          source_key = value.key?(key) ? key : value.keys.find { |candidate| candidate.to_s == key }
          result[key] = canonicalize(value.fetch(source_key))
        end
      when Array
        value.map { |entry| canonicalize(entry) }
      else
        value
      end
    end

    def sha256(value)
      Digest::SHA256.hexdigest(value)
    end

    def forbidden_serialized_data?(text)
      return true if FORBIDDEN_SERIALIZED_TERMS.any? { |term| text.include?(term) }
      return true if text.match?(%r{/(?:home|tmp|mnt|Users)/})
      return true if text.match?(/\b\d{4}-\d{2}-\d{2}T\d{2}:\d{2}/)

      false
    end
  end
end

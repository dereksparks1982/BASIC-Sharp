# frozen_string_literal: true

require 'json'
require_relative 'bytecode_contract'
require_relative 'bytecode_disassembler'

module BasicSharp
  class BytecodeLoaderError < ArgumentError; end

  class BytecodeLoader
    HEADER_FORMAT = 'a4v2V6'
    HEADER_FIELD_COUNT = 9
    META_SIZE_BYTES = 68
    KIND_RECORD_SIZE_BYTES = 12
    THING_RECORD_SIZE_BYTES = 12
    EVENT_RECORD_SIZE_BYTES = 28
    CODE_DIRECTORY_ENTRY_SIZE_BYTES = 16

    INSTRUCTION_OPERAND_COUNTS = {
      'START_STATE' => 3,
      'START_RELATION' => 3,
      'START_VALUE' => 3,
      'START_TEXT_VALUE' => 3,
      'DAMAGE' => 3,
      'CHANGE_STATE' => 4,
      'CHANGE_VALUE' => 4,
      'CHANGE_TEXT_VALUE' => 4,
      'INCREASE_VALUE' => 4,
      'DECREASE_VALUE' => 4,
      'CARRY' => 2,
      'UNLOCK' => 2,
      'CAUSE_EVENT' => 5
    }.freeze
    CONDITION_OPERAND_COUNTS = {
      'STATE_IS' => 2,
      'STATE_ISNT' => 2,
      'RELATION_EXISTS' => 3,
      'VALUE_EQUALS' => 3,
      'TEXT_VALUE_EQUALS' => 3,
      'VALUE_AT_LEAST' => 3,
      'VALUE_MORE_THAN' => 3,
      'VALUE_AT_MOST' => 3,
      'VALUE_LESS_THAN' => 3
    }.freeze
    START_INSTRUCTIONS = %w[START_STATE START_RELATION START_VALUE START_TEXT_VALUE].freeze
    ACTION_INSTRUCTIONS = %w[DAMAGE CHANGE_STATE CHANGE_VALUE CHANGE_TEXT_VALUE INCREASE_VALUE DECREASE_VALUE CARRY UNLOCK CAUSE_EVENT].freeze
    EVENT_ACTOR_SELECTORS = %w[EXACT_THING ONE_KIND].freeze
    EVENT_TARGET_SELECTORS = %w[EXACT_THING ONE_KIND NO_REFERENCE].freeze
    ACTION_TARGET_SELECTORS = %w[EXACT_THING BOUND_THAT_KIND EVERY_KIND].freeze
    CAUSED_ACTOR_SELECTORS = %w[EXACT_THING ONE_KIND BOUND_THAT_KIND].freeze
    CAUSED_TARGET_SELECTORS = %w[EXACT_THING ONE_KIND BOUND_THAT_KIND NO_REFERENCE].freeze

    attr_reader :model, :source_label

    def self.read(path, expected_fingerprint: nil)
      expanded = File.expand_path(path)
      raise BytecodeLoaderError, "BSharp Bytecode file not found: #{path}" unless File.file?(expanded)

      new(File.binread(expanded), source_label: path, expected_fingerprint: expected_fingerprint)
    rescue SystemCallError => error
      raise BytecodeLoaderError, "BSharp Bytecode could not be read: #{error.message}"
    end

    def initialize(bytes, source_label: '(memory)', expected_fingerprint: nil)
      unless bytes.is_a?(String)
        raise BytecodeLoaderError, 'BSharp Bytecode input must be binary bytes.'
      end

      @bytes = bytes.b.dup.freeze
      @source_label = source_label.to_s.freeze
      @expected_fingerprint = normalize_fingerprint(expected_fingerprint)
      @sections = {}
      @directory = []
      @model = deep_freeze(parse)
    end

    def disassembly
      @disassembly ||= BytecodeDisassembler.new(model).render.freeze
    end

    def fingerprint
      model.fetch(:fingerprint)
    end

    def instruction_count
      model.fetch(:blocks).sum { |block| block.fetch(:instructions).length }
    end

    def summary
      {
        binary_format: BytecodeContract::BINARY_FORMAT,
        binary_format_version: BytecodeContract::BINARY_FORMAT_VERSION,
        profile: model.fetch(:profile),
        meaning_profile: model.fetch(:meaning_profile),
        fingerprint: fingerprint,
        strings: model.fetch(:strings).length,
        kinds: model.fetch(:kinds).length,
        things: model.fetch(:things).length,
        start_records: model.fetch(:start_records).length,
        events: model.fetch(:events).length,
        if_rules: model.fetch(:if_rules).length,
        code_blocks: model.fetch(:blocks).length,
        instructions: instruction_count,
        controls: model.fetch(:controls, []).length,
        hover_declarations: model.fetch(:hover_declarations, []).length,
        context_declarations: model.fetch(:context_declarations, []).length
      }.freeze
    end

    def verify_fingerprint!(expected)
      normalized = normalize_fingerprint(expected)
      return true if normalized == fingerprint

      raise BytecodeLoaderError,
            "This BSharp Bytecode belongs to different BASIC# program meaning.\n" \
            'Validate it against the same .bsharp or .bsir.json program that created it.'
    end

    private

    def parse
      parse_header_and_directory!
      parse_strings!
      parse_meta!
      reject_implementation_leaks! if @profile_format_version == 1
      parse_kinds!
      parse_things!
      parse_start_records!
      parse_events!
      parse_if_rules!
      parse_game_sections!
      parse_code!
      validate_count_agreement!
      validate_string_usage_and_order!
      validate_value_type_contracts!
      verify_expected_fingerprint! if @expected_fingerprint

      {
        profile: @strings.fetch(@meta.fetch(:profile_string_index)),
        meaning_profile: @strings.fetch(@meta.fetch(:meaning_profile_string_index)),
        fingerprint_algorithm: @strings.fetch(@meta.fetch(:fingerprint_algorithm_string_index)),
        fingerprint: @meta.fetch(:fingerprint),
        strings: @strings,
        string_roles: @string_roles.map do |roles|
          roles.length == 2 ? :identifier_and_literal : roles.fetch(0)
        end,
        kinds: @kinds,
        things: @things,
        start_records: @start_records,
        events: @events,
        if_rules: @if_rules,
        blocks: @blocks,
        controls: @controls,
        hover_declarations: @hover_declarations,
        context_declarations: @context_declarations
      }
    end


    def verify_expected_fingerprint!
      return if @expected_fingerprint == @meta.fetch(:fingerprint)

      raise BytecodeLoaderError,
            "This BSharp Bytecode belongs to different BASIC# program meaning.\n" \
            'Validate it against the same .bsharp or .bsir.json program that created it.'
    end

    def reject_implementation_leaks!
      term = BytecodeContract::FORBIDDEN_SERIALIZED_TERMS.find { |entry| @bytes.include?(entry) }
      return unless term

      raise BytecodeLoaderError, 'BSharp Bytecode contains implementation-specific serialized data.'
    end

    def parse_header_and_directory!
      if @bytes.bytesize < BytecodeContract::HEADER_SIZE_BYTES
        raise BytecodeLoaderError, 'BSharp Bytecode header is truncated.'
      end

      magic, binary_version, profile_version, header_size, section_count,
        directory_offset, directory_entry_size, declared_file_size, reserved_flags =
        @bytes.byteslice(0, BytecodeContract::HEADER_SIZE_BYTES).unpack(HEADER_FORMAT)

      raise BytecodeLoaderError, 'BSharp Bytecode magic bytes are wrong.' unless magic == BytecodeContract::MAGIC
      unless binary_version == BytecodeContract::BINARY_FORMAT_VERSION
        raise BytecodeLoaderError, "BSharp Bytecode binary format version #{binary_version} is not supported."
      end
      unless [1, 2, 3, 4, 5].include?(profile_version)
        raise BytecodeLoaderError, "BSharp Bytecode profile format version #{profile_version} is not supported."
      end
      @profile_format_version = profile_version
      raise BytecodeLoaderError, 'BSharp Bytecode header size is wrong.' unless header_size == BytecodeContract::HEADER_SIZE_BYTES
      expected_order = BytecodeContract.section_order_for_format(profile_version)
      raise BytecodeLoaderError, 'BSharp Bytecode section count is wrong.' unless section_count == expected_order.length
      raise BytecodeLoaderError, 'BSharp Bytecode section directory offset is wrong.' unless directory_offset == BytecodeContract::HEADER_SIZE_BYTES
      unless directory_entry_size == BytecodeContract::DIRECTORY_ENTRY_SIZE_BYTES
        raise BytecodeLoaderError, 'BSharp Bytecode section-directory entry size is wrong.'
      end
      raise BytecodeLoaderError, 'BSharp Bytecode reserved header field must be zero.' unless reserved_flags.zero?
      raise BytecodeLoaderError, 'BSharp Bytecode file-size field does not match the file.' unless declared_file_size == @bytes.bytesize

      directory_size = section_count * directory_entry_size
      directory_end = checked_add(directory_offset, directory_size, 'section directory')
      if directory_end > @bytes.bytesize
        raise BytecodeLoaderError, 'BSharp Bytecode section directory is truncated.'
      end

      ids = []
      section_count.times do |index|
        cursor = directory_offset + index * directory_entry_size
        id, offset, length, count = @bytes.byteslice(cursor, directory_entry_size).unpack('a4V3')
        ids << id
        @directory << { id: id, offset: offset, length: length, count: count }
      end

      if ids.uniq.length != ids.length
        raise BytecodeLoaderError, 'BSharp Bytecode contains a duplicate section.'
      end
      unless (expected_order - ids).empty? && (ids - expected_order).empty?
        raise BytecodeLoaderError, 'BSharp Bytecode is missing a required section.'
      end
      unless ids == expected_order
        raise BytecodeLoaderError, 'BSharp Bytecode sections are in the wrong order.'
      end

      minimum_data_offset = directory_end
      previous_end = minimum_data_offset
      @directory.each do |entry|
        offset = entry.fetch(:offset)
        length = entry.fetch(:length)
        if offset < minimum_data_offset || offset > @bytes.bytesize
          raise BytecodeLoaderError, "BSharp Bytecode section #{entry[:id]} has an out-of-range offset."
        end
        unless (offset % BytecodeContract::ALIGNMENT_BYTES).zero?
          raise BytecodeLoaderError, "BSharp Bytecode section #{entry[:id]} is not four-byte aligned."
        end
        section_end = checked_add(offset, length, "section #{entry[:id]}")
        if section_end > @bytes.bytesize
          raise BytecodeLoaderError, "BSharp Bytecode section #{entry[:id]} has an out-of-range length."
        end
        if offset < previous_end
          raise BytecodeLoaderError, 'BSharp Bytecode sections overlap.'
        end

        expected_offset = align(previous_end)
        unless offset == expected_offset
          raise BytecodeLoaderError, 'BSharp Bytecode contains an unexplained section gap.'
        end
        padding = @bytes.byteslice(previous_end, offset - previous_end)
        unless padding.nil? || padding.bytes.all?(&:zero?)
          raise BytecodeLoaderError, 'BSharp Bytecode alignment padding must be zero-filled.'
        end

        @sections[entry.fetch(:id)] = @bytes.byteslice(offset, length)
        previous_end = section_end
      end
      unless previous_end == @bytes.bytesize
        raise BytecodeLoaderError, 'BSharp Bytecode contains trailing unexplained data.'
      end
    end

    def parse_strings!
      entry = directory_entry('STRS')
      data = section('STRS')
      cursor = 0
      @strings = []

      entry.fetch(:count).times do
        ensure_bytes!(data, cursor, 4, 'STRS record')
        byte_length = data.byteslice(cursor, 4).unpack1('V')
        record_start = cursor
        cursor += 4
        ensure_bytes!(data, cursor, byte_length, 'STRS text')
        raw = data.byteslice(cursor, byte_length)
        cursor += byte_length
        value = raw.dup.force_encoding(Encoding::UTF_8)
        unless value.valid_encoding?
          raise BytecodeLoaderError, 'BSharp Bytecode string table contains invalid UTF-8.'
        end
        padding_length = align(cursor - record_start) - (cursor - record_start)
        ensure_bytes!(data, cursor, padding_length, 'STRS padding')
        padding = data.byteslice(cursor, padding_length)
        unless padding.bytes.all?(&:zero?)
          raise BytecodeLoaderError, 'BSharp Bytecode string padding must be zero-filled.'
        end
        cursor += padding_length
        @strings << value
      end

      unless cursor == data.bytesize
        raise BytecodeLoaderError, 'BSharp Bytecode STRS section contains a truncated record or trailing bytes.'
      end
      unless @strings.uniq.length == @strings.length
        raise BytecodeLoaderError, 'BSharp Bytecode string table contains a duplicate deterministic entry.'
      end
      mandatory = if @profile_format_version == 5
                    [BytecodeContract::PROFILE_5, BytecodeContract::MEANING_PROFILE_5, 'sha256-bsir-meaning-v5']
                  elsif @profile_format_version == 4
                    [BytecodeContract::PROFILE_4, BytecodeContract::MEANING_PROFILE_4, 'sha256-bsir-meaning-v4']
                  elsif @profile_format_version == 3
                    [BytecodeContract::PROFILE_3, BytecodeContract::MEANING_PROFILE_3, 'sha256-bsir-meaning-v3']
                  elsif @profile_format_version == 2
                    [BytecodeContract::PROFILE_2, BytecodeContract::MEANING_PROFILE_2, 'sha256-bsir-meaning-v2']
                  else
                    [BytecodeContract::PROFILE, BytecodeContract::MEANING_PROFILE, 'sha256-bsir-meaning-v1']
                  end
      unless @strings.first(3) == mandatory
        raise BytecodeLoaderError, 'BSharp Bytecode string table has the wrong mandatory identity prefix.'
      end
    end

    def parse_meta!
      entry = directory_entry('META')
      data = section('META')
      raise BytecodeLoaderError, 'BSharp Bytecode META record count must be one.' unless entry.fetch(:count) == 1
      raise BytecodeLoaderError, 'BSharp Bytecode META section has the wrong length.' unless data.bytesize == META_SIZE_BYTES

      profile_index, meaning_index, fingerprint_algorithm_index = data.byteslice(0, 12).unpack('V3')
      fingerprint = data.byteslice(12, 32).unpack1('H*')
      kind_count, thing_count, start_count, event_count, if_count, block_count = data.byteslice(44, 24).unpack('V6')
      [profile_index, meaning_index, fingerprint_algorithm_index].each { |index| validate_string_index!(index) }
      expected_profile = { 1 => BytecodeContract::PROFILE, 2 => BytecodeContract::PROFILE_2, 3 => BytecodeContract::PROFILE_3, 4 => BytecodeContract::PROFILE_4, 5 => BytecodeContract::PROFILE_5 }.fetch(@profile_format_version)
      expected_meaning = { 1 => BytecodeContract::MEANING_PROFILE, 2 => BytecodeContract::MEANING_PROFILE_2, 3 => BytecodeContract::MEANING_PROFILE_3, 4 => BytecodeContract::MEANING_PROFILE_4, 5 => BytecodeContract::MEANING_PROFILE_5 }.fetch(@profile_format_version)
      expected_fingerprint = { 1 => 'sha256-bsir-meaning-v1', 2 => 'sha256-bsir-meaning-v2', 3 => 'sha256-bsir-meaning-v3', 4 => 'sha256-bsir-meaning-v4', 5 => 'sha256-bsir-meaning-v5' }.fetch(@profile_format_version)
      unless @strings.fetch(profile_index) == expected_profile
        raise BytecodeLoaderError, 'BSharp Bytecode uses an unsupported bytecode profile.'
      end
      unless @strings.fetch(meaning_index) == expected_meaning
        raise BytecodeLoaderError, "BSharp Bytecode meaning profile does not match #{expected_meaning}."
      end
      unless @strings.fetch(fingerprint_algorithm_index) == expected_fingerprint
        raise BytecodeLoaderError, 'BSharp Bytecode meaning-fingerprint algorithm is not supported.'
      end

      @meta = {
        profile_string_index: profile_index,
        meaning_profile_string_index: meaning_index,
        fingerprint_algorithm_string_index: fingerprint_algorithm_index,
        fingerprint: fingerprint,
        kind_count: kind_count,
        thing_count: thing_count,
        start_count: start_count,
        event_count: event_count,
        if_count: if_count,
        block_count: block_count
      }
    end

    def parse_kinds!
      entry = directory_entry('KIND')
      data = section('KIND')
      expected = checked_multiply(entry.fetch(:count), KIND_RECORD_SIZE_BYTES, 'KIND records')
      raise BytecodeLoaderError, 'BSharp Bytecode KIND section length does not match its record count.' unless data.bytesize == expected

      seen_names = {}
      @kinds = entry.fetch(:count).times.map do |index|
        name_index, parent_index, source_order = data.byteslice(index * KIND_RECORD_SIZE_BYTES, KIND_RECORD_SIZE_BYTES).unpack('V3')
        validate_string_index!(name_index)
        name = @strings.fetch(name_index)
        raise BytecodeLoaderError, "BSharp Bytecode contains duplicate Kind '#{name}'." if seen_names[name]
        seen_names[name] = true
        unless parent_index == BytecodeContract::NO_REFERENCE_U32 || parent_index < entry.fetch(:count)
          raise BytecodeLoaderError, "BSharp Bytecode Kind '#{name}' has an invalid parent index."
        end
        unless source_order == index
          raise BytecodeLoaderError, 'BSharp Bytecode Kind source order is not canonical.'
        end
        { name: name, name_string_index: name_index, parent_index: parent_index, source_order: source_order }
      end
      validate_kind_ancestry!
      @kinds.each_with_index do |entry, index|
        parent = entry.fetch(:parent_index)
        next if parent == BytecodeContract::NO_REFERENCE_U32
        if parent >= index
          raise BytecodeLoaderError, "BSharp Bytecode Kind '#{entry.fetch(:name)}' must appear after its parent."
        end
      end
    end

    def parse_things!
      entry = directory_entry('THNG')
      data = section('THNG')
      expected = checked_multiply(entry.fetch(:count), THING_RECORD_SIZE_BYTES, 'THNG records')
      raise BytecodeLoaderError, 'BSharp Bytecode THNG section length does not match its record count.' unless data.bytesize == expected

      seen_names = {}
      @things = entry.fetch(:count).times.map do |index|
        name_index, kind_index, definition_order = data.byteslice(index * THING_RECORD_SIZE_BYTES, THING_RECORD_SIZE_BYTES).unpack('V3')
        validate_string_index!(name_index)
        validate_kind_index!(kind_index)
        name = @strings.fetch(name_index)
        raise BytecodeLoaderError, "BSharp Bytecode contains duplicate Thing '#{name}'." if seen_names[name]
        seen_names[name] = true
        unless definition_order == index
          raise BytecodeLoaderError, 'BSharp Bytecode Thing definition order is not canonical.'
        end
        { name: name, name_string_index: name_index, kind_index: kind_index, definition_order: definition_order }
      end
    end

    def parse_start_records!
      entry = directory_entry('STRT')
      data = section('STRT')
      cursor = 0
      @start_records = entry.fetch(:count).times.map do
        record, cursor = parse_instruction_record(data, cursor, data.bytesize, context: :start)
        validate_start_instruction!(record)
        decorate_instruction(record)
      end
      unless cursor == data.bytesize
        raise BytecodeLoaderError, 'BSharp Bytecode STRT section contains a truncated record or trailing bytes.'
      end
    end

    def parse_events!
      entry = directory_entry('EVNT')
      data = section('EVNT')
      expected = checked_multiply(entry.fetch(:count), EVENT_RECORD_SIZE_BYTES, 'EVNT records')
      raise BytecodeLoaderError, 'BSharp Bytecode EVNT section length does not match its record count.' unless data.bytesize == expected

      @events = entry.fetch(:count).times.map do |index|
        values = data.byteslice(index * EVENT_RECORD_SIZE_BYTES, EVENT_RECORD_SIZE_BYTES).unpack('V7')
        actor_code, actor_reference, action_index, target_code, target_reference, block_index, source_order = values
        actor_selector = selector_name!(actor_code)
        target_selector = selector_name!(target_code)
        validate_selector_context!(actor_selector, actor_reference, EVENT_ACTOR_SELECTORS, 'WHEN actor')
        validate_selector_context!(target_selector, target_reference, EVENT_TARGET_SELECTORS, 'WHEN target')
        validate_string_index!(action_index)
        validate_record_block_reference!(block_index)
        unless block_index == index
          raise BytecodeLoaderError, 'BSharp Bytecode WHEN block order is not canonical.'
        end
        unless source_order == index
          raise BytecodeLoaderError, 'BSharp Bytecode WHEN source order is not canonical.'
        end
        {
          actor_selector: actor_selector,
          actor_reference: actor_reference,
          action: @strings.fetch(action_index),
          action_string_index: action_index,
          target_selector: target_selector,
          target_reference: target_reference,
          block_index: block_index,
          source_order: source_order
        }
      end
    end

    def parse_if_rules!
      entry = directory_entry('IFRL')
      data = section('IFRL')
      cursor = 0
      event_count = directory_entry('EVNT').fetch(:count)
      @if_rules = entry.fetch(:count).times.map do |index|
        condition, cursor = parse_condition_record(data, cursor, data.bytesize)
        ensure_bytes!(data, cursor, 8, 'IFRL block fields')
        block_index, source_order = data.byteslice(cursor, 8).unpack('V2')
        cursor += 8
        validate_record_block_reference!(block_index)
        unless block_index == event_count + index
          raise BytecodeLoaderError, 'BSharp Bytecode IF block order is not canonical.'
        end
        unless source_order == index
          raise BytecodeLoaderError, 'BSharp Bytecode IF source order is not canonical.'
        end
        { condition: decorate_condition(condition), block_index: block_index, source_order: source_order }
      end
      unless cursor == data.bytesize
        raise BytecodeLoaderError, 'BSharp Bytecode IFRL section contains a truncated record or trailing bytes.'
      end
    end

    def parse_game_sections!
      @controls = []
      @hover_declarations = []
      @context_declarations = []
      return unless [3, 4, 5].include?(@profile_format_version)

      @controls = parse_game_section!('CTRL', 'controls')
      @hover_declarations = parse_game_section!('HOVR', 'hover declarations')
      @context_declarations = parse_game_section!('CTXT', 'context declarations')
    end

    def parse_game_section!(id, label)
      data = section(id)
      unless data.dup.force_encoding(Encoding::UTF_8).valid_encoding?
        raise BytecodeLoaderError, "BSharp Bytecode #{id} section is not valid UTF-8."
      end
      parsed = JSON.parse(data)
      unless parsed.is_a?(Array) && parsed.length == directory_entry(id).fetch(:count)
        raise BytecodeLoaderError, "BSharp Bytecode #{label} count does not match its section directory."
      end
      deep_symbolize(parsed)
    rescue JSON::ParserError
      raise BytecodeLoaderError, "BSharp Bytecode #{id} section is not valid canonical game data."
    end

    def deep_symbolize(value)
      case value
      when Hash
        value.each_with_object({}) { |(key, entry), result| result[key.to_sym] = deep_symbolize(entry) }
      when Array
        value.map { |entry| deep_symbolize(entry) }
      else
        value
      end
    end

    def parse_code!
      entry = directory_entry('CODE')
      data = section('CODE')
      ensure_bytes!(data, 0, 4, 'CODE block count')
      block_count = data.byteslice(0, 4).unpack1('V')
      unless block_count == entry.fetch(:count)
        raise BytecodeLoaderError, 'BSharp Bytecode CODE block count disagrees with its directory entry.'
      end
      directory_end = checked_add(4, checked_multiply(block_count, CODE_DIRECTORY_ENTRY_SIZE_BYTES, 'CODE directory'), 'CODE directory')
      if directory_end > data.bytesize
        raise BytecodeLoaderError, 'BSharp Bytecode CODE block directory is truncated.'
      end

      rows = block_count.times.map do |index|
        cursor = 4 + index * CODE_DIRECTORY_ENTRY_SIZE_BYTES
        id, offset, length, instruction_count = data.byteslice(cursor, CODE_DIRECTORY_ENTRY_SIZE_BYTES).unpack('V4')
        { id: id, offset: offset, length: length, instruction_count: instruction_count }
      end
      ids = rows.map { |row| row.fetch(:id) }
      raise BytecodeLoaderError, 'BSharp Bytecode contains a duplicate block identifier.' unless ids.uniq.length == ids.length
      unless ids == (0...block_count).to_a
        raise BytecodeLoaderError, 'BSharp Bytecode block identifiers must be zero-based and ordered.'
      end

      previous_end = directory_end
      @blocks = rows.map do |row|
        offset = row.fetch(:offset)
        length = row.fetch(:length)
        unless (offset % BytecodeContract::ALIGNMENT_BYTES).zero?
          raise BytecodeLoaderError, 'BSharp Bytecode code block is not four-byte aligned.'
        end
        block_end = checked_add(offset, length, 'CODE block')
        if offset < previous_end
          raise BytecodeLoaderError, 'BSharp Bytecode code blocks overlap.'
        end
        unless offset == previous_end
          raise BytecodeLoaderError, 'BSharp Bytecode CODE section contains an unexplained block gap.'
        end
        if block_end > data.bytesize
          raise BytecodeLoaderError, 'BSharp Bytecode code block extends outside the CODE section.'
        end

        cursor = offset
        instructions = row.fetch(:instruction_count).times.map do
          record, cursor = parse_instruction_record(data, cursor, block_end, context: :code)
          validate_action_instruction!(record)
          decorate_instruction(record)
        end
        unless cursor == block_end
          raise BytecodeLoaderError, 'BSharp Bytecode instruction count or block length is inconsistent.'
        end
        previous_end = block_end
        { id: row.fetch(:id), instructions: instructions }
      end
      unless previous_end == data.bytesize
        raise BytecodeLoaderError, 'BSharp Bytecode CODE section contains trailing unexplained data.'
      end
    end

    def parse_instruction_record(data, cursor, boundary, context:)
      ensure_record_boundary!(data, cursor, boundary, 4, 'instruction header')
      opcode, operand_count, reserved = data.byteslice(cursor, 4).unpack('CCv')
      raise BytecodeLoaderError, 'BSharp Bytecode instruction reserved field must be zero.' unless reserved.zero?
      name = instruction_name!(opcode)
      expected = INSTRUCTION_OPERAND_COUNTS.fetch(name)
      unless operand_count == expected
        raise BytecodeLoaderError, "BSharp Bytecode instruction #{name} has the wrong operand count."
      end
      record_length = checked_add(4, checked_multiply(operand_count, 4, 'instruction operands'), 'instruction record')
      ensure_record_boundary!(data, cursor, boundary, record_length, 'instruction record')
      operands = operand_count.zero? ? [] : data.byteslice(cursor + 4, operand_count * 4).unpack("V#{operand_count}")
      [{ name: name, opcode: opcode, operands: operands }, cursor + record_length]
    rescue KeyError
      raise BytecodeLoaderError, "BSharp Bytecode instruction 0x#{format('%02X', opcode)} is not defined."
    end

    def parse_condition_record(data, cursor, boundary)
      ensure_record_boundary!(data, cursor, boundary, 4, 'condition header')
      opcode, operand_count, reserved = data.byteslice(cursor, 4).unpack('CCv')
      raise BytecodeLoaderError, 'BSharp Bytecode condition reserved field must be zero.' unless reserved.zero?
      name = condition_name!(opcode)
      expected = CONDITION_OPERAND_COUNTS.fetch(name)
      unless operand_count == expected
        raise BytecodeLoaderError, "BSharp Bytecode condition #{name} has the wrong operand count."
      end
      record_length = checked_add(4, checked_multiply(operand_count, 4, 'condition operands'), 'condition record')
      ensure_record_boundary!(data, cursor, boundary, record_length, 'condition record')
      operands = data.byteslice(cursor + 4, operand_count * 4).unpack("V#{operand_count}")
      validate_condition_operands!(name, operands)
      [{ name: name, opcode: opcode, operands: operands }, cursor + record_length]
    end

    def validate_start_instruction!(record)
      name = record.fetch(:name)
      unless START_INSTRUCTIONS.include?(name)
        raise BytecodeLoaderError, "BSharp Bytecode instruction #{name} is not allowed in STRT."
      end
      operands = record.fetch(:operands)
      case name
      when 'START_STATE'
        validate_thing_index!(operands[0])
        validate_string_index!(operands[1])
        validate_optional_string_index!(operands[2])
      when 'START_RELATION'
        validate_thing_index!(operands[0])
        validate_string_index!(operands[1])
        validate_thing_index!(operands[2])
      when 'START_VALUE'
        validate_thing_index!(operands[0])
        validate_string_index!(operands[1])
        validate_whole_number!(operands[2])
      when 'START_TEXT_VALUE'
        require_profile_2!(name)
        validate_thing_index!(operands[0])
        validate_string_index!(operands[1])
        validate_string_index!(operands[2])
        if @strings.fetch(operands[1]) == 'damage'
          raise BytecodeLoaderError, 'BSharp Bytecode damage cannot use START_TEXT_VALUE.'
        end
      end
    end

    def validate_action_instruction!(record)
      name = record.fetch(:name)
      unless ACTION_INSTRUCTIONS.include?(name)
        raise BytecodeLoaderError, "BSharp Bytecode instruction #{name} is not allowed in CODE."
      end
      operands = record.fetch(:operands)
      case name
      when 'DAMAGE'
        validate_selector_operands!(operands[0], operands[1], ACTION_TARGET_SELECTORS, 'DAMAGE target')
        validate_whole_number!(operands[2], minimum: 1)
      when 'CHANGE_STATE'
        validate_selector_operands!(operands[0], operands[1], ACTION_TARGET_SELECTORS, 'CHANGE_STATE target')
        validate_string_index!(operands[2])
        validate_optional_string_index!(operands[3])
      when 'CHANGE_VALUE'
        validate_selector_operands!(operands[0], operands[1], ACTION_TARGET_SELECTORS, 'CHANGE_VALUE target')
        validate_string_index!(operands[2])
        validate_whole_number!(operands[3])
      when 'INCREASE_VALUE', 'DECREASE_VALUE'
        require_profile_5!(name)
        validate_selector_operands!(operands[0], operands[1], ACTION_TARGET_SELECTORS, "#{name} target")
        validate_string_index!(operands[2])
        validate_whole_number!(operands[3], minimum: 1)
      when 'CHANGE_TEXT_VALUE'
        require_profile_2!(name)
        validate_selector_operands!(operands[0], operands[1], ACTION_TARGET_SELECTORS, 'CHANGE_TEXT_VALUE target')
        validate_string_index!(operands[2])
        validate_string_index!(operands[3])
      when 'CARRY', 'UNLOCK'
        validate_selector_operands!(operands[0], operands[1], ACTION_TARGET_SELECTORS, "#{name} target")
      when 'CAUSE_EVENT'
        validate_selector_operands!(operands[0], operands[1], CAUSED_ACTOR_SELECTORS, 'CAUSE_EVENT actor')
        validate_string_index!(operands[2])
        validate_selector_operands!(operands[3], operands[4], CAUSED_TARGET_SELECTORS, 'CAUSE_EVENT target')
      end
    end

    def validate_condition_operands!(name, operands)
      case name
      when 'STATE_IS', 'STATE_ISNT'
        validate_thing_index!(operands[0])
        validate_string_index!(operands[1])
      when 'RELATION_EXISTS'
        validate_thing_index!(operands[0])
        validate_string_index!(operands[1])
        validate_thing_index!(operands[2])
      when 'VALUE_EQUALS'
        validate_thing_index!(operands[0])
        validate_string_index!(operands[1])
        validate_whole_number!(operands[2])
      when 'VALUE_AT_LEAST', 'VALUE_MORE_THAN', 'VALUE_AT_MOST', 'VALUE_LESS_THAN'
        require_profile_5!(name)
        validate_thing_index!(operands[0])
        validate_string_index!(operands[1])
        validate_whole_number!(operands[2])
      when 'TEXT_VALUE_EQUALS'
        require_profile_2!(name)
        validate_thing_index!(operands[0])
        validate_string_index!(operands[1])
        validate_string_index!(operands[2])
      end
    end

    def validate_count_agreement!
      expected = {
        'KIND' => @meta.fetch(:kind_count),
        'THNG' => @meta.fetch(:thing_count),
        'STRT' => @meta.fetch(:start_count),
        'EVNT' => @meta.fetch(:event_count),
        'IFRL' => @meta.fetch(:if_count),
        'CODE' => @meta.fetch(:block_count)
      }
      expected.each do |id, count|
        unless directory_entry(id).fetch(:count) == count
          raise BytecodeLoaderError, "BSharp Bytecode META count disagrees with #{id}."
        end
      end
      unless @blocks.length == @events.length + @if_rules.length
        raise BytecodeLoaderError, 'BSharp Bytecode code-block count must equal WHEN plus IF blocks.'
      end
    end

    def validate_string_usage_and_order!
      encountered = []
      @string_roles = Array.new(@strings.length) { [] }
      add_string_use(encountered, @meta.fetch(:profile_string_index), role: :identifier)
      add_string_use(encountered, @meta.fetch(:meaning_profile_string_index), role: :identifier)
      add_string_use(encountered, @meta.fetch(:fingerprint_algorithm_string_index), role: :identifier)
      @kinds.each { |entry| add_string_use(encountered, entry.fetch(:name_string_index), role: :identifier) }
      @things.each { |entry| add_string_use(encountered, entry.fetch(:name_string_index), role: :identifier) }
      @start_records.each { |record| collect_instruction_string_uses(encountered, record) }
      @events.each { |event| add_string_use(encountered, event.fetch(:action_string_index)) }
      @if_rules.each { |rule| collect_condition_string_uses(encountered, rule.fetch(:condition)) }
      @blocks.each do |block|
        block.fetch(:instructions).each { |instruction| collect_instruction_string_uses(encountered, instruction) }
      end
      unless encountered == (0...@strings.length).to_a
        if encountered.sort != (0...@strings.length).to_a
          raise BytecodeLoaderError, 'BSharp Bytecode string table contains an unused entry.'
        end
        raise BytecodeLoaderError, 'BSharp Bytecode string table order is not canonical.'
      end
      validate_string_roles!
    end

    def collect_instruction_string_uses(encountered, record)
      operands = record.fetch(:operands)
      case record.fetch(:name)
      when 'START_STATE'
        add_string_use(encountered, operands[1])
        add_optional_string_use(encountered, operands[2])
      when 'START_RELATION', 'START_VALUE'
        add_string_use(encountered, operands[1])
      when 'START_TEXT_VALUE'
        add_string_use(encountered, operands[1], role: :identifier)
        add_string_use(encountered, operands[2], role: :literal)
      when 'CHANGE_STATE'
        add_string_use(encountered, operands[2])
        add_optional_string_use(encountered, operands[3])
      when 'CHANGE_VALUE', 'INCREASE_VALUE', 'DECREASE_VALUE'
        add_string_use(encountered, operands[2])
      when 'CHANGE_TEXT_VALUE'
        add_string_use(encountered, operands[2], role: :identifier)
        add_string_use(encountered, operands[3], role: :literal)
      when 'CAUSE_EVENT'
        add_string_use(encountered, operands[2])
      end
    end

    def collect_condition_string_uses(encountered, condition)
      operands = condition.fetch(:operands)
      add_string_use(encountered, operands[1], role: :identifier)
      add_string_use(encountered, operands[2], role: :literal) if condition.fetch(:name) == 'TEXT_VALUE_EQUALS'
    end

    def add_string_use(encountered, index, role: :identifier)
      validate_string_index!(index)
      @string_roles[index] << role unless @string_roles[index].include?(role)
      encountered << index unless encountered.include?(index)
    end

    def add_optional_string_use(encountered, index)
      add_string_use(encountered, index) unless index == BytecodeContract::NO_REFERENCE_U32
    end

    def decorate_instruction(record)
      name = record.fetch(:name)
      operands = record.fetch(:operands)
      display = case name
                when 'START_STATE'
                  [thing_display(operands[0]), string_at(operands[1]), remove_display(operands[2])]
                when 'START_RELATION'
                  [thing_display(operands[0]), string_at(operands[1]), thing_display(operands[2])]
                when 'START_VALUE'
                  [thing_display(operands[0]), string_at(operands[1]), operands[2].to_s]
                when 'START_TEXT_VALUE'
                  [thing_display(operands[0]), string_at(operands[1]), quote_text(string_at(operands[2]))]
                when 'DAMAGE'
                  [selector_display(operands[0], operands[1]), operands[2].to_s]
                when 'CHANGE_STATE'
                  [selector_display(operands[0], operands[1]), string_at(operands[2]), remove_display(operands[3])]
                when 'CHANGE_VALUE', 'INCREASE_VALUE', 'DECREASE_VALUE'
                  [selector_display(operands[0], operands[1]), string_at(operands[2]), operands[3].to_s]
                when 'CHANGE_TEXT_VALUE'
                  [selector_display(operands[0], operands[1]), string_at(operands[2]), quote_text(string_at(operands[3]))]
                when 'CARRY', 'UNLOCK'
                  [selector_display(operands[0], operands[1])]
                when 'CAUSE_EVENT'
                  [selector_display(operands[0], operands[1]), string_at(operands[2]), selector_display(operands[3], operands[4])]
                else
                  []
                end
      record.merge(display: display)
    end

    def decorate_condition(condition)
      operands = condition.fetch(:operands)
      display = case condition.fetch(:name)
                when 'STATE_IS', 'STATE_ISNT'
                  [thing_display(operands[0]), string_at(operands[1])]
                when 'RELATION_EXISTS'
                  [thing_display(operands[0]), string_at(operands[1]), thing_display(operands[2])]
                when 'VALUE_EQUALS', 'VALUE_AT_LEAST', 'VALUE_MORE_THAN', 'VALUE_AT_MOST', 'VALUE_LESS_THAN'
                  [thing_display(operands[0]), string_at(operands[1]), operands[2].to_s]
                when 'TEXT_VALUE_EQUALS'
                  [thing_display(operands[0]), string_at(operands[1]), quote_text(string_at(operands[2]))]
                end
      condition.merge(display: display)
    end

    def selector_display(code, reference)
      name = selector_name!(code)
      case name
      when 'EXACT_THING' then thing_display(reference)
      when 'ONE_KIND' then "ONE_KIND[#{@kinds.fetch(reference).fetch(:name)}]"
      when 'BOUND_THAT_KIND' then "BOUND_THAT_KIND[#{@kinds.fetch(reference).fetch(:name)}]"
      when 'EVERY_KIND' then "EVERY_KIND[#{@kinds.fetch(reference).fetch(:name)}]"
      when 'NO_REFERENCE' then 'NONE'
      end
    end

    def thing_display(index)
      "THING[#{@things.fetch(index).fetch(:name)}]"
    end

    def remove_display(index)
      index == BytecodeContract::NO_REFERENCE_U32 ? 'REMOVE NONE' : "REMOVE #{string_at(index)}"
    end

    def string_at(index)
      validate_string_index!(index)
      @strings.fetch(index)
    end

    def validate_kind_ancestry!
      @kinds.each_index do |start|
        seen = {}
        cursor = start
        loop do
          parent = @kinds.fetch(cursor).fetch(:parent_index)
          break if parent == BytecodeContract::NO_REFERENCE_U32
          raise BytecodeLoaderError, 'BSharp Bytecode Kind ancestry contains a circle.' if seen[parent]
          seen[parent] = true
          cursor = parent
        end
      end
    end

    def validate_selector_operands!(code, reference, allowed, label)
      selector = selector_name!(code)
      validate_selector_context!(selector, reference, allowed, label)
    end

    def validate_selector_context!(selector, reference, allowed, label)
      unless allowed.include?(selector)
        raise BytecodeLoaderError, "BSharp Bytecode selector #{selector} is not allowed for #{label}."
      end
      case selector
      when 'EXACT_THING'
        validate_thing_index!(reference)
      when 'ONE_KIND', 'BOUND_THAT_KIND', 'EVERY_KIND'
        validate_kind_index!(reference)
      when 'NO_REFERENCE'
        unless reference == BytecodeContract::NO_REFERENCE_U32
          raise BytecodeLoaderError, "BSharp Bytecode NO_REFERENCE for #{label} must use 0xFFFFFFFF."
        end
      end
    end

    def selector_name!(code)
      name = BytecodeContract::SELECTORS.key(code)
      raise BytecodeLoaderError, "BSharp Bytecode selector code 0x#{format('%02X', code & 0xFF)} is invalid." unless name
      name
    end

    def instruction_name!(opcode)
      instructions = BytecodeContract.instruction_codes(profile_name)
      conditions = BytecodeContract.condition_codes(profile_name)
      name = instructions.key(opcode)
      return name if name
      if conditions.value?(opcode)
        raise BytecodeLoaderError, "BSharp Bytecode instruction code 0x#{format('%02X', opcode)} is unknown."
      end
      raise BytecodeLoaderError, "BSharp Bytecode instruction code 0x#{format('%02X', opcode)} is reserved."
    end

    def condition_name!(opcode)
      instructions = BytecodeContract.instruction_codes(profile_name)
      conditions = BytecodeContract.condition_codes(profile_name)
      name = conditions.key(opcode)
      return name if name
      if instructions.value?(opcode)
        raise BytecodeLoaderError, "BSharp Bytecode condition code 0x#{format('%02X', opcode)} is unknown."
      end
      raise BytecodeLoaderError, "BSharp Bytecode condition code 0x#{format('%02X', opcode)} is reserved."
    end

    def validate_string_index!(index)
      unless index.is_a?(Integer) && index.between?(0, @strings.length - 1)
        raise BytecodeLoaderError, "BSharp Bytecode string index #{index} is invalid."
      end
    end

    def validate_optional_string_index!(index)
      validate_string_index!(index) unless index == BytecodeContract::NO_REFERENCE_U32
    end

    def validate_kind_index!(index)
      count = directory_entry('KIND').fetch(:count)
      unless index.is_a?(Integer) && index.between?(0, count - 1)
        raise BytecodeLoaderError, "BSharp Bytecode Kind index #{index} is invalid."
      end
    end

    def validate_thing_index!(index)
      count = directory_entry('THNG').fetch(:count)
      unless index.is_a?(Integer) && index.between?(0, count - 1)
        raise BytecodeLoaderError, "BSharp Bytecode Thing index #{index} is invalid."
      end
    end

    def validate_whole_number!(value, minimum: 0)
      unless value.is_a?(Integer) && value.between?(minimum, BytecodeContract::WHOLE_NUMBER_RANGE.end)
        raise BytecodeLoaderError,
              "BSharp Bytecode whole number #{value} is outside #{minimum} through #{BytecodeContract::WHOLE_NUMBER_RANGE.end}."
      end
    end

    def validate_record_block_reference!(index)
      count = directory_entry('CODE').fetch(:count)
      unless index.is_a?(Integer) && index.between?(0, count - 1)
        raise BytecodeLoaderError, "BSharp Bytecode code-block reference #{index} is invalid."
      end
    end

    def normalize_fingerprint(value)
      return nil if value.nil?
      text = value.to_s.strip.downcase
      unless text.match?(/\A[0-9a-f]{64}\z/)
        raise BytecodeLoaderError, 'BSharp Bytecode comparison fingerprint must be 64 lowercase hexadecimal characters.'
      end
      text
    end

    def normalize_string(value)
      value.to_s.strip.downcase.gsub(/\s+/, ' ')
    end

    def profile_name
      { 1 => BytecodeContract::PROFILE, 2 => BytecodeContract::PROFILE_2, 3 => BytecodeContract::PROFILE_3, 4 => BytecodeContract::PROFILE_4, 5 => BytecodeContract::PROFILE_5 }.fetch(@profile_format_version)
    end

    def require_profile_2!(name)
      return if [2, 3, 4, 5].include?(@profile_format_version)

      raise BytecodeLoaderError, "BSharp Bytecode #{name} requires Profile 2 or later."
    end

    def require_profile_5!(name)
      return if @profile_format_version == 5

      raise BytecodeLoaderError, "BSharp Bytecode #{name} requires Profile 5."
    end

    def validate_string_roles!
      @strings.each_with_index do |value, index|
        roles = @string_roles.fetch(index)
        if roles.include?(:identifier) && value != normalize_string(value)
          raise BytecodeLoaderError, 'BSharp Bytecode identifier string contains noncanonical semantic text.'
        end
        next unless roles.include?(:literal)

        if value.include?("\n") || value.include?("\r")
          raise BytecodeLoaderError, 'BSharp Bytecode creator text must stay on one line.'
        end
        if value.include?('\\')
          raise BytecodeLoaderError, 'BSharp Bytecode creator text cannot contain unsupported escape sequences.'
        end
        if value.include?('#{')
          raise BytecodeLoaderError, 'BSharp Bytecode creator text cannot contain unsupported interpolation.'
        end
        if value.include?('"')
          raise BytecodeLoaderError, 'BSharp Bytecode creator text cannot contain an unescaped straight double quote.'
        end
      end
    end

    def validate_value_type_contracts!
      schemas = { 'damage' => :whole_number }
      assigned = {}

      @start_records.each do |record|
        type = case record.fetch(:name)
               when 'START_VALUE' then :whole_number
               when 'START_TEXT_VALUE' then :text
               end
        next unless type

        thing_index, value_name_index = record.fetch(:operands).first(2)
        value_name = @strings.fetch(value_name_index)
        key = [thing_index, value_name]
        if assigned[key]
          raise BytecodeLoaderError, "BSharp Bytecode assigns starting value #{value_name} more than once for #{thing_display(thing_index)}."
        end
        assigned[key] = true
        established = schemas[value_name]
        if established && established != type
          raise BytecodeLoaderError, "BSharp Bytecode starting value #{value_name} changes its established value type."
        end
        schemas[value_name] = type
      end

      @if_rules.each do |rule|
        condition = rule.fetch(:condition)
        type = condition.fetch(:name) == 'TEXT_VALUE_EQUALS' ? :text : :whole_number
        next unless %w[TEXT_VALUE_EQUALS VALUE_EQUALS VALUE_AT_LEAST VALUE_MORE_THAN VALUE_AT_MOST VALUE_LESS_THAN].include?(condition.fetch(:name))

        validate_known_bytecode_value_type!(schemas, condition.fetch(:operands)[1], type, condition.fetch(:name))
      end

      @blocks.each do |block|
        block.fetch(:instructions).each do |instruction|
          type = instruction.fetch(:name) == 'CHANGE_TEXT_VALUE' ? :text : :whole_number
          next unless %w[CHANGE_TEXT_VALUE CHANGE_VALUE INCREASE_VALUE DECREASE_VALUE].include?(instruction.fetch(:name))

          operands = instruction.fetch(:operands)
          validate_known_bytecode_value_type!(schemas, operands[2], type, instruction.fetch(:name))
        end
      end
    end

    def validate_known_bytecode_value_type!(schemas, value_name_index, expected_type, operation)
      value_name = @strings.fetch(value_name_index)
      established = schemas[value_name]
      if established.nil?
        schemas[value_name] = expected_type
        return
      end
      return if established == expected_type

      shown = established == :text ? 'text' : 'a whole number'
      raise BytecodeLoaderError,
            "BSharp Bytecode #{operation} conflicts with value #{value_name}, which is #{shown}."
    end

    def quote_text(value)
      %Q{"#{value}"}
    end

    def section(id)
      @sections.fetch(id)
    end

    def directory_entry(id)
      @directory.find { |entry| entry.fetch(:id) == id } || raise(BytecodeLoaderError, "BSharp Bytecode is missing section #{id}.")
    end

    def ensure_bytes!(data, cursor, length, label)
      end_offset = checked_add(cursor, length, label)
      raise BytecodeLoaderError, "BSharp Bytecode #{label} is truncated." if cursor.negative? || end_offset > data.bytesize
    end

    def ensure_record_boundary!(data, cursor, boundary, length, label)
      ensure_bytes!(data, cursor, length, label)
      if cursor + length > boundary
        raise BytecodeLoaderError, "BSharp Bytecode #{label} crosses its block boundary."
      end
    end

    def checked_add(left, right, label)
      unless left.is_a?(Integer) && right.is_a?(Integer) && left >= 0 && right >= 0
        raise BytecodeLoaderError, "BSharp Bytecode #{label} geometry is invalid."
      end
      result = left + right
      raise BytecodeLoaderError, "BSharp Bytecode #{label} arithmetic overflowed." if result > 0xFFFF_FFFF
      result
    end

    def checked_multiply(left, right, label)
      unless left.is_a?(Integer) && right.is_a?(Integer) && left >= 0 && right >= 0
        raise BytecodeLoaderError, "BSharp Bytecode #{label} geometry is invalid."
      end
      result = left * right
      raise BytecodeLoaderError, "BSharp Bytecode #{label} arithmetic overflowed." if result > 0xFFFF_FFFF
      result
    end

    def align(value)
      alignment = BytecodeContract::ALIGNMENT_BYTES
      value + ((alignment - (value % alignment)) % alignment)
    end

    def deep_freeze(value)
      case value
      when Hash
        value.each { |key, entry| deep_freeze(key); deep_freeze(entry) }
      when Array
        value.each { |entry| deep_freeze(entry) }
      end
      value.freeze
    end
  end
end

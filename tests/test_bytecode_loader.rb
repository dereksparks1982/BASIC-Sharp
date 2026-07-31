# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/world_save'

module BytecodeMutationSupport
  module_function

  def write_u16(bytes, offset, value)
    bytes[offset, 2] = [value].pack('v')
  end

  def write_u32(bytes, offset, value)
    bytes[offset, 4] = [value].pack('V')
  end

  def read_u32(bytes, offset)
    bytes.byteslice(offset, 4).unpack1('V')
  end

  def entries(bytes)
    8.times.map do |index|
      at = 32 + index * 16
      id, offset, length, count = bytes.byteslice(at, 16).unpack('a4V3')
      { id: id, offset: offset, length: length, count: count, directory_offset: at }
    end
  end

  def entry(bytes, id)
    entries(bytes).find { |candidate| candidate[:id] == id } || raise("missing #{id}")
  end

  def string_records(bytes)
    section = entry(bytes, 'STRS')
    cursor = section[:offset]
    section[:count].times.map do
      length = read_u32(bytes, cursor)
      record = { length_offset: cursor, payload_offset: cursor + 4, length: length }
      cursor += 4 + length
      cursor += (4 - ((4 + length) % 4)) % 4
      record
    end
  end

  def code_info(bytes)
    section = entry(bytes, 'CODE')
    base = section[:offset]
    count = read_u32(bytes, base)
    rows = count.times.map do |index|
      at = base + 4 + index * 16
      id, offset, length, instruction_count = bytes.byteslice(at, 16).unpack('V4')
      { row_offset: at, id: id, offset: offset, length: length, instruction_count: instruction_count }
    end
    [section, rows]
  end

  def instruction_offsets(bytes)
    section, rows = code_info(bytes)
    rows.flat_map do |row|
      cursor = section[:offset] + row[:offset]
      row[:instruction_count].times.map do
        current = cursor
        operand_count = bytes.getbyte(current + 1)
        cursor += 4 + operand_count * 4
        current
      end
    end
  end

  def mutate(original, mutation)
    bytes = original.dup.b
    options = {}
    dirs = entries(bytes)
    strs = dirs.find { |e| e[:id] == 'STRS' }
    meta = dirs.find { |e| e[:id] == 'META' }
    kind = dirs.find { |e| e[:id] == 'KIND' }
    thng = dirs.find { |e| e[:id] == 'THNG' }
    evnt = dirs.find { |e| e[:id] == 'EVNT' }
    ifrl = dirs.find { |e| e[:id] == 'IFRL' }
    code = dirs.find { |e| e[:id] == 'CODE' }

    case mutation
    when 'wrong_magic_bytes'
      bytes[0, 4] = 'NOPE'
    when 'unsupported_binary_format_version'
      write_u16(bytes, 4, 2)
    when 'unsupported_bytecode_profile'
      write_u32(bytes, meta[:offset], 1)
    when 'meaning_profile_mismatch'
      write_u32(bytes, meta[:offset] + 4, 0)
    when 'meaning_fingerprint_mismatch'
      options[:expected_fingerprint] = '0' * 64
    when 'wrong_header_size'
      write_u32(bytes, 8, 31)
    when 'nonzero_reserved_field'
      write_u32(bytes, 28, 1)
    when 'missing_required_section'
      bytes[dirs.last[:directory_offset], 4] = 'MISS'
    when 'duplicate_section'
      bytes[dirs[1][:directory_offset], 4] = dirs[0][:id]
    when 'wrong_section_order'
      first = bytes.byteslice(dirs[0][:directory_offset], 16)
      second = bytes.byteslice(dirs[1][:directory_offset], 16)
      bytes[dirs[0][:directory_offset], 16] = second
      bytes[dirs[1][:directory_offset], 16] = first
    when 'overlapping_section_data'
      write_u32(bytes, meta[:directory_offset] + 4, strs[:offset])
    when 'out_of_range_section_offset'
      write_u32(bytes, strs[:directory_offset] + 4, 0)
    when 'out_of_range_section_length'
      write_u32(bytes, code[:directory_offset] + 8, code[:length] + 4)
    when 'misaligned_section_data'
      write_u32(bytes, meta[:directory_offset] + 4, meta[:offset] + 1)
    when 'file_size_mismatch'
      write_u32(bytes, 24, bytes.bytesize + 1)
    when 'truncated_header'
      bytes = bytes.byteslice(0, 20)
    when 'truncated_section_directory'
      bytes = bytes.byteslice(0, 100)
      write_u32(bytes, 24, bytes.bytesize)
    when 'truncated_section_record'
      write_u32(bytes, strs[:offset], strs[:length] + 1)
    when 'trailing_unexplained_data'
      bytes << "\x00"
      write_u32(bytes, 24, bytes.bytesize)
    when 'invalid_utf8'
      record = string_records(bytes).fetch(3)
      bytes.setbyte(record[:payload_offset], 0xFF)
    when 'duplicate_deterministic_string_entry'
      records = string_records(bytes)
      source = records.fetch(3)
      target = records.fetch(10)
      raise 'fixture string sizes changed' unless source[:length] == target[:length]
      bytes[target[:payload_offset], target[:length]] = bytes.byteslice(source[:payload_offset], source[:length])
    when 'invalid_string_index'
      write_u32(bytes, kind[:offset], 0xFFFF_FFFE)
    when 'invalid_kind_parent_index'
      write_u32(bytes, kind[:offset] + 12 + 4, kind[:count])
    when 'kind_ancestry_circle'
      write_u32(bytes, kind[:offset] + 4, 0)
    when 'invalid_thing_kind_index'
      write_u32(bytes, thng[:offset] + 4, kind[:count])
    when 'invalid_selector_code'
      write_u32(bytes, evnt[:offset], 0xDEAD)
    when 'selector_not_allowed_in_context'
      write_u32(bytes, evnt[:offset], BasicSharp::BytecodeContract::SELECTORS.fetch('EVERY_KIND'))
      write_u32(bytes, evnt[:offset] + 4, 0)
    when 'invalid_thing_reference'
      write_u32(bytes, evnt[:offset], BasicSharp::BytecodeContract::SELECTORS.fetch('EXACT_THING'))
      write_u32(bytes, evnt[:offset] + 4, thng[:count])
    when 'invalid_kind_reference'
      write_u32(bytes, evnt[:offset] + 12, BasicSharp::BytecodeContract::SELECTORS.fetch('ONE_KIND'))
      write_u32(bytes, evnt[:offset] + 16, kind[:count])
    when 'invalid_code_block_reference'
      write_u32(bytes, evnt[:offset] + 20, code[:count])
    when 'unknown_instruction_code'
      bytes.setbyte(instruction_offsets(bytes).first, BasicSharp::BytecodeContract::CONDITIONS.fetch('STATE_IS'))
    when 'reserved_instruction_code'
      bytes.setbyte(instruction_offsets(bytes).first, 0)
    when 'wrong_instruction_operand_count'
      at = instruction_offsets(bytes).first
      bytes.setbyte(at + 1, bytes.getbyte(at + 1) + 1)
    when 'nonzero_instruction_reserved_field'
      write_u16(bytes, instruction_offsets(bytes).first + 2, 1)
    when 'unknown_condition_code'
      bytes.setbyte(ifrl[:offset], BasicSharp::BytecodeContract::INSTRUCTIONS.fetch('DAMAGE'))
    when 'reserved_condition_code'
      bytes.setbyte(ifrl[:offset], 0)
    when 'wrong_condition_operand_count'
      bytes.setbyte(ifrl[:offset] + 1, bytes.getbyte(ifrl[:offset] + 1) + 1)
    when 'whole_number_outside_range'
      damage = instruction_offsets(bytes).find { |at| bytes.getbyte(at) == BasicSharp::BytecodeContract::INSTRUCTIONS.fetch('DAMAGE') }
      write_u32(bytes, damage + 12, 0xFFFF_FFFF)
    when 'duplicate_block_identifier'
      _section, rows = code_info(bytes)
      write_u32(bytes, rows.fetch(1)[:row_offset], rows.fetch(0)[:id])
    when 'overlapping_code_blocks'
      _section, rows = code_info(bytes)
      write_u32(bytes, rows.fetch(1)[:row_offset] + 4, rows.fetch(0)[:offset])
    when 'instruction_crossing_block_boundary'
      _section, rows = code_info(bytes)
      write_u32(bytes, rows.fetch(0)[:row_offset] + 8, 8)
    else
      raise "unknown mutation #{mutation}"
    end
    [bytes, options]
  end
end

class TestBytecodeLoader < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  RUBY = RbConfig.ruby
  FIXTURE_PATH = File.join(ROOT, 'spec/bytecode_v1/BASIC_SHARP_BYTECODE_LOADER_FIXTURES_v1.json')
  SAMPLE_NAMES = %w[ask_demo every_guard first_room follow_up_events values_and_amounts world_save_demo].freeze

  def fixture
    @fixture ||= JSON.parse(File.read(FIXTURE_PATH))
  end

  def resolve_source(path)
    parser = BasicSharp::Parser.new(File.read(path))
    program = parser.parse
    BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  end

  def test_all_committed_samples_load_and_disassemble_exactly
    SAMPLE_NAMES.each do |name|
      binary_path = File.join(ROOT, 'samples', "#{name}.bsbc")
      loader = BasicSharp::BytecodeLoader.read(binary_path)
      assert_equal 'bsharp.bytecode.v1', loader.model.fetch(:profile), name
      assert_equal File.read("#{binary_path}.txt"), loader.disassembly, name
      assert loader.model.frozen?, name
      assert loader.model.fetch(:strings).all?(&:frozen?), name
    end
  end

  def test_source_and_bsir_fingerprint_comparisons_pass
    source = resolve_source(File.join(ROOT, 'samples/first_room.bsharp'))
    bsir = JSON.parse(File.read(File.join(ROOT, 'samples/first_room.bsir.json')))
    source_fingerprint = BasicSharp::WorldSave.program_fingerprint(source)
    bsir_fingerprint = BasicSharp::WorldSave.program_fingerprint(bsir)
    assert_equal source_fingerprint, bsir_fingerprint
    assert BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'), expected_fingerprint: source_fingerprint)
    assert BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'), expected_fingerprint: bsir_fingerprint)
  end

  def test_wrong_program_fingerprint_is_rejected_plainly
    error = assert_raises(BasicSharp::BytecodeLoaderError) do
      BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'), expected_fingerprint: '0' * 64)
    end
    assert_includes error.message, 'different BASIC# program meaning'
    assert_includes error.message, 'same .bsharp or .bsir.json'
  end

  def test_loaded_model_is_deeply_frozen_and_instances_are_isolated
    first = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'))
    second = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'))
    refute_same first.model, second.model
    assert_equal first.model, second.model
    assert_raises(FrozenError) { first.model[:profile].replace('changed') }
    assert_raises(FrozenError) { first.model[:kinds] << {} }
    assert_raises(FrozenError) { first.model[:kinds].first[:name].replace('changed') }
  end

  def test_all_twelve_valid_meaning_cases_emit_and_load
    paths = Dir[File.join(ROOT, 'spec/meaning_v1/cases/*/source.bsharp')].sort
    paths.first(12).each do |path|
      emitter = BasicSharp::BytecodeEmitter.new(resolve_source(path))
      loader = BasicSharp::BytecodeLoader.new(emitter.binary, expected_fingerprint: emitter.fingerprint)
      assert_equal emitter.disassembly, loader.disassembly, path
      assert_equal emitter.model, loader.model, path
    end
  end

  def test_fixture_covers_all_forty_one_contract_rules
    cases = fixture.fetch('malformed_cases')
    assert_equal 41, cases.length
    assert_equal BasicSharp::BytecodeContract::REQUIRED_MALFORMED_RULES, cases.map { |entry| entry.fetch('rule') }
    assert_equal 41, cases.map { |entry| entry.fetch('mutation') }.uniq.length
  end

  def test_all_forty_one_malformed_fixtures_are_rejected
    original = File.binread(File.join(ROOT, fixture.fetch('source_artifact')))
    fixture.fetch('malformed_cases').each do |entry|
      bytes, options = BytecodeMutationSupport.mutate(original, entry.fetch('mutation'))
      error = assert_raises(BasicSharp::BytecodeLoaderError, entry.fetch('id')) do
        BasicSharp::BytecodeLoader.new(bytes, **options)
      end
      assert_includes error.message, entry.fetch('expected_message'), entry.fetch('id')
    end
  end

  def test_every_truncated_prefix_is_rejected_without_partial_model
    original = File.binread(File.join(ROOT, 'samples/first_room.bsbc'))
    (0...original.bytesize).each do |length|
      bytes = original.byteslice(0, length)
      assert_raises(BasicSharp::BytecodeLoaderError, "prefix #{length}") do
        BasicSharp::BytecodeLoader.new(bytes)
      end
    end
  end

  def test_summary_is_deterministic_and_complete
    loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'))
    expected = {
      binary_format: 'bsharp.bytecode.bin', binary_format_version: 1,
      profile: 'bsharp.bytecode.v1', meaning_profile: 'bsharp.meaning.v1',
      fingerprint: '2065082c70bd242b0ec905b928855752a452100096354fde0e955f1ed88a3b84',
      strings: 26, kinds: 9, things: 7, start_records: 5,
      events: 4, if_rules: 2, code_blocks: 6, instructions: 9
    }
    assert_equal expected, loader.summary
    assert loader.summary.frozen?
  end

  def test_cli_validates_disassembles_and_compares
    compiler = File.join(ROOT, 'compiler/basic_sharp.rb')
    bytecode = File.join(ROOT, 'samples/first_room.bsbc')
    source = File.join(ROOT, 'samples/first_room.bsharp')
    bsir = File.join(ROOT, 'samples/first_room.bsir.json')

    stdout, stderr, status = Open3.capture3(RUBY, compiler, bytecode, chdir: ROOT)
    assert status.success?, stderr
    assert_includes stdout, 'BSharp Bytecode: valid'
    assert_includes stdout, 'profile: bsharp.bytecode.v1'
    assert_includes stdout, 'instructions: 9'

    stdout, stderr, status = Open3.capture3(RUBY, compiler, bytecode, '--disassemble-bytecode', chdir: ROOT)
    assert status.success?, stderr
    assert_equal File.read("#{bytecode}.txt"), stdout

    [source, bsir].each do |against|
      stdout, stderr, status = Open3.capture3(RUBY, compiler, bytecode, '--against', against, chdir: ROOT)
      assert status.success?, stderr
      assert_includes stdout, 'meaning comparison: PASS'
    end
  end

  def test_cli_executes_validated_bytecode_and_rejects_wrong_comparison_program
    compiler = File.join(ROOT, 'compiler/basic_sharp.rb')
    bytecode = File.join(ROOT, 'samples/first_room.bsbc')
    stdout, stderr, status = Open3.capture3(RUBY, compiler, bytecode, '--run', 'player attacks ember', chdir: ROOT)
    assert status.success?, stderr
    assert_includes stdout, 'BSharp Virtual Machine'
    assert_includes stdout, 'ember damage is now 1'

    _stdout, stderr, status = Open3.capture3(
      RUBY, compiler, bytecode, '--against', File.join(ROOT, 'samples/ask_demo.bsharp'), chdir: ROOT
    )
    refute status.success?
    assert_includes stderr, 'different BASIC# program meaning'
  end

  def test_validated_loader_is_the_only_vm_program_boundary
    loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'))
    machine = BasicSharp::BytecodeVirtualMachine.new(loader)
    assert_equal loader.model.fetch(:fingerprint), machine.program_fingerprint
    assert_equal loader.model, loader.model
    assert loader.model.frozen?
  end


end

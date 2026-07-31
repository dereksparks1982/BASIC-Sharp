# frozen_string_literal: true

require 'digest'
require 'json'
require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_contract'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'

class TestBytecodeProfile2 < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  PROFILE_PATH = File.join(ROOT, 'spec/bytecode_v2/BASIC_SHARP_BYTECODE_PROFILE_v2.json')
  FIXTURE_PATH = File.join(ROOT, 'spec/bytecode_v2/BASIC_SHARP_BYTECODE_PROFILE_v2_FIXTURES_v1.json')

  def profile
    @profile ||= JSON.parse(File.read(PROFILE_PATH, encoding: 'UTF-8'))
  end

  def resolve(path)
    parser = BasicSharp::Parser.new(File.read(path, encoding: 'UTF-8'))
    BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  end

  def emitter
    @emitter ||= BasicSharp::BytecodeEmitter.new(resolve(File.join(ROOT, 'samples/text_values.bsharp')))
  end

  def loader(bytes = emitter.binary)
    BasicSharp::BytecodeLoader.new(bytes)
  end

  def test_profile_2_contract_validates_and_has_fixed_codes
    assert BasicSharp::BytecodeContract.validate_profile!(profile, root: ROOT)
    assert_equal 'bsharp.bytecode.v2', profile.dig('artifact', 'profile')
    assert_equal 'bsharp.meaning.v2', profile.dig('artifact', 'required_meaning_profile')
    assert_equal 0x13, BasicSharp::BytecodeContract::PROFILE_2_INSTRUCTIONS.fetch('START_TEXT_VALUE')
    assert_equal 0x26, BasicSharp::BytecodeContract::PROFILE_2_INSTRUCTIONS.fetch('CHANGE_TEXT_VALUE')
    assert_equal 0x34, BasicSharp::BytecodeContract::PROFILE_2_CONDITIONS.fetch('TEXT_VALUE_EQUALS')
  end

  def test_source_and_saved_bsir_emit_identical_profile_2_artifacts
    bsir = JSON.parse(File.read(File.join(ROOT, 'samples/text_values.bsir.json'), encoding: 'UTF-8'))
    from_bsir = BasicSharp::BytecodeEmitter.new(bsir)
    assert_equal emitter.binary, from_bsir.binary
    assert_equal emitter.disassembly, from_bsir.disassembly
    assert_equal 'bsharp.bytecode.v2', loader.model.fetch(:profile)
    assert_equal 'bsharp.meaning.v2', loader.model.fetch(:meaning_profile)
    assert_equal [1, 2], emitter.binary.byteslice(4, 4).unpack('v2')
  end

  def test_profile_2_instructions_and_exact_literal_strings_survive_loading
    model = loader.model
    assert_equal %w[START_TEXT_VALUE START_TEXT_VALUE], model.fetch(:start_records).reject { |entry| entry.fetch(:name) == 'START_VALUE' }.map { |entry| entry.fetch(:name) }
    assert_equal 'CHANGE_TEXT_VALUE', model.fetch(:blocks).first.fetch(:instructions).first.fetch(:name)
    assert_equal 'TEXT_VALUE_EQUALS', model.fetch(:if_rules).first.fetch(:condition).fetch(:name)
    assert_includes model.fetch(:strings), 'North  Gate!'
    assert_includes model.fetch(:strings), 'OPEN — RubyVM!'
    assert_includes loader.disassembly, 'CHANGE_TEXT_VALUE EVERY_KIND[gate] title "OPEN — RubyVM!"'
  end

  def test_creator_text_is_not_mistaken_for_runtime_leakage
    assert_includes emitter.binary, 'RubyVM'
    assert_equal 'bsharp.bytecode.v2', loader.model.fetch(:profile)
  end

  def test_profile_2_instruction_inside_profile_1_is_rejected
    bytes = File.binread(File.join(ROOT, 'samples/first_room.bsbc')).dup
    start = section(bytes, 'STRT')
    bytes.setbyte(start.fetch(:offset), BasicSharp::BytecodeContract::PROFILE_2_INSTRUCTIONS.fetch('START_TEXT_VALUE'))
    error = assert_raises(BasicSharp::BytecodeLoaderError) { BasicSharp::BytecodeLoader.new(bytes) }
    assert_includes error.message, 'reserved'
  end

  def test_identifier_and_literal_string_roles_are_validated_separately
    changed_identifier = replace_string(emitter.binary, 'title', 'Title')
    error = assert_raises(BasicSharp::BytecodeLoaderError) { loader(changed_identifier) }
    assert_includes error.message, 'identifier string'

    changed_literal = replace_string(emitter.binary, 'North  Gate!', "North\n Gate!")
    error = assert_raises(BasicSharp::BytecodeLoaderError) { loader(changed_literal) }
    assert_includes error.message, 'stay on one line'
  end

  def test_unsupported_literal_boundaries_are_rejected_from_binary
    {
      'backslash' => ['North  Gate!', 'North\\ Gate!', 'escape sequences'],
      'interpolation' => ['North  Gate!', 'Nor#{thGate}', 'interpolation'],
      'quote' => ['North  Gate!', 'North" Gate!', 'straight double quote']
    }.each do |label, (before, after, message)|
      error = assert_raises(BasicSharp::BytecodeLoaderError, label) { loader(replace_string(emitter.binary, before, after)) }
      assert_includes error.message, message, label
    end
  end

  def test_text_and_whole_number_condition_type_conflict_is_rejected
    bytes = emitter.binary.dup
    condition = section(bytes, 'IFRL')
    bytes.setbyte(condition.fetch(:offset), BasicSharp::BytecodeContract::CONDITIONS.fetch('VALUE_EQUALS'))
    error = assert_raises(BasicSharp::BytecodeLoaderError) { loader(bytes) }
    assert_includes error.message, 'VALUE_EQUALS conflicts'
    assert_includes error.message, 'which is text'
  end

  def test_profile_1_sample_bytes_remain_unchanged
    %w[ask_demo every_guard first_room follow_up_events values_and_amounts world_save_demo].each do |name|
      generated = BasicSharp::BytecodeEmitter.new(resolve(File.join(ROOT, "samples/#{name}.bsharp"))).binary
      committed = File.binread(File.join(ROOT, "samples/#{name}.bsbc"))
      assert_equal Digest::SHA256.hexdigest(committed), Digest::SHA256.hexdigest(generated), name
      assert_equal committed, generated, name
    end
  end

  def test_fixture_hashes_lock_profile_2_output
    fixture = JSON.parse(File.read(FIXTURE_PATH, encoding: 'UTF-8'))
    assert_equal 'bsharp.bytecode.profile2.fixtures.json', fixture.fetch('format')
    assert_equal 1, fixture.fetch('format_version')
    fixture.fetch('files').each do |entry|
      bytes = File.binread(File.join(ROOT, entry.fetch('path')))
      assert_equal entry.fetch('bytes'), bytes.bytesize, entry.fetch('path')
      assert_equal entry.fetch('sha256'), Digest::SHA256.hexdigest(bytes), entry.fetch('path')
    end
    fixture.fetch('meaning_cases').each do |entry|
      generated = BasicSharp::BytecodeEmitter.new(resolve(File.join(ROOT, entry.fetch('source'))))
      assert_equal entry.fetch('binary_bytes'), generated.binary.bytesize, entry.fetch('id')
      assert_equal entry.fetch('binary_sha256'), Digest::SHA256.hexdigest(generated.binary), entry.fetch('id')
      assert_equal entry.fetch('disassembly_bytes'), generated.disassembly.bytesize, entry.fetch('id')
      assert_equal entry.fetch('disassembly_sha256'), Digest::SHA256.hexdigest(generated.disassembly), entry.fetch('id')
    end
    assert_equal BasicSharp::BytecodeContract::PROFILE_2_REQUIRED_MALFORMED_RULES,
                 fixture.fetch('malformed_cases')
  end

  private

  def section(bytes, id)
    8.times do |index|
      at = 32 + index * 16
      name, offset, length, count = bytes.byteslice(at, 16).unpack('a4V3')
      return { offset: offset, length: length, count: count } if name == id
    end
    raise "missing section #{id}"
  end

  def string_records(bytes)
    strings = section(bytes, 'STRS')
    cursor = strings.fetch(:offset)
    strings.fetch(:count).times.map do
      length = bytes.byteslice(cursor, 4).unpack1('V')
      payload = cursor + 4
      record = { offset: payload, length: length, value: bytes.byteslice(payload, length).force_encoding(Encoding::UTF_8) }
      cursor += 4 + length
      cursor += (4 - ((4 + length) % 4)) % 4
      record
    end
  end

  def replace_string(binary, before, after)
    raise 'replacement must preserve byte length' unless before.bytesize == after.bytesize
    bytes = binary.dup
    record = string_records(bytes).find { |entry| entry.fetch(:value) == before } || raise("missing string #{before.inspect}")
    bytes[record.fetch(:offset), record.fetch(:length)] = after.b
    bytes
  end
end

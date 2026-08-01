#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
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


def assert_pass(condition, label)
  raise "#{label}: FAIL" unless condition
end

ROOT = File.expand_path('..', __dir__)
SAMPLES = %w[ask_demo every_guard first_room follow_up_events values_and_amounts world_save_demo].freeze
FIXTURE_PATH = File.join(ROOT, 'spec/bytecode_v1/BASIC_SHARP_BYTECODE_LOADER_FIXTURES_v1.json')
FIXTURE = JSON.parse(File.read(FIXTURE_PATH))

def resolve(path)
  parser = BasicSharp::Parser.new(File.read(path))
  program = parser.parse
  BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
end

loaded_disassembly_parity = true
header_directory = true
string_table = true
meta_counts = true
kind_thing = true
start_valid = true
event_valid = true
if_valid = true
code_valid = true
selector_refs = true
SAMPLES.each do |name|
  path = File.join(ROOT, 'samples', "#{name}.bsbc")
  loader = BasicSharp::BytecodeLoader.read(path)
  loaded_disassembly_parity &&= loader.disassembly == File.read("#{path}.txt")
  summary = loader.summary
  header_directory &&= summary[:binary_format] == 'bsharp.bytecode.bin' && summary[:binary_format_version] == 1
  string_table &&= loader.model[:strings].uniq.length == loader.model[:strings].length
  meta_counts &&= summary[:code_blocks] == summary[:events] + summary[:if_rules]
  kind_thing &&= loader.model[:kinds].each_with_index.all? { |entry, index| entry[:parent_index] == BasicSharp::BytecodeContract::NO_REFERENCE_U32 || entry[:parent_index] < index }
  kind_thing &&= loader.model[:things].each_with_index.all? { |entry, index| entry[:definition_order] == index }
  start_valid &&= loader.model[:start_records].all? { |entry| %w[START_STATE START_RELATION START_VALUE].include?(entry[:name]) }
  event_valid &&= loader.model[:events].each_with_index.all? { |entry, index| entry[:block_index] == index && entry[:source_order] == index }
  if_valid &&= loader.model[:if_rules].each_with_index.all? { |entry, index| entry[:block_index] == loader.model[:events].length + index }
  code_valid &&= loader.model[:blocks].each_with_index.all? { |entry, index| entry[:id] == index }
  selector_refs &&= loader.model[:events].all? { |entry| !entry[:actor_selector].nil? && !entry[:target_selector].nil? }
end

text_loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/text_values.bsbc'))
text_profile = text_loader.model.fetch(:profile) == 'bsharp.bytecode.v2' &&
               text_loader.model.fetch(:meaning_profile) == 'bsharp.meaning.v2' &&
               text_loader.model.fetch(:strings).include?('OPEN — RubyVM!') &&
               text_loader.disassembly == File.read(File.join(ROOT, 'samples/text_values.bsbc.txt'))
assert_pass(text_profile, 'Profile 2 role-aware string loading')
assert_pass(loaded_disassembly_parity, 'Loaded disassembly parity')
assert_pass(header_directory, 'Header and directory validation')
assert_pass(string_table, 'String-table validation')
assert_pass(meta_counts, 'META and count agreement')
assert_pass(kind_thing, 'Kind and Thing validation')
assert_pass(start_valid, 'START validation')
assert_pass(event_valid, 'WHEN validation')
assert_pass(if_valid, 'IF validation')
assert_pass(code_valid, 'CODE validation')
assert_pass(selector_refs, 'Selector and reference validation')

meaning_paths = Dir[File.join(ROOT, 'spec/meaning_v1/cases/*/source.bsharp')].sort
meaning_paths.first(12).each do |path|
  emitter = BasicSharp::BytecodeEmitter.new(resolve(path))
  loader = BasicSharp::BytecodeLoader.new(emitter.binary, expected_fingerprint: emitter.fingerprint)
  assert_pass(loader.model == emitter.model, "Meaning load #{File.basename(File.dirname(path))}")
  assert_pass(loader.disassembly == emitter.disassembly, "Meaning disassembly #{File.basename(File.dirname(path))}")
end

source_doc = resolve(File.join(ROOT, 'samples/first_room.bsharp'))
bsir_doc = JSON.parse(File.read(File.join(ROOT, 'samples/first_room.bsir.json')))
source_fp = BasicSharp::WorldSave.program_fingerprint(source_doc)
bsir_fp = BasicSharp::WorldSave.program_fingerprint(bsir_doc)
assert_pass(source_fp == bsir_fp, 'Source and BSIR fingerprint parity')
BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'), expected_fingerprint: source_fp)
BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'), expected_fingerprint: bsir_fp)

first = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'))
second = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'))
assert_pass(first.model == second.model && !first.model.equal?(second.model), 'Repeated-load determinism')
assert_pass(first.model.frozen? && first.model[:strings].all?(&:frozen?), 'Immutable trusted model')
game_loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/demon_killer_controls.bsbc'))
assert_pass(game_loader.model[:profile] == 'bsharp.bytecode.v3' && game_loader.model[:controls].length == 1, 'Profile 3 game sections')

original = File.binread(File.join(ROOT, FIXTURE.fetch('source_artifact')))
assert_pass(FIXTURE.fetch('malformed_case_count') == 41, 'Malformed fixture count')
FIXTURE.fetch('malformed_cases').each do |entry|
  bytes, options = BytecodeMutationSupport.mutate(original, entry.fetch('mutation'))
  begin
    BasicSharp::BytecodeLoader.new(bytes, **options)
    raise "Malformed fixture accepted: #{entry.fetch('id')}"
  rescue BasicSharp::BytecodeLoaderError => error
    assert_pass(error.message.include?(entry.fetch('expected_message')), "Malformed message #{entry.fetch('id')}")
  end
end

(0...original.bytesize).each do |length|
  begin
    BasicSharp::BytecodeLoader.new(original.byteslice(0, length))
    raise "Truncated prefix accepted: #{length}"
  rescue BasicSharp::BytecodeLoaderError
    # expected
  end
end

puts 'BSharp Bytecode Loader v0.1.35'
puts "Profile 1 sample artifacts: #{SAMPLES.length}"
puts 'Profile 2 sample artifacts: 1'
puts 'Profile 3 sample artifacts: 1'
puts 'Valid Meaning Profile cases: 12'
puts "Malformed fixture cases: #{FIXTURE.fetch('malformed_case_count')}"
puts
puts 'Header and directory validation: PASS'
puts 'Section boundaries and padding: PASS'
puts 'String-table validation: PASS'
puts 'META and count agreement: PASS'
puts 'Kind and Thing validation: PASS'
puts 'START validation: PASS'
puts 'WHEN validation: PASS'
puts 'IF validation: PASS'
puts 'CODE validation: PASS'
puts 'Selector and reference validation: PASS'
puts 'Source fingerprint comparison: PASS'
puts 'BSIR fingerprint comparison: PASS'
puts 'Loaded disassembly parity: PASS'
puts 'Repeated-load determinism: PASS'
puts 'Immutable trusted model: PASS'
puts 'Complete malformed rejection: PASS'
puts 'Truncation sweep: PASS'
puts 'No partial model exposure: PASS'
puts 'Profile 2 role-aware string loading: PASS'
puts
puts 'BYTECODE LOADER: PASS'

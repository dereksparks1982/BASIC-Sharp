#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'json'
require_relative '../compiler/small_compiler_subset_ir_emitter'
require_relative '../compiler/small_compiler_subset_bsbc_encoder'
require_relative '../compiler/small_compiler_subset_bsbc_loader'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/small_compiler_subset_bsbc_execution_parity'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_LOADER_INDEPENDENCE_v1.json')
LOADER_PATH = File.join(ROOT, 'compiler/small_compiler_subset_bsbc_loader.rb')

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset BSBC loader independence failed: #{message}" unless condition
end

def normalize(value)
  case value
  when Hash then value.each_with_object({}) { |(key, child), result| result[key.to_s] = normalize(child) }.sort.to_h
  when Array then value.map { |child| normalize(child) }
  else value
  end
end

def digest_json(value)
  Digest::SHA256.hexdigest(JSON.generate(normalize(value)))
end

def put_u16(bytes, offset, value)
  copy = bytes.dup
  copy[offset, 2] = [value].pack('v')
  copy
end

def put_u32(bytes, offset, value)
  copy = bytes.dup
  copy[offset, 4] = [value].pack('V')
  copy
end

def directory(bytes)
  header = bytes.byteslice(0, 32).unpack('a4v2V6')
  section_count = header.fetch(4)
  directory_offset = header.fetch(5)
  entry_size = header.fetch(6)
  section_count.times.each_with_object({}) do |index, result|
    cursor = directory_offset + index * entry_size
    id, offset, length, count = bytes.byteslice(cursor, entry_size).unpack('a4V3')
    result[id] = { cursor: cursor, offset: offset, length: length, count: count }
  end
end

def code_instruction_offset(bytes)
  code = directory(bytes).fetch('CODE')
  block_count = bytes.byteslice(code.fetch(:offset), 4).unpack1('V')
  raise 'fixture needs a CODE block' if block_count.zero?
  _id, relative_offset, _length, _instruction_count = bytes.byteslice(code.fetch(:offset) + 4, 16).unpack('V4')
  code.fetch(:offset) + relative_offset
end

def malformed_cases(base)
  {
    'bad_magic' => begin
      copy = base.dup
      copy.setbyte(0, 0)
      copy
    end,
    'unsupported_profile' => put_u16(base, 6, 8),
    'bad_section_offset' => begin
      first = directory(base).values.first
      put_u32(base, first.fetch(:cursor) + 4, 1)
    end,
    'overlapping_sections' => begin
      entries = directory(base).values
      put_u32(base, entries.fetch(1).fetch(:cursor) + 4, entries.fetch(0).fetch(:offset))
    end,
    'truncated_string_record' => begin
      strs = directory(base).fetch('STRS')
      put_u32(base, strs.fetch(:offset), 0x7FFF_FFFF)
    end,
    'invalid_string_index' => begin
      meta = directory(base).fetch('META')
      put_u32(base, meta.fetch(:offset), 0xFFFF_FFFF)
    end,
    'invalid_kind_index' => begin
      things = directory(base).fetch('THNG')
      put_u32(base, things.fetch(:offset) + 4, 0xFFFF_FFFF)
    end,
    'invalid_thing_index' => begin
      start = directory(base).fetch('STRT')
      put_u32(base, start.fetch(:offset) + 4, 0xFFFF_FFFF)
    end,
    'invalid_opcode' => begin
      copy = base.dup
      copy.setbyte(code_instruction_offset(copy), 0xFF)
      copy
    end,
    'invalid_selector' => begin
      events = directory(base).fetch('EVNT')
      put_u32(base, events.fetch(:offset), 0xFFFF_FFFF)
    end,
    'invalid_condition' => begin
      copy = base.dup
      if_rules = directory(copy).fetch('IFRL')
      copy.setbyte(if_rules.fetch(:offset), 0xFF)
      copy
    end,
    'invalid_operand_width' => begin
      copy = base.dup
      copy.setbyte(code_instruction_offset(copy) + 1, 0)
      copy
    end,
    'bad_instruction_target' => begin
      events = directory(base).fetch('EVNT')
      put_u32(base, events.fetch(:offset) + 20, 0xFFFF_FFFF)
    end,
    'incorrect_record_count' => begin
      things = directory(base).fetch('THNG')
      put_u32(base, things.fetch(:cursor) + 12, things.fetch(:count) + 1)
    end,
    'truncated_artifact' => begin
      copy = base.byteslice(0, base.bytesize - 1).dup
      put_u32(copy, 24, copy.bytesize)
    end,
    'trailing_invalid_data' => begin
      copy = base.dup << "\x01"
      put_u32(copy, 24, copy.bytesize)
    end
  }
end

def rejection_message(loader_class, bytes)
  loader_class.new(bytes)
  'ACCEPTED'
rescue StandardError => error
  error.message
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.bsbc_loader_independence.contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_contract!(spec.fetch('status') == 'bsbc_loader_independent_under_ruby_referee', 'status changed')

loader_source = File.read(LOADER_PATH, encoding: 'UTF-8')
assert_contract!(!loader_source.include?("require_relative 'bytecode_loader'"), 'independent loader requires production BytecodeLoader')
assert_contract!(!loader_source.match?(/\bBytecodeLoader\.new\b/), 'independent loader instantiates production BytecodeLoader')
assert_contract!(!loader_source.match?(/class\s+SmallCompilerSubsetBSBCLoader\s*<\s*BytecodeLoader/), 'independent loader inherits production BytecodeLoader')

fixture = spec.fetch('fixture')
source = File.read(File.join(ROOT, fixture.fetch('source_path')), encoding: 'UTF-8')
ir_emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(source)
encoder = BasicSharp::SmallCompilerSubsetBSBCEncoder.new(ir_emitter.bsharp_ir)
subset = BasicSharp::SmallCompilerSubsetBSBCLoader.new(encoder.binary, expected_fingerprint: encoder.fingerprint)
referee = BasicSharp::BytecodeLoader.new(encoder.binary, expected_fingerprint: encoder.fingerprint)

assert_contract!(encoder.profile == fixture.fetch('expected_profile'), 'dedicated fixture profile changed')
assert_contract!(encoder.binary.bytesize == fixture.fetch('expected_binary_bytes'), 'dedicated fixture byte count changed')
assert_contract!(Digest::SHA256.hexdigest(encoder.binary) == fixture.fetch('expected_binary_sha256'), 'dedicated fixture binary digest changed')
assert_contract!(Digest::SHA256.hexdigest(encoder.disassembly) == fixture.fetch('expected_disassembly_sha256'), 'dedicated fixture disassembly digest changed')
assert_contract!(digest_json(ir_emitter.bsharp_ir) == fixture.fetch('expected_bsharp_ir_sha256'), 'dedicated fixture IR digest changed')
assert_contract!(encoder.fingerprint == fixture.fetch('expected_fingerprint'), 'dedicated fixture fingerprint changed')
assert_contract!(digest_json(subset.summary) == fixture.fetch('expected_loader_summary_sha256'), 'dedicated fixture loader summary changed')
assert_contract!(digest_json(subset.model) == fixture.fetch('expected_loader_model_sha256'), 'dedicated fixture loader model changed')
assert_contract!(normalize(subset.model) == normalize(referee.model), 'trusted model differs from production referee')
assert_contract!(normalize(subset.summary) == normalize(referee.summary), 'loader summary differs from production referee')
assert_contract!(subset.fingerprint == referee.fingerprint, 'fingerprint differs from production referee')
assert_contract!(subset.disassembly == referee.disassembly, 'disassembly differs from production referee')

# The independent loader must continue to work even when the production loader is disabled.
klass = BasicSharp::BytecodeLoader
klass.singleton_class.class_eval do
  alias_method :__v076_original_new, :new
  define_method(:new) { |*| raise 'production BytecodeLoader invoked from independent path' }
end
begin
  isolated = BasicSharp::SmallCompilerSubsetBSBCLoader.new(encoder.binary, expected_fingerprint: encoder.fingerprint)
  assert_contract!(isolated.fingerprint == encoder.fingerprint, 'independent valid load failed with production loader disabled')
ensure
  klass.singleton_class.class_eval do
    alias_method :new, :__v076_original_new
    remove_method :__v076_original_new
  end
end

cases = malformed_cases(encoder.binary)
assert_contract!(cases.keys == spec.fetch('malformed_campaign'), 'malformed campaign names changed')
cases.each do |name, bytes|
  subset_message = rejection_message(BasicSharp::SmallCompilerSubsetBSBCLoader, bytes)
  referee_message = rejection_message(BasicSharp::BytecodeLoader, bytes)
  assert_contract!(subset_message != 'ACCEPTED', "subset loader accepted malformed case #{name}")
  assert_contract!(referee_message != 'ACCEPTED', "production referee accepted malformed case #{name}")
  assert_contract!(subset_message == referee_message, "malformed rejection differs for #{name}")
end

parity_source = File.read(File.join(ROOT, 'compiler/small_compiler_subset_bsbc_execution_parity.rb'), encoding: 'UTF-8')
assert_contract!(parity_source.include?('SmallCompilerSubsetBSBCLoader.new'), 'execution parity does not load through independent loader')
assert_contract!(parity_source.include?('SmallCompilerSubsetBSBCVirtualMachine.new(subset_loader)'), 'BSharp VM execution lane is not fed by subset-loaded model')

references = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json'
]
references.each do |relative|
  text = File.read(File.join(ROOT, relative), encoding: 'UTF-8')
  assert_contract!(text.include?('spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_LOADER_INDEPENDENCE_v1.json'), "#{relative} does not reference the BSBC loader independence spec")
end

puts "BASIC# Small Compiler Subset BSBC Loader Independence v#{BasicSharp::VERSION}"
puts 'Subset loader parses its own BSBC input: PASS'
puts 'Production BytecodeLoader used only as referee: PASS'
puts 'Trusted-model structural parity: PASS'
puts 'Loader-summary and fingerprint parity: PASS'
puts 'Instruction, selector, and condition decoding parity: PASS'
puts "Malformed artifact rejection parity: PASS (#{cases.length} mutations)"
puts 'BSharp VM accepts subset-loaded model: PASS'
puts 'Profiles 1-7 remain unchanged: PASS'
puts 'SMALL COMPILER SUBSET BSBC LOADER INDEPENDENCE: PASS'

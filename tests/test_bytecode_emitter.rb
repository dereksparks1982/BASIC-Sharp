# frozen_string_literal: true

require 'digest'
require 'json'
require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/world_save'

class TestBytecodeEmitter < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  RUBY = RbConfig.ruby
  SAMPLE_NAMES = %w[ask_demo every_guard first_room follow_up_events values_and_amounts world_save_demo].freeze

  def resolve_source(path)
    parser = BasicSharp::Parser.new(File.read(path))
    program = parser.parse
    BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  end

  def source_document(name)
    resolve_source(File.join(ROOT, 'samples', "#{name}.bsharp"))
  end

  def bsir_document(name)
    JSON.parse(File.read(File.join(ROOT, 'samples', "#{name}.bsir.json")))
  end

  def test_all_six_samples_have_source_and_bsir_byte_parity
    SAMPLE_NAMES.each do |name|
      source = BasicSharp::BytecodeEmitter.new(source_document(name))
      bsir = BasicSharp::BytecodeEmitter.new(bsir_document(name))
      assert_equal source.binary, bsir.binary, name
      assert_equal source.disassembly, bsir.disassembly, name
      assert_equal BasicSharp::WorldSave.program_fingerprint(source_document(name)), source.fingerprint, name
    end
  end

  def test_repeated_emission_is_byte_identical
    first = BasicSharp::BytecodeEmitter.new(source_document('first_room'))
    second = BasicSharp::BytecodeEmitter.new(source_document('first_room'))
    assert_equal first.binary, second.binary
    assert_equal first.disassembly, second.disassembly
    assert_equal Digest::SHA256.hexdigest(first.binary), Digest::SHA256.hexdigest(second.binary)
  end

  def test_blank_lines_and_line_numbers_do_not_change_output
    original = File.read(File.join(ROOT, 'samples/first_room.bsharp'))
    spaced = original.lines.map { |line| line.strip.empty? ? line : "\n#{line}" }.join
    parser = BasicSharp::Parser.new(spaced)
    program = parser.parse
    document = BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
    original_emitter = BasicSharp::BytecodeEmitter.new(source_document('first_room'))
    spaced_emitter = BasicSharp::BytecodeEmitter.new(document)
    assert_equal original_emitter.binary, spaced_emitter.binary
    assert_equal original_emitter.disassembly, spaced_emitter.disassembly
  end

  def test_header_and_section_directory_match_contract
    bytes = BasicSharp::BytecodeEmitter.new(source_document('first_room')).binary
    assert_equal 'BSBC', bytes.byteslice(0, 4)
    assert_equal [1, 1], bytes.byteslice(4, 4).unpack('v2')
    assert_equal [32, 8, 32, 16, bytes.bytesize, 0], bytes.byteslice(8, 24).unpack('V6')
    entries = parse_directory(bytes)
    assert_equal BasicSharp::BytecodeContract::SECTION_ORDER, entries.map { |entry| entry[:id] }
    assert_equal 8, entries.length
    entries.each do |entry|
      assert_equal 0, entry[:offset] % 4
      assert_operator entry[:offset], :>=, 160
      assert_operator entry[:offset] + entry[:length], :<=, bytes.bytesize
    end
  end

  def test_mandatory_strings_are_first
    emitter = BasicSharp::BytecodeEmitter.new(source_document('first_room'))
    assert_equal [
      'bsharp.bytecode.v1',
      'bsharp.meaning.v1',
      'sha256-bsir-meaning-v1'
    ], emitter.model.fetch(:strings).first(3)
    assert_equal emitter.model.fetch(:strings).length, emitter.model.fetch(:strings).uniq.length
  end

  def test_kind_ancestors_precede_descendants
    kinds = BasicSharp::BytecodeEmitter.new(source_document('first_room')).model.fetch(:kinds)
    names = kinds.map { |entry| entry.fetch(:name) }
    assert_operator names.index('thing'), :<, names.index('creature')
    assert_operator names.index('creature'), :<, names.index('dragon')
    assert_operator names.index('dragon'), :<, names.index('wyrm')
    kinds.each_with_index do |entry, index|
      parent = entry.fetch(:parent_index)
      next if parent == BasicSharp::BytecodeContract::NO_REFERENCE_U32
      assert_operator parent, :<, index
    end
  end

  def test_event_blocks_precede_if_blocks
    model = BasicSharp::BytecodeEmitter.new(source_document('first_room')).model
    event_count = model.fetch(:events).length
    assert_equal [0, 1, 2, 3], model.fetch(:events).map { |entry| entry.fetch(:block_index) }
    assert_equal [4, 5], model.fetch(:if_rules).map { |entry| entry.fetch(:block_index) }
    assert_equal event_count + model.fetch(:if_rules).length, model.fetch(:blocks).length
  end

  def test_disassembly_is_deterministic_and_creator_syntax_neutral
    text = BasicSharp::BytecodeEmitter.new(source_document('first_room')).disassembly
    assert_includes text, 'BSharp Bytecode bsharp.bytecode.v1'
    assert_includes text, 'WHEN actor=THING[player] action=attack target=ONE_KIND[guard] BLOCK 3'
    assert_includes text, 'DAMAGE BOUND_THAT_KIND[guard] 1'
    assert_includes text, 'IF STATE_IS THING[north door] locked BLOCK 4'
    assert_includes text, "BLOCK 5\n    DAMAGE THING[player] 1\nEND"
    refute_includes text, 'line_number'
    refute_includes text, 'BasicSharp::'
  end

  def test_all_twelve_valid_meaning_cases_emit_and_invalid_case_is_rejected
    paths = Dir[File.join(ROOT, 'spec/meaning_v1/cases/*/source.bsharp')].sort
    paths.first(12).each do |path|
      emitter = BasicSharp::BytecodeEmitter.new(resolve_source(path))
      assert_equal 'BSBC', emitter.binary.byteslice(0, 4), path
      assert_includes emitter.disassembly, 'BSharp Bytecode bsharp.bytecode.v1', path
    end
    error = assert_raises(BasicSharp::BytecodeEmitterError) do
      BasicSharp::BytecodeEmitter.new(resolve_source(paths.last))
    end
    assert_includes error.message, '8 errors'
  end

  def test_warning_rejects_emission
    document = bsir_document('first_room')
    document['diagnostics'] = [{ 'severity' => 'warning', 'message' => 'test warning' }]
    error = assert_raises(BasicSharp::BytecodeEmitterError) { BasicSharp::BytecodeEmitter.new(document) }
    assert_includes error.message, '1 warning'
  end

  def test_unsupported_action_rejects_emission
    document = bsir_document('first_room')
    document['events'][0]['then'][0]['action'] = 'teleport'
    error = assert_raises(BasicSharp::BytecodeEmitterError) { BasicSharp::BytecodeEmitter.new(document) }
    assert_includes error.message, "does not support action 'teleport'"
  end

  def test_output_requires_bsbc_extension
    emitter = BasicSharp::BytecodeEmitter.new(source_document('first_room'))
    Dir.mktmpdir do |dir|
      error = assert_raises(BasicSharp::BytecodeEmitterError) { emitter.write(File.join(dir, 'room.bin')) }
      assert_includes error.message, '.bsbc'
      assert_empty Dir.children(dir)
    end
  end

  def test_atomic_pair_write_replaces_both_outputs
    emitter = BasicSharp::BytecodeEmitter.new(source_document('first_room'))
    Dir.mktmpdir do |dir|
      binary_path = File.join(dir, 'room.bsbc')
      text_path = "#{binary_path}.txt"
      File.binwrite(binary_path, 'old binary')
      File.write(text_path, 'old text')
      returned = emitter.write(binary_path)
      assert_equal [binary_path, text_path], returned
      assert_equal emitter.binary, File.binread(binary_path)
      assert_equal emitter.disassembly, File.read(text_path)
      assert_equal [], Dir.children(dir).grep(/backup|tmp/)
    end
  end

  def test_cli_emits_default_source_paths
    Dir.mktmpdir do |dir|
      source = File.join(dir, 'room.bsharp')
      FileUtils.cp(File.join(ROOT, 'samples/first_room.bsharp'), source)
      stdout, stderr, status = Open3.capture3(RUBY, File.join(ROOT, 'compiler/basic_sharp.rb'), source, '--emit-bytecode', chdir: ROOT)
      assert status.success?, stderr
      assert File.file?(File.join(dir, 'room.bsbc'))
      assert File.file?(File.join(dir, 'room.bsbc.txt'))
      assert_includes stdout, 'wrote:'
    end
  end

  def test_cli_source_and_bsir_custom_outputs_are_identical
    Dir.mktmpdir do |dir|
      source_out = File.join(dir, 'source.bsbc')
      bsir_out = File.join(dir, 'bsir.bsbc')
      source_status = Open3.capture3(RUBY, File.join(ROOT, 'compiler/basic_sharp.rb'), File.join(ROOT, 'samples/first_room.bsharp'), '--emit-bytecode', '--out', source_out, chdir: ROOT)
      bsir_status = Open3.capture3(RUBY, File.join(ROOT, 'compiler/basic_sharp.rb'), File.join(ROOT, 'samples/first_room.bsir.json'), '--emit-bytecode', '--out', bsir_out, chdir: ROOT)
      assert source_status[2].success?, source_status[1]
      assert bsir_status[2].success?, bsir_status[1]
      assert_equal File.binread(source_out), File.binread(bsir_out)
      assert_equal File.read("#{source_out}.txt"), File.read("#{bsir_out}.txt")
    end
  end

  def test_cli_rejects_incompatible_runtime_mode_and_bad_extension
    _stdout, stderr, status = Open3.capture3(RUBY, File.join(ROOT, 'compiler/basic_sharp.rb'), File.join(ROOT, 'samples/first_room.bsharp'), '--emit-bytecode', '--run', 'player attacks ember', chdir: ROOT)
    refute status.success?
    assert_equal 64, status.exitstatus
    assert_includes stderr, 'cannot be combined'

    _stdout, stderr, status = Open3.capture3(RUBY, File.join(ROOT, 'compiler/basic_sharp.rb'), File.join(ROOT, 'samples/first_room.bsharp'), '--emit-bytecode', '--out', '/tmp/not-bytecode.bin', chdir: ROOT)
    refute status.success?
    assert_equal 64, status.exitstatus
    assert_includes stderr, 'must end with .bsbc'
  end

  def test_cli_rejects_bsharp_save_as_program_input
    _stdout, stderr, status = Open3.capture3(RUBY, File.join(ROOT, 'compiler/basic_sharp.rb'), File.join(ROOT, 'samples/ask_demo.bsave.json'), '--emit-bytecode', chdir: ROOT)
    refute status.success?
    assert_includes stderr, 'contains world state, not program rules'
  end


  def test_fixture_manifest_locks_samples_and_meaning_cases
    path = File.join(ROOT, 'spec/bytecode_v1/BASIC_SHARP_BYTECODE_EMITTER_FIXTURES_v1.json')
    fixture = JSON.parse(File.read(path))
    assert_equal 'bsharp.bytecode.emitter.fixtures.json', fixture.fetch('format')
    assert_equal 1, fixture.fetch('format_version')
    assert_equal '0.1.27', fixture.fetch('created_by_basic_sharp')
    assert_equal 6, fixture.fetch('sample_count')
    assert_equal 12, fixture.fetch('valid_meaning_case_count')
    assert fixture.dig('invalid_meaning_case', 'must_reject_without_output')

    fixture.fetch('samples').each do |entry|
      binary = File.binread(File.join(ROOT, entry.fetch('binary')))
      text = File.binread(File.join(ROOT, entry.fetch('disassembly')))
      assert_equal entry.fetch('binary_bytes'), binary.bytesize, entry.fetch('id')
      assert_equal entry.fetch('binary_sha256'), Digest::SHA256.hexdigest(binary), entry.fetch('id')
      assert_equal entry.fetch('disassembly_bytes'), text.bytesize, entry.fetch('id')
      assert_equal entry.fetch('disassembly_sha256'), Digest::SHA256.hexdigest(text), entry.fetch('id')
      assert entry.fetch('source_bsir_binary_equal')
      assert entry.fetch('source_bsir_disassembly_equal')
    end

    fixture.fetch('meaning_cases').each do |entry|
      emitter = BasicSharp::BytecodeEmitter.new(resolve_source(File.join(ROOT, entry.fetch('source'))))
      assert_equal entry.fetch('binary_bytes'), emitter.binary.bytesize, entry.fetch('case_id')
      assert_equal entry.fetch('binary_sha256'), Digest::SHA256.hexdigest(emitter.binary), entry.fetch('case_id')
      assert_equal entry.fetch('disassembly_bytes'), emitter.disassembly.bytesize, entry.fetch('case_id')
      assert_equal entry.fetch('disassembly_sha256'), Digest::SHA256.hexdigest(emitter.disassembly), entry.fetch('case_id')
    end
  end

  def test_binary_contains_no_ruby_names_paths_or_timestamps
    binary = BasicSharp::BytecodeEmitter.new(source_document('first_room')).binary
    %w[BasicSharp RubyVM ObjectSpace Marshal /home/ /tmp/].each { |term| refute_includes binary, term }
    refute_match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}/, binary)
  end

  def test_profile_2_sample_preserves_exact_text_and_profile_1_remains_default
    text_emitter = BasicSharp::BytecodeEmitter.new(source_document('text_values'))
    assert_equal 'bsharp.bytecode.v2', text_emitter.model.fetch(:profile)
    assert_equal 'bsharp.meaning.v2', text_emitter.model.fetch(:meaning_profile)
    assert_includes text_emitter.model.fetch(:strings), 'OPEN — RubyVM!'
    assert_includes text_emitter.disassembly, 'START_TEXT_VALUE'

    profile_1 = BasicSharp::BytecodeEmitter.new(source_document('first_room'))
    assert_equal 'bsharp.bytecode.v1', profile_1.model.fetch(:profile)
    assert_equal File.binread(File.join(ROOT, 'samples/first_room.bsbc')), profile_1.binary
  end

  private

  def parse_directory(bytes)
    8.times.map do |index|
      offset = 32 + index * 16
      id = bytes.byteslice(offset, 4)
      section_offset, length, count = bytes.byteslice(offset + 4, 12).unpack('V3')
      { id: id, offset: section_offset, length: length, count: count }
    end
  end
end

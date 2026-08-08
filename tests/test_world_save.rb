# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'
require_relative '../compiler/world_save'

class TestWorldSave < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  RUBY = RbConfig.ruby

  def resolve(source)
    parser = BasicSharp::Parser.new(source)
    program = parser.parse
    BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  end

  def runtime(source, world_save: nil)
    BasicSharp::Runtime.new(resolve(source), world_save: world_save)
  end

  def deep_copy(value)
    JSON.parse(JSON.generate(value))
  end

  def thing(snapshot, name)
    snapshot.find { |entry| entry.fetch('name') == name }
  end

  def demo_source
    File.read(File.join(ROOT, 'samples/world_save_demo.bsharp'))
  end

  def event_save_document
    machine = runtime(demo_source)
    result = machine.run_event('player attacks henry')
    assert_nil result['error']
    BasicSharp::WorldSave.document_for(machine)
  end

  def test_save_after_start_settlement
    machine = runtime(demo_source)
    document = BasicSharp::WorldSave.document_for(machine)

    assert_equal 'bsharp.save.json', document.fetch('format')
    assert_equal 1, document.fetch('format_version')
    assert_equal '0.1.52', document.fetch('created_by_basic_sharp')
    assert_equal true, document.dig('world', 'settled')
    assert_equal %w[player henry mara brass\ bell brass\ key oak\ table], document.dig('world', 'things').map { |entry| entry.fetch('name') }
    assert_equal 10, document.dig('world', 'things', 1, 'values', 'health')
  end

  def test_save_waits_for_the_complete_event_chain_and_if_settlement
    document = event_save_document
    world = document.fetch('world')

    assert_equal 1, thing(world.fetch('things'), 'player').dig('values', 'damage')
    assert_equal ['angry'], thing(world.fetch('things'), 'henry').fetch('states')
    assert_equal 3, thing(world.fetch('things'), 'henry').dig('values', 'damage')
    assert_equal({ 'carried by' => 'henry' }, thing(world.fetch('things'), 'brass key').fetch('relations'))
    assert_equal true, world.dig('if_rules', 0, 'active')
    refute world.key?('pending_events')
    refute world.key?('event_queue')
  end

  def test_source_and_saved_bsir_have_the_same_program_fingerprint
    resolved = resolve(demo_source)
    bsir = JSON.parse(BasicSharp::IREmitter.new(resolved).to_json)

    assert_equal BasicSharp::WorldSave.program_fingerprint(resolved), BasicSharp::WorldSave.program_fingerprint(bsir)
  end

  def test_program_fingerprint_ignores_line_number_changes_from_blank_lines
    spaced = demo_source.gsub("\n\n", "\n\n\n")

    assert_equal BasicSharp::WorldSave.program_fingerprint(resolve(demo_source)), BasicSharp::WorldSave.program_fingerprint(resolve(spaced))
  end

  def test_same_settled_world_produces_byte_identical_files
    Dir.mktmpdir do |dir|
      first = runtime(demo_source)
      second = runtime(demo_source)
      first.run_event('player attacks henry')
      second.run_event('player attacks henry')
      first_path = File.join(dir, 'first.bsave.json')
      second_path = File.join(dir, 'second.bsave.json')

      first.write_world_save(first_path)
      second.write_world_save(second_path)

      assert_equal File.binread(first_path), File.binread(second_path)
    end
  end

  def test_restore_preserves_definition_order_states_relations_values_and_if_activity
    document = event_save_document
    restored = runtime(demo_source, world_save: document)
    snapshot = restored.snapshot

    assert_equal %w[player henry mara brass\ bell brass\ key oak\ table], snapshot.map { |entry| entry.fetch('name') }
    assert_equal ['angry'], thing(snapshot, 'henry').fetch('states')
    assert_equal 3, thing(snapshot, 'henry').dig('values', 'damage')
    assert_equal 10, thing(snapshot, 'henry').dig('values', 'health')
    assert_equal({ 'carried by' => 'henry' }, thing(snapshot, 'brass key').fetch('relations'))
    assert restored.save_ready?
    assert_empty restored.startup_ran
    assert_empty restored.startup_if_rules
    assert_empty restored.startup_follow_up_events
  end

  def test_start_if_and_startup_follow_up_events_do_not_rerun_on_restore
    source = <<~BSHARP
      DEFINE
      [
          @brass bell is a #device
      ].

      START
      [
          @brass bell is on
      ].

      IF @brass bell is on
      [
          |then (damage PLAYER
          |then (cause PLAYER sounds @brass bell
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (damage PLAYER
      ].
    BSHARP

    original = runtime(source)
    assert_equal 2, thing(original.snapshot, 'player').dig('values', 'damage')
    document = BasicSharp::WorldSave.document_for(original)

    restored = runtime(source, world_save: document)

    assert_equal 2, thing(restored.snapshot, 'player').dig('values', 'damage')
    assert_empty restored.startup_if_rules
    assert_empty restored.startup_follow_up_events
  end

  def test_save_is_refused_after_an_unmatched_event
    machine = runtime(demo_source)
    result = machine.run_event('player dances')

    refute result.fetch('matched')
    error = assert_raises(BasicSharp::WorldSaveError) { BasicSharp::WorldSave.document_for(machine) }
    assert_includes error.message, 'did not finish a successful event'
  end

  def test_save_is_refused_after_a_runtime_error
    source = <<~BSHARP
      DEFINE
      [
          @henry is a #guard
      ].

      WHEN PLAYER attacks @henry
      [
          |then (change health of @henry to 7
      ].
    BSHARP
    machine = runtime(source)
    result = machine.run_event('player attacks henry')

    refute_nil result['error']
    assert_raises(BasicSharp::WorldSaveError) { BasicSharp::WorldSave.document_for(machine) }
  end

  def test_save_is_refused_after_the_follow_up_event_circuit_breaker
    source = <<~BSHARP
      DEFINE
      [
          @brass bell is a #device
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (cause PLAYER sounds @brass bell
      ].
    BSHARP
    machine = runtime(source)
    result = machine.run_event('player sounds brass bell')

    assert_equal BasicSharp::Runtime::EVENT_CHAIN_LIMIT_MESSAGE, result.fetch('error')
    assert_raises(BasicSharp::WorldSaveError) { BasicSharp::WorldSave.document_for(machine) }
  end

  def test_different_program_is_rejected
    document = event_save_document
    changed = demo_source.sub('mara is calm', 'mara is angry')

    error = assert_raises(BasicSharp::WorldSaveError) { runtime(changed, world_save: document) }
    assert_equal "This BSharp Save belongs to a different BASIC# program.\nLoad it with the same .bsharp, .bsir.json, or .bsbc program that created it.", error.message
  end

  def test_invalid_json_has_plain_message
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'broken.bsave.json')
      File.write(path, '{broken')

      error = assert_raises(BasicSharp::WorldSaveError) { BasicSharp::WorldSave.read(path) }
      assert_equal 'BSharp Save cannot load because the file is not valid JSON.', error.message
    end
  end

  def test_wrong_format_is_rejected
    document = event_save_document
    document['format'] = 'bsir.debug.json'

    error = assert_raises(BasicSharp::WorldSaveError) { runtime(demo_source, world_save: document) }
    assert_equal 'BSharp Save cannot load because this is not a BSharp Save file.', error.message
  end

  def test_unsupported_format_version_is_rejected
    document = event_save_document
    document['format_version'] = 2

    error = assert_raises(BasicSharp::WorldSaveError) { runtime(demo_source, world_save: document) }
    assert_equal "This BSharp Save uses format version 2.\nThis program requires BSharp Save format version 1.", error.message
  end

  def test_unknown_or_reordered_thing_is_rejected
    document = event_save_document
    document.dig('world', 'things', 1)['name'] = 'ghost'

    error = assert_raises(BasicSharp::WorldSaveError) { runtime(demo_source, world_save: document) }
    assert_includes error.message, 'expected Thing 2 to be henry, but found ghost'
  end

  def test_changed_kind_is_rejected
    document = event_save_document
    document.dig('world', 'things', 1)['kind'] = 'dragon'

    error = assert_raises(BasicSharp::WorldSaveError) { runtime(demo_source, world_save: document) }
    assert_includes error.message, 'defines henry as a guard'
  end

  def test_missing_relationship_target_is_rejected
    document = event_save_document
    thing(document.dig('world', 'things'), 'brass key')['relations']['carried by'] = 'ghost'

    error = assert_raises(BasicSharp::WorldSaveError) { runtime(demo_source, world_save: document) }
    assert_includes error.message, "points to missing Thing 'ghost'"
  end

  def test_invalid_number_is_rejected
    document = event_save_document
    thing(document.dig('world', 'things'), 'henry')['values']['health'] = 'ten'

    error = assert_raises(BasicSharp::WorldSaveError) { runtime(demo_source, world_save: document) }
    assert_includes error.message, 'must be a whole number from 0 to 2147483647'
  end

  def test_contradictory_states_are_rejected
    document = event_save_document
    thing(document.dig('world', 'things'), 'henry')['states'] = %w[angry calm]

    error = assert_raises(BasicSharp::WorldSaveError) { runtime(demo_source, world_save: document) }
    assert_includes error.message, 'contradictory states'
  end

  def test_if_active_record_must_match_the_restored_world
    document = event_save_document
    document.dig('world', 'if_rules', 0)['active'] = false

    error = assert_raises(BasicSharp::WorldSaveError) { runtime(demo_source, world_save: document) }
    assert_includes error.message, 'does not match the restored world'
  end

  def test_failed_restore_does_not_change_the_existing_runtime
    machine = runtime(demo_source)
    before = machine.snapshot
    document = event_save_document
    thing(document.dig('world', 'things'), 'henry')['values']['health'] = -1

    assert_raises(BasicSharp::WorldSaveError) { machine.restore_world_save!(document) }
    assert_equal before, machine.snapshot
  end

  def test_failed_atomic_write_preserves_the_previous_save
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'world.bsave.json')
      File.write(path, "previous save\n")
      machine = runtime(demo_source)

      File.stub(:rename, ->(*_arguments) { raise Errno::EIO, 'forced write failure' }) do
        assert_raises(BasicSharp::WorldSaveError) { machine.write_world_save(path) }
      end

      assert_equal "previous save\n", File.read(path)
      assert_empty Dir[File.join(dir, '.world.bsave.json.*.tmp')]
    end
  end

  def test_directly_running_a_save_file_explains_what_to_do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'world.bsave.json')
      machine = runtime(demo_source)
      machine.write_world_save(path)

      stdout, stderr, status = Open3.capture3(RUBY, File.join(ROOT, 'compiler/basic_sharp.rb'), path, chdir: ROOT)

      refute status.success?
      assert_empty stdout
      assert_equal "A BSharp Save contains world state, not program rules.\nStart BASIC# with the matching .bsharp or .bsir.json file and use --load-world.\n", stderr
    end
  end

  def test_cli_source_save_and_bsir_restore_continue_the_world
    Dir.mktmpdir do |dir|
      save_path = File.join(dir, 'world.bsave.json')
      bsir_path = File.join(dir, 'world.bsir.json')
      source_path = File.join(ROOT, 'samples/world_save_demo.bsharp')

      _stdout, stderr, status = Open3.capture3(
        RUBY, File.join(ROOT, 'compiler/basic_sharp.rb'), source_path,
        '--emit-ir', '--out', bsir_path, chdir: ROOT
      )
      assert status.success?, stderr

      stdout, stderr, status = Open3.capture3(
        RUBY, File.join(ROOT, 'compiler/basic_sharp.rb'), source_path,
        '--run', 'player attacks henry', '--save-world', save_path, chdir: ROOT
      )
      assert status.success?, stderr
      assert_includes stdout, "saved world: #{save_path}"

      stdout, stderr, status = Open3.capture3(
        RUBY, File.join(ROOT, 'compiler/basic_sharp.rb'), bsir_path,
        '--load-world', save_path, '--run', 'henry attacks player', chdir: ROOT
      )
      assert status.success?, stderr
      assert_includes stdout, 'player damage is now 2'
      refute_includes stdout, 'starting IF rules:'
      refute_includes stdout, 'starting follow-up events:'
    end
  end

  def test_replay_after_restore_is_deterministic_and_runtimes_are_isolated
    document = event_save_document
    first = runtime(demo_source, world_save: deep_copy(document))
    second = runtime(demo_source, world_save: deep_copy(document))

    first_result = first.run_event('henry attacks player')
    second_result = second.run_event('henry attacks player')

    assert_equal first_result.fetch('state'), second_result.fetch('state')
    first.run_event('henry attacks player')
    refute_equal first.snapshot, second.snapshot
  end

  def test_profile_2_save_uses_typed_values_and_format_2
    source = File.read(File.join(ROOT, 'samples/text_values.bsharp'), encoding: 'UTF-8')
    machine = runtime(source)
    machine.run_event('player sounds brass bell')
    document = BasicSharp::WorldSave.document_for(machine)
    north = document.dig('world', 'things').find { |thing| thing.fetch('name') == 'north gate' }
    assert_equal 2, document.fetch('format_version')
    assert_equal 'sha256-bsir-meaning-v2', document.dig('program_fingerprint', 'algorithm')
    assert_equal({ 'type' => 'text', 'value' => 'OPEN — RubyVM!' }, north.dig('values', 'title'))
    assert_equal({ 'type' => 'whole_number', 'value' => 0 }, north.dig('values', 'damage'))
    assert_equal machine.snapshot, runtime(source, world_save: document).snapshot
  end
end

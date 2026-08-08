# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require 'tmpdir'

class TestCLIOutput < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  RUBY = RbConfig.ruby

  def test_emit_ir_out_writes_file_and_creates_parent_directory
    Dir.mktmpdir do |dir|
      out_path = File.join(dir, 'nested', 'first_room.bsir.json')
      stdout, stderr, status = Open3.capture3(
        RUBY,
        File.join(ROOT, 'compiler/basic_sharp.rb'),
        File.join(ROOT, 'samples/first_room.bsharp'),
        '--emit-ir',
        '--out',
        out_path,
        chdir: ROOT
      )

      assert status.success?, stderr
      assert_includes stdout, "wrote: #{out_path}"
      assert File.file?(out_path), 'expected --out to create the IR file'
      json = JSON.parse(File.read(out_path))
      assert_equal '0.1.55', json.fetch('version')
    end
  end

  def test_run_executes_one_event_and_prints_changed_world_state
    stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/first_room.bsharp'),
      '--run',
      'player attacks ember',
      chdir: ROOT
    )

    assert status.success?, stderr
    assert_includes stdout, 'BSharp Virtual Machine v0.1.55'
    assert_includes stdout, 'matched: yes'
    assert_includes stdout, 'what matched:'
    assert_includes stdout, 'player attacks ember'
    assert_includes stdout, 'what happened:'
    assert_includes stdout, '(damage ember'
    assert_includes stdout, 'ember damage is now 1'
    assert_includes stdout, '(change ember to angry'
    assert_includes stdout, 'ember is now angry'
    assert_includes stdout, 'ember: kind=wyrm; states=angry; damage=1'
    assert_includes stdout, 'north door: kind=door; states=unlocked'
  end

  def test_run_requires_an_event
    _stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/first_room.bsharp'),
      '--run',
      chdir: ROOT
    )

    refute status.success?
    assert_equal 64, status.exitstatus
    assert_includes stderr, 'Missing event after --run'
  end

  def test_run_executes_existing_bsir_json
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'first_room.bsir.json')
      _emit_stdout, emit_stderr, emit_status = Open3.capture3(
        RUBY,
        File.join(ROOT, 'compiler/basic_sharp.rb'),
        File.join(ROOT, 'samples/first_room.bsharp'),
        '--emit-ir',
        '--out',
        path,
        chdir: ROOT
      )
      assert emit_status.success?, emit_stderr

      stdout, stderr, status = Open3.capture3(
        RUBY,
        File.join(ROOT, 'compiler/basic_sharp.rb'),
        path,
        '--run',
        'player attacks henry',
        chdir: ROOT
      )

      assert status.success?, stderr
      assert_includes stdout, 'BSharp Virtual Machine v0.1.55'
      assert_includes stdout, 'matched: yes'
      assert_includes stdout, 'what matched:'
      assert_includes stdout, 'player attacks a guard'
      assert_includes stdout, 'a guard means henry'
      assert_includes stdout, 'that guard means henry'
      assert_includes stdout, 'henry damage is now 1'
      assert_includes stdout, 'henry is now angry'
      assert_includes stdout, 'henry: kind=guard; states=angry; damage=1'
    end
  end

  def test_missing_out_path_exits_with_usage_error
    _stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/first_room.bsharp'),
      '--emit-ir',
      '--out',
      chdir: ROOT
    )

    refute status.success?
    assert_equal 64, status.exitstatus
    assert_includes stderr, 'Missing output path after --out'
  end
  def test_run_matches_named_guard_to_kind_trigger
    stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/first_room.bsharp'),
      '--run',
      'player attacks henry',
      chdir: ROOT
    )

    assert status.success?, stderr
    assert_includes stdout, 'BSharp Virtual Machine v0.1.55'
    assert_includes stdout, 'matched: yes'
    assert_includes stdout, 'what matched:'
    assert_includes stdout, 'player attacks a guard'
    assert_includes stdout, 'what I understood:'
    assert_includes stdout, 'a guard means henry'
    assert_includes stdout, 'that guard means henry'
    assert_includes stdout, 'what happened:'
    assert_includes stdout, '(damage henry'
    assert_includes stdout, 'henry damage is now 1'
    assert_includes stdout, '(change henry to angry'
    assert_includes stdout, 'henry is now angry'
    assert_includes stdout, 'henry: kind=guard; states=angry; damage=1'
  end

  def test_run_reports_unknown_thing_for_kind_trigger
    stdout, _stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/first_room.bsharp'),
      '--run',
      'player attacks ghost',
      chdir: ROOT
    )

    refute status.success?
    assert_includes stdout, 'matched: no'
    assert_includes stdout, "error: event Thing 'ghost' is not defined"
  end


  def test_run_matches_wyrm_to_ancestor_creature_trigger
    stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/first_room.bsharp'),
      '--run',
      'player attacks cinder',
      chdir: ROOT
    )

    assert status.success?, stderr
    assert_includes stdout, 'what matched:'
    assert_includes stdout, 'player attacks a creature'
    assert_includes stdout, 'a creature means cinder'
    assert_includes stdout, 'that creature means cinder'
    assert_includes stdout, 'cinder damage is now 1'
    assert_includes stdout, 'cinder is now angry'
    assert_includes stdout, 'IF rules:'
    assert_includes stdout, 'cinder is angry became true after the event'
    assert_includes stdout, 'player damage is now 1'
  end

  def test_follow_up_loop_reports_failure_exit_status
    Dir.mktmpdir do |dir|
      source_path = File.join(dir, 'loop.bsharp')
      File.write(source_path, <<~BSHARP)
        DEFINE
        [
            @brass bell is a #device
        ].

        WHEN PLAYER sounds @brass bell
        [
            |then (cause PLAYER sounds @brass bell
        ].
      BSHARP

      stdout, stderr, status = Open3.capture3(
        RUBY,
        File.join(ROOT, 'compiler/basic_sharp.rb'),
        source_path,
        '--run',
        'player sounds brass bell',
        chdir: ROOT
      )

      refute status.success?
      assert_empty stderr
      assert_includes stdout, 'Events kept causing more events.'
      assert_includes stdout, 'stopped this chain after 1,024 follow-up events'
    end
  end

  def test_reference_runtime_is_available_only_by_explicit_option
    stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/first_room.bsharp'),
      '--reference-runtime',
      '--run',
      'player attacks cinder',
      chdir: ROOT
    )

    assert status.success?, stderr
    assert_includes stdout, 'BASIC# Runtime v0.1.55'
    refute_includes stdout, 'BSharp Virtual Machine v0.1.55'
  end

  def test_shadow_parity_mode_reports_only_preferred_vm_result
    stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/first_room.bsharp'),
      '--verify-runtime-parity',
      '--run',
      'player attacks cinder',
      chdir: ROOT
    )

    assert status.success?, stderr
    assert_includes stdout, 'BSharp Virtual Machine v0.1.55'
    refute_includes stdout, 'BASIC# Runtime v0.1.55'
    assert_includes stdout, 'cinder damage is now 1'
  end

  def test_runtime_transition_options_reject_direct_bytecode
    _stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/first_room.bsbc'),
      '--reference-runtime',
      '--run',
      'player attacks cinder',
      chdir: ROOT
    )

    refute status.success?
    assert_equal 64, status.exitstatus
    assert_includes stderr, 'Direct .bsbc execution already uses the BSharp VM.'
  end

  def test_runtime_transition_options_are_mutually_exclusive
    _stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/first_room.bsharp'),
      '--reference-runtime',
      '--verify-runtime-parity',
      '--run',
      'player attacks cinder',
      chdir: ROOT
    )

    refute status.success?
    assert_equal 64, status.exitstatus
    assert_includes stderr, 'cannot be combined'
  end

  def test_cli_runs_profile_2_text_values_through_the_preferred_vm
    stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/text_values.bsharp'),
      '--verify-runtime-parity',
      '--run',
      'player sounds brass bell',
      chdir: ROOT
    )
    assert status.success?, stderr
    assert_empty stderr
    assert_includes stdout, 'BSharp Virtual Machine v0.1.55'
    assert_includes stdout, 'north gate title changed from "North  Gate!" to "OPEN — RubyVM!"'
    assert_includes stdout, 'north gate: kind=gate; title="OPEN — RubyVM!"'
  end

  def test_cli_runs_profile_5_source_and_direct_bytecode
    [
      File.join(ROOT, 'samples/number_changes.bsharp'),
      File.join(ROOT, 'samples/number_changes.bsbc')
    ].each do |program|
      stdout, stderr, status = Open3.capture3(
        RUBY,
        File.join(ROOT, 'compiler/basic_sharp.rb'),
        program,
        '--run',
        'player takes gold coin',
        chdir: ROOT
      )
      assert status.success?, stderr
      assert_empty stderr
      assert_includes stdout, 'BSharp Virtual Machine v0.1.55'
      assert_includes stdout, '(increase score of player by 10'
      assert_includes stdout, 'player score changed from 0 to 10'
    end
  end

end

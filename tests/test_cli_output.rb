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
      out_path = File.join(dir, 'nested', 'first_room.ir.json')
      stdout, stderr, status = Open3.capture3(
        RUBY,
        File.join(ROOT, 'compiler/dks.rb'),
        File.join(ROOT, 'samples/first_room.dks'),
        '--emit-ir',
        '--out',
        out_path,
        chdir: ROOT
      )

      assert status.success?, stderr
      assert_includes stdout, "wrote: #{out_path}"
      assert File.file?(out_path), 'expected --out to create the IR file'
      json = JSON.parse(File.read(out_path))
      assert_equal '0.1.09', json.fetch('version')
    end
  end

  def test_run_executes_one_event_and_prints_changed_world_state
    stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/dks.rb'),
      File.join(ROOT, 'samples/first_room.dks'),
      '--run',
      'player attacks ember',
      chdir: ROOT
    )

    assert status.success?, stderr
    assert_includes stdout, 'DKScript Runtime v0.1.09'
    assert_includes stdout, 'matched: yes'
    assert_includes stdout, '(damage ember'
    assert_includes stdout, '(change ember to angry'
    assert_includes stdout, 'ember: kind=dragon; states=angry; damage=1'
    assert_includes stdout, 'north door: kind=door; states=unlocked'
  end

  def test_run_requires_an_event
    _stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/dks.rb'),
      File.join(ROOT, 'samples/first_room.dks'),
      '--run',
      chdir: ROOT
    )

    refute status.success?
    assert_equal 64, status.exitstatus
    assert_includes stderr, 'Missing event after --run'
  end

  def test_run_executes_existing_dkir_json
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'first_room.ir.json')
      _emit_stdout, emit_stderr, emit_status = Open3.capture3(
        RUBY,
        File.join(ROOT, 'compiler/dks.rb'),
        File.join(ROOT, 'samples/first_room.dks'),
        '--emit-ir',
        '--out',
        path,
        chdir: ROOT
      )
      assert emit_status.success?, emit_stderr

      stdout, stderr, status = Open3.capture3(
        RUBY,
        File.join(ROOT, 'compiler/dks.rb'),
        path,
        '--run',
        'player attacks ember',
        chdir: ROOT
      )

      assert status.success?, stderr
      assert_includes stdout, 'DKScript Runtime v0.1.09'
      assert_includes stdout, 'matched: yes'
      assert_includes stdout, 'ember: kind=dragon; states=angry; damage=1'
    end
  end

  def test_missing_out_path_exits_with_usage_error
    _stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/dks.rb'),
      File.join(ROOT, 'samples/first_room.dks'),
      '--emit-ir',
      '--out',
      chdir: ROOT
    )

    refute status.success?
    assert_equal 64, status.exitstatus
    assert_includes stderr, 'Missing output path after --out'
  end
end

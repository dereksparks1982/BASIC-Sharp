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
      assert_equal '0.1.06', json.fetch('version')
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

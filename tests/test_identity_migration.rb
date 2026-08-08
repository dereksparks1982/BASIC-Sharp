# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'

class TestIdentityMigration < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def test_basic_sharp_is_the_only_active_ruby_namespace
    assert Object.const_defined?(:BasicSharp)
    refute Object.const_defined?(:DKScript)
    assert_equal '0.1.57', BasicSharp::VERSION
  end

  def test_new_compiler_paths_exist_and_retired_paths_are_gone
    assert File.file?(File.join(ROOT, 'compiler/basic_sharp.rb'))
    assert File.file?(File.join(ROOT, 'compiler/basic_sharp_ir.rb'))
    refute File.exist?(File.join(ROOT, 'compiler/dks.rb'))
    refute File.exist?(File.join(ROOT, 'compiler/dks_ir.rb'))
  end

  def test_creator_samples_use_bsharp_extension_only
    samples = Dir[File.join(ROOT, 'samples/**/*')].select { |path| File.file?(path) }
    assert samples.any? { |path| path.end_with?('.bsharp') }
    assert_empty samples.grep(/\.dks\z/i)
  end

  def test_compiler_and_runtime_banners_use_basic_sharp_identity
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/first_room.bsharp')
    )

    assert status.success?, stderr
    assert_includes stdout, 'BASIC# Ruby Bootstrap Compiler v0.1.57'
    refute_includes stdout, 'DKScript Ruby Bootstrap Compiler'

    run_stdout, run_stderr, run_status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/first_room.bsharp'),
      '--run',
      'player attacks henry'
    )

    assert run_status.success?, run_stderr
    assert_includes run_stdout, 'BSharp Virtual Machine v0.1.57'
    refute_includes run_stdout, 'DKScript Runtime'
  end

  def test_v0_1_13_saved_bsir_still_runs
    path = File.join(ROOT, 'tests/fixtures/first_room_v0_1_13.bsir.json')
    document = JSON.parse(File.read(path))
    assert_equal '0.1.13', document.fetch('version')

    machine = BasicSharp::Runtime.load(path)
    result = machine.run_event('player attacks henry')

    assert_equal true, result.fetch('matched')
    assert_equal 'player attacks a guard', result.fetch('matched_when')
    henry = result.fetch('state').find { |thing| thing.fetch('name') == 'henry' }
    assert_equal 1, henry.fetch('damage')
    assert_equal ['angry'], henry.fetch('states')
  end

  def test_company_bible_is_integrated
    bible_root = File.join(ROOT, 'docs/company_bible')
    canonical = File.join(bible_root, 'BASIC_SHARP_COMPANY_BIBLE.md')
    files = Dir[File.join(bible_root, '**/*')].select { |path| File.file?(path) }

    assert_equal [canonical], files
    assert File.file?(canonical)
    assert File.read(canonical).include?('one active Company Bible for BASIC#')
  end

  def test_no_project_filename_uses_retired_dkscript_identity
    paths = Dir[File.join(ROOT, '**/*'), File.join(ROOT, '**/.*')]
      .select { |path| File.file?(path) }
      .reject { |path| path.include?('/.git/') }
      .map { |path| path.delete_prefix("#{ROOT}/") }

    retired = paths.select do |path|
      basename = File.basename(path)
      basename.match?(/dkscript/i) || basename.match?(/\Adks(?:_|\.|\z)/i) || basename.end_with?('.dks')
    end

    assert_empty retired, "Retired project filenames remain: #{retired.join(', ')}"
  end
end

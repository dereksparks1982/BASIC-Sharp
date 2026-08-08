# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require_relative '../compiler/ast_nodes'

class TestUTF8SourceReadingContract < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/governance/BASIC_SHARP_UTF8_SOURCE_READING_CONTRACT_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_contract_identity
    assert_equal 'bsharp.utf8_source_reading_contract.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'active_hardening_gate', spec.fetch('status')
  end

  def test_cli_reads_utf8_source_under_minimal_locale
    sample = spec.fetch('required_samples').find { |entry| entry.fetch('path') == 'samples/text_values.bsharp' }
    env = spec.fetch('minimal_locale_environment')
    stdout, stderr, status = Open3.capture3(
      { 'LC_ALL' => env.fetch('LC_ALL'), 'LANG' => env.fetch('LANG'), 'RUBYOPT' => env.fetch('RUBYOPT') },
      RbConfig.ruby, 'compiler/basic_sharp.rb', 'samples/text_values.bsharp', '--run', 'player sounds brass bell',
      chdir: ROOT
    )
    stdout.force_encoding('UTF-8')
    stderr.force_encoding('UTF-8')

    assert status.success?, stderr.empty? ? stdout : stderr
    assert_empty stderr
    assert_includes stdout, sample.fetch('must_include_stdout')
  end

  def test_cli_reads_utf8_bsir_under_minimal_locale
    sample = spec.fetch('required_samples').find { |entry| entry.fetch('path') == 'samples/text_values.bsir.json' }
    env = spec.fetch('minimal_locale_environment')
    stdout, stderr, status = Open3.capture3(
      { 'LC_ALL' => env.fetch('LC_ALL'), 'LANG' => env.fetch('LANG'), 'RUBYOPT' => env.fetch('RUBYOPT') },
      RbConfig.ruby, 'compiler/basic_sharp.rb', 'samples/text_values.bsir.json', '--run', 'player sounds brass bell',
      chdir: ROOT
    )
    stdout.force_encoding('UTF-8')
    stderr.force_encoding('UTF-8')

    assert status.success?, stderr.empty? ? stdout : stderr
    assert_empty stderr
    assert_includes stdout, sample.fetch('must_include_stdout')
  end

  def test_trial_by_fire_inventory_runs_utf8_contract
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/utf8_source_reading_contract.rb'
  end
end

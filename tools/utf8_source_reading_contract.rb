#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open3'
require 'rbconfig'
require_relative '../compiler/ast_nodes'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/governance/BASIC_SHARP_UTF8_SOURCE_READING_CONTRACT_v1.json')

def assert_contract!(condition, message)
  raise "UTF-8 source reading contract failed: #{message}" unless condition
end

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
assert_contract!(spec.fetch('format') == 'bsharp.utf8_source_reading_contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_contract!(spec.fetch('status') == 'active_hardening_gate', 'wrong contract status')

minimal_env = {
  'LC_ALL' => spec.fetch('minimal_locale_environment').fetch('LC_ALL'),
  'LANG' => spec.fetch('minimal_locale_environment').fetch('LANG'),
  'RUBYOPT' => spec.fetch('minimal_locale_environment').fetch('RUBYOPT')
}

spec.fetch('required_samples').each do |sample|
  path = File.join(ROOT, sample.fetch('path'))
  text = File.read(path, encoding: 'UTF-8')
  assert_contract!(text.include?(sample.fetch('contains')), "sample does not contain required UTF-8 text: #{sample.fetch('path')}")

  command = sample.fetch('command')
  executable = command.fetch(0) == 'ruby' ? RbConfig.ruby : command.fetch(0)
  stdout, stderr, status = Open3.capture3(minimal_env, executable, *command.drop(1), chdir: ROOT)
  stdout.force_encoding('UTF-8')
  stderr.force_encoding('UTF-8')

  assert_contract!(status.success?, "minimal-locale command failed for #{sample.fetch('path')}: #{stderr.empty? ? stdout : stderr}")
  assert_contract!(stderr.empty?, "minimal-locale command emitted stderr for #{sample.fetch('path')}: #{stderr}")
  assert_contract!(stdout.include?(sample.fetch('must_include_stdout')), "minimal-locale stdout did not include required text for #{sample.fetch('path')}")
end

puts "BASIC# UTF-8 Source Reading Contract v#{BasicSharp::VERSION}: PASS"
puts 'Minimal/no-locale source read: PASS'
puts 'UTF-8 creator text survives CLI parsing and execution: PASS'

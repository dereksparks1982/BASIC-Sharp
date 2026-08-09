#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open3'
require 'rbconfig'
require_relative '../compiler/ast_nodes'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/release/BASIC_SHARP_DETERMINISTIC_FIXTURE_HASH_SWEEP_v1.json')
spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_sweep!(condition, message)
  raise "Deterministic fixture hash sweep failed: #{message}" unless condition
end

assert_sweep!(spec.fetch('format') == 'bsharp.deterministic_fixture_hash_sweep.json', 'wrong spec identity')
assert_sweep!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_sweep!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_sweep!(spec.fetch('status') == 'active_release_gate', 'wrong status')
assert_sweep!(spec.fetch('forbidden').include?('single-goblin repair'), 'single-goblin repair must stay forbidden')

spec.fetch('required_fixture_specs').each do |relative|
  path = File.join(ROOT, relative)
  assert_sweep!(File.file?(path), "missing fixture spec #{relative}")
  JSON.parse(File.read(path, encoding: 'UTF-8'))
end

results = spec.fetch('required_tools').map do |relative|
  path = File.join(ROOT, relative)
  assert_sweep!(File.file?(path), "missing deterministic tool #{relative}")
  stdout, stderr, status = Open3.capture3(
    { 'LC_ALL' => 'C.UTF-8', 'LANG' => 'C.UTF-8', 'TERM' => 'xterm', 'RUBYOPT' => '-W2' },
    RbConfig.ruby, path,
    chdir: ROOT
  )
  assert_sweep!(status.success?, "#{relative} failed\n#{stdout}\n#{stderr}")
  assert_sweep!(stderr.empty?, "#{relative} emitted stderr: #{stderr}")
  { path: relative, stdout_bytes: stdout.bytesize, status: 'PASS' }
end

puts "BASIC# Deterministic Fixture Hash Sweep v#{BasicSharp::VERSION}: PASS"
results.each { |entry| puts "#{entry.fetch(:path)}: PASS" }
puts 'Complete deterministic fixture family swept together: PASS'

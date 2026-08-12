#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'json'
require 'open3'
require_relative '../compiler/ast_nodes'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/release/BASIC_SHARP_RELEASE_PACKAGE_PREFLIGHT_v1.json')
MANIFEST_PATH = File.join(ROOT, 'BASIC_SHARP_PATCH_MANIFEST.json')
spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
manifest = JSON.parse(File.read(MANIFEST_PATH, encoding: 'UTF-8'))

def assert_preflight!(condition, message)
  raise "Release package preflight failed: #{message}" unless condition
end

def sha256(path)
  Digest::SHA256.file(path).hexdigest
end

assert_preflight!(spec.fetch('format') == 'bsharp.release_package_preflight.json', 'wrong spec identity')
assert_preflight!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_preflight!(spec.fetch('target_version') == BasicSharp::VERSION, 'spec target mismatch')
assert_preflight!(spec.fetch('status') == 'active_release_gate', 'wrong status')
assert_preflight!(manifest.fetch('format') == 'BASIC_SHARP_CHANGED_FILES_PATCH', 'manifest identity mismatch')
assert_preflight!(manifest.fetch('target_version') == spec.fetch('required_target_version'), 'manifest target mismatch')
assert_preflight!(manifest.fetch('base_version') == spec.fetch('required_base_version'), 'manifest base mismatch')
assert_preflight!(manifest.fetch('package_name').include?('v0_1_80'), 'package filename is not v0.1.80')
assert_preflight!(manifest.fetch('package_name').end_with?(spec.fetch('required_package_suffix')), 'package suffix mismatch')
assert_preflight!(manifest.fetch('installer_name') == spec.fetch('required_installer'), 'installer name mismatch')
assert_preflight!(manifest.fetch('deletions') == [], 'deletions are not allowed in this build')
assert_preflight!(manifest.fetch('added_path_count') == manifest.fetch('added_paths').length, 'added count mismatch')
assert_preflight!(manifest.fetch('modified_path_count') == manifest.fetch('modified_paths').length, 'modified count mismatch')
assert_preflight!(manifest.fetch('changed_path_count_including_manifest') == manifest.fetch('added_paths').length + manifest.fetch('modified_paths').length, 'changed count mismatch')

listed = (manifest.fetch('added_paths') + manifest.fetch('modified_paths')).sort
status_lines = Open3.capture2('git', 'status', '--porcelain=v1', '--untracked-files=all', chdir: ROOT).first.lines.map { |line| line[3..].strip }.sort
assert_preflight!(status_lines == listed, "git scope differs from manifest\nlisted=#{listed.inspect}\nstatus=#{status_lines.inspect}")

manifest.fetch('files').each do |entry|
  path = File.join(ROOT, entry.fetch('path'))
  assert_preflight!(File.file?(path), "payload file missing from working tree: #{entry.fetch('path')}")
  assert_preflight!(File.size(path) == entry.fetch('bytes'), "payload byte count mismatch: #{entry.fetch('path')}")
  assert_preflight!(sha256(path) == entry.fetch('sha256'), "payload hash mismatch: #{entry.fetch('path')}")
end

inventory_path = File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json')
inventory = JSON.parse(File.read(inventory_path, encoding: 'UTF-8'))
required_tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
spec.fetch('required_tools').each do |tool|
  assert_preflight!(required_tools.include?(tool), "validation inventory does not run #{tool}")
end
assert_preflight!(spec.fetch('forbidden').include?('repairing only the first failed deterministic fixture hash'), 'anti-single-fix rule missing')

puts "BASIC# Release Package Preflight v#{BasicSharp::VERSION}: PASS"
puts 'Manifest identity, version, package name, and counts: PASS'
puts 'Installed Git scope matches manifest: PASS'
puts 'Payload byte counts and SHA-256 records match active tree: PASS'
puts 'Release hardening tools are in the validation inventory: PASS'

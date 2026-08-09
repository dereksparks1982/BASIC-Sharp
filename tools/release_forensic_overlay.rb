#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'json'
require_relative '../compiler/ast_nodes'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/release/BASIC_SHARP_RELEASE_FORENSIC_OVERLAY_v1.json')
MANIFEST_PATH = File.join(ROOT, 'BASIC_SHARP_PATCH_MANIFEST.json')
INVENTORY_PATH = File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json')

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
manifest = JSON.parse(File.read(MANIFEST_PATH, encoding: 'UTF-8'))
inventory = JSON.parse(File.read(INVENTORY_PATH, encoding: 'UTF-8'))

failures = []

check = lambda do |condition, message|
  failures << message unless condition
end

sha256 = lambda do |path|
  Digest::SHA256.file(path).hexdigest
end

check.call(spec.fetch('format') == 'bsharp.release_forensic_overlay.json', 'wrong forensic overlay spec identity')
check.call(spec.fetch('format_version') == 1, 'wrong forensic overlay spec format version')
check.call(spec.fetch('target_version') == BasicSharp::VERSION, 'forensic overlay target version mismatch')
check.call(spec.fetch('status') == 'active_release_gate', 'forensic overlay status mismatch')
check.call(manifest.fetch('format') == 'BASIC_SHARP_CHANGED_FILES_PATCH', 'manifest identity mismatch')
check.call(manifest.fetch('target_version') == spec.fetch('required_target_version'), 'manifest target version mismatch')
check.call(manifest.fetch('base_version') == spec.fetch('required_base_version'), 'manifest base version mismatch')
check.call(inventory.fetch('format') == 'bsharp.trial_by_fire.validation_inventory.json', 'validation inventory identity mismatch')
check.call(inventory.fetch('target_version') == BasicSharp::VERSION, 'validation inventory target version mismatch')
check.call(spec.fetch('forbidden').include?('stopping after the first sealed inventory mismatch'), 'multi-mismatch rule missing')

record_groups = [
  ['test file', inventory.fetch('test_files')],
  ['required tool', inventory.fetch('required_tools')],
  ['sealed artifact', inventory.fetch('sealed_artifacts')]
]

record_groups.each do |label, records|
  records.each do |entry|
    relative = entry.fetch('path')
    path = File.join(ROOT, relative)
    unless File.file?(path)
      failures << "#{label} missing: #{relative}"
      next
    end

    actual_bytes = File.size(path)
    actual_sha = sha256.call(path)
    expected_bytes = entry.fetch('bytes')
    expected_sha = entry.fetch('sha256')

    if actual_bytes != expected_bytes || actual_sha != expected_sha
      failures << [
        "#{label} mismatch: #{relative}",
        "expected_bytes=#{expected_bytes}",
        "actual_bytes=#{actual_bytes}",
        "expected_sha=#{expected_sha}",
        "actual_sha=#{actual_sha}"
      ].join(' | ')
    end
  end
end

inventory.fetch('protected_artifacts').each do |relative, expected_sha|
  path = File.join(ROOT, relative)
  unless File.file?(path)
    failures << "protected artifact missing: #{relative}"
    next
  end

  actual_sha = sha256.call(path)
  failures << "protected artifact hash mismatch: #{relative} | expected_sha=#{expected_sha} | actual_sha=#{actual_sha}" unless actual_sha == expected_sha
end

unless failures.empty?
  warn 'BASIC# Release Forensic Overlay: FAIL'
  failures.each_with_index { |failure, index| warn "#{index + 1}. #{failure}" }
  raise "Release forensic overlay failed with #{failures.length} mismatch(es)."
end

puts "BASIC# Release Forensic Overlay v#{BasicSharp::VERSION}: PASS"
puts "Test files checked: #{inventory.fetch('test_files').length}"
puts "Required tools checked: #{inventory.fetch('required_tools').length}"
puts "Sealed artifacts checked: #{inventory.fetch('sealed_artifacts').length}"
puts "Protected artifacts checked: #{inventory.fetch('protected_artifacts').length}"
puts 'Every inventory mismatch would be reported together before project mutation: PASS'

# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/ast_nodes'

class TestReleaseForensicOverlay < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/release/BASIC_SHARP_RELEASE_FORENSIC_OVERLAY_v1.json')
  INVENTORY_PATH = File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def inventory
    @inventory ||= JSON.parse(File.read(INVENTORY_PATH, encoding: 'UTF-8'))
  end

  def test_contract_identity
    assert_equal 'bsharp.release_forensic_overlay.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'active_release_gate', spec.fetch('status')
  end

  def test_overlay_runs_before_mutation
    assert_equal 'v0.1.72', spec.fetch('required_base_version')
    assert_equal 'v0.1.73', spec.fetch('required_target_version')
    assert_equal 'pre-mutation forensic overlay', spec.fetch('required_installer_phase')
  end

  def test_forbids_single_mismatch_reporting
    forbidden = spec.fetch('forbidden')
    assert_includes forbidden, 'mutating the active project before overlay inventory verification'
    assert_includes forbidden, 'stopping after the first sealed inventory mismatch'
    assert_includes forbidden, 'accepting a package whose inventory names files not present in the overlaid candidate tree'
  end

  def test_validation_inventory_runs_overlay_gate
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/release_forensic_overlay.rb'
    assert_includes tools, 'tools/release_package_preflight.rb'
  end
end

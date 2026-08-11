# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/ast_nodes'

class TestReleasePackagePreflight < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/release/BASIC_SHARP_RELEASE_PACKAGE_PREFLIGHT_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_contract_identity
    assert_equal 'bsharp.release_package_preflight.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'active_release_gate', spec.fetch('status')
  end

  def test_manifest_requirements_are_current_versioned
    assert_equal 'BASIC_SHARP_PATCH_MANIFEST.json', spec.fetch('required_manifest')
    assert_equal 'APPLY_BASIC_SHARP_v0_1_73.sh', spec.fetch('required_installer')
    assert_equal 'v0.1.72', spec.fetch('required_base_version')
    assert_equal 'v0.1.73', spec.fetch('required_target_version')
  end

  def test_forbids_unproven_package_handoff
    forbidden = spec.fetch('forbidden')
    assert_includes forbidden, 'accepting a release package whose final extracted payload has not been audited'
    assert_includes forbidden, 'repairing only the first failed deterministic fixture hash'
    assert_includes forbidden, 'removing the DKLab compatibility bridge in v0.1.73'
    assert_includes forbidden, 'skipping the pre-mutation forensic overlay'
  end

  def test_trial_by_fire_inventory_runs_preflight
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/release_forensic_overlay.rb'
    assert_includes tools, 'tools/release_package_preflight.rb'
    assert_includes tools, 'tools/small_compiler_subset_execution_corpus.rb'
  end
end

# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/ast_nodes'

class TestEldereddIdentityContract < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/governance/BASIC_SHARP_ELDEREDD_IDENTITY_CONTRACT_v1.json')
  README_PATH = File.join(ROOT, 'README.md')
  COMPANY_BIBLE_PATH = File.join(ROOT, 'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md')
  ROADMAP_PATH = File.join(ROOT, 'docs/roadmap/BASIC_SHARP_ROADMAP.md')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def active_text
    @active_text ||= [README_PATH, COMPANY_BIBLE_PATH, ROADMAP_PATH].map { |path| File.read(path, encoding: 'UTF-8') }.join("
")
  end

  def test_identity_spec_matches_version
    assert_equal 'bsharp.elderedd_identity_contract.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
  end

  def test_elderedd_identity_is_current_truth
    assert_equal 'Elderedd Softworks LLC', spec.fetch('parent_company')
    assert_equal 'Elderedd Laboratory', spec.fetch('laboratory')
    assert_equal 'ELDL', spec.fetch('internal_shorthand')
    assert_equal 'BSharp Creator Services', spec.fetch('service_layer').fetch('name')
    assert_equal 'BCS', spec.fetch('service_layer').fetch('short_name')
  end

  def test_dklab_is_compatibility_not_active_identity
    assert_equal 'DKLab', spec.fetch('retired_identity')
    assert_equal '~/Elderedd/Projects/BASIC#', spec.fetch('canonical_future_path')
    assert_equal '~/DKLab/Projects/BASIC#', spec.fetch('legacy_compatibility_path')
    assert_includes active_text, 'DKLab is retired'
    assert_includes active_text, 'compatibility bridge'
    refute_includes active_text, 'DKLab is retained as the internal workspace and lab name'
  end

  def test_private_github_and_closeout_order_are_locked
    assert_includes spec.fetch('private_github_rule'), 'Never make the BASIC# GitHub repository public'
    assert_equal ['accepted snapshot', 'local Git commit/tag verification', 'GitHub push and remote verification', 'GitHub description update', 'final status summary'], spec.fetch('closeout_order')
    assert_includes active_text, 'GitHub description update'
  end
end

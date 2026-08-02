# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../tools/trial_by_fire_support'

class TestTrialByFireMutation < Minitest::Test
  def setup
    @trial = BasicSharp::TrialByFire
    @emitter, @loader = @trial.principal_bytecode
    machine = BasicSharp::BytecodeVirtualMachine.new(@loader)
    @trial::CAMPAIGN_EVENTS.each { |event| machine.run_event(event) }
    @save = BasicSharp::WorldSave.document_for(machine)
  end

  def test_source_mutation_families_are_rejected
    assert 12.times.all? { |index| @trial.reject_source_mutation!(index).fetch('artifact') == 'BASIC# source' }
  end

  def test_bsir_mutation_families_are_rejected
    assert 12.times.all? { |index| @trial.reject_bsir_mutation!(@trial.saved_bsir, @emitter.fingerprint, index).fetch('artifact') == 'saved BSIR' }
  end

  def test_save_mutation_families_are_atomic
    assert 12.times.all? { |index| @trial.reject_save_mutation!(@loader, @save, index).fetch('artifact') == 'BSharp Save' }
  end

  def test_bytecode_mutation_families_are_rejected
    assert 12.times.all? { |index| @trial.reject_bytecode_mutation!(@emitter.binary, index).fetch('artifact') == 'BSharp Bytecode' }
  end

  def test_every_principal_bytecode_prefix_is_rejected
    assert_equal @emitter.binary.bytesize, @trial.verify_every_truncated_prefix!(@emitter.binary)
  end
end

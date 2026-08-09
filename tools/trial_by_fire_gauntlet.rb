#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'trial_by_fire_support'

include BasicSharp

EVENTS = TrialByFire.env_count('BASIC_SHARP_TRIAL_EVENTS_PER_PATH', 128_000)
FRAMES = TrialByFire.env_count('BASIC_SHARP_TRIAL_PLATFORM_FRAMES', 128_000)
QUESTIONS = TrialByFire.env_count('BASIC_SHARP_TRIAL_ASK_QUESTIONS', 32_000)
CHECKPOINTS = TrialByFire.env_count('BASIC_SHARP_TRIAL_SAVE_CHECKPOINTS', 1_250)
WORLDS = TrialByFire.env_count('BASIC_SHARP_TRIAL_ISOLATED_WORLDS', 320)
PROGRAMS = TrialByFire.env_count('BASIC_SHARP_TRIAL_PROGRAMS', 384)
MUTATIONS = TrialByFire.env_count('BASIC_SHARP_TRIAL_MUTATIONS_PER_BOUNDARY', 3_072)
INPUT_FRAMES = TrialByFire.env_count('BASIC_SHARP_TRIAL_INPUT_MOVEMENT_FRAMES', 64_000)
SEED = Integer(ENV.fetch('BASIC_SHARP_TRIAL_SEED', TrialByFire::DEFAULT_SEED.to_s), 10)

raise ArgumentError, 'BASIC_SHARP_TRIAL_PROGRAMS cannot exceed 512' if PROGRAMS > 512

results = {}
run_phase = lambda do |name, maximum_seconds: nil, &block|
  puts "PHASE START: #{name}"
  value, seconds = TrialByFire.timed_phase(name, maximum_seconds: maximum_seconds, &block)
  results[name] = value
  puts format('PHASE PASS: %s (%.3f seconds)', name, seconds)
end

puts "BASIC# v#{BasicSharp::VERSION} TRIAL BY FIRE — WHOLE-LANGUAGE GAUNTLET"
puts "Counts: events=#{EVENTS}/path frames=#{FRAMES} ASK=#{QUESTIONS} saves=#{CHECKPOINTS} worlds=#{WORLDS} programs=#{PROGRAMS} mutations=#{MUTATIONS}/boundary input_movement_frames=#{INPUT_FRAMES}"

run_phase.call('independent golden trace') { TrialByFire.verify_golden_trace! }
run_phase.call('protected Profile 1–7 artifacts') do
  inventory = JSON.parse(File.read(TrialByFire::VALIDATION_INVENTORY, encoding: Encoding::UTF_8))
  TrialByFire.verify_profile_artifacts!(inventory.fetch('protected_artifacts'))
end
run_phase.call('event execution paths') { TrialByFire.verify_event_paths!(EVENTS) }
run_phase.call('platform movement') { TrialByFire.verify_platform_frames!(FRAMES) }
run_phase.call('read-only ASK') { TrialByFire.verify_ask_questions!(QUESTIONS) }
run_phase.call('combined movement and input actions') { TrialByFire.verify_combined_input_movement!(INPUT_FRAMES) }
run_phase.call('Save and restore') { TrialByFire.verify_save_checkpoints!(CHECKPOINTS) }
run_phase.call('simultaneous isolated worlds') { TrialByFire.verify_isolated_worlds!(WORLDS) }
run_phase.call('follow-up boundaries 1023/1024/1025') { TrialByFire.verify_follow_up_boundaries! }
run_phase.call('deterministic cross-profile programs') do
  TrialByFire.run_generator_campaign(
    count: PROGRAMS,
    seed: SEED,
    progress: lambda { |done, total| puts "  generator #{done}/#{total}" if (done % 32).zero? || done == total }
  ).reject { |key, _value| key == 'results' }
end
run_phase.call('hostile artifact campaign') do
  TrialByFire.run_mutation_campaign(
    count: MUTATIONS,
    progress: lambda { |done, total| puts "  mutations #{done}/#{total}" if (done % 256).zero? || done == total }
  ).reject { |key, _value| key == 'rejections' }
end

summary = {
  'format' => 'bsharp.trial_by_fire.run.json',
  'format_version' => 1,
  'basic_sharp_version' => BasicSharp::VERSION,
  'counts' => {
    'events_per_path' => EVENTS,
    'platform_frames' => FRAMES,
    'ask_questions' => QUESTIONS,
    'save_checkpoints' => CHECKPOINTS,
    'isolated_worlds' => WORLDS,
    'generated_programs' => PROGRAMS,
    'mutations_per_boundary' => MUTATIONS,
    'input_movement_frames' => INPUT_FRAMES
  },
  'results_sha256' => TrialByFire.semantic_sha256(results)
}
puts JSON.generate(summary)
puts "BASIC# v#{BasicSharp::VERSION} TRIAL BY FIRE: PASS"

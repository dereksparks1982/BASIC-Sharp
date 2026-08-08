# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'parser'
require_relative 'resolver'
require_relative 'runtime'
require_relative 'world_save'
require_relative 'ask'

module BasicSharp
  class MeaningProfileError < ArgumentError; end

  module MeaningProfile
    PROFILE = 'bsharp.meaning.v1'
    PROFILE_2 = 'bsharp.meaning.v2'
    PROFILE_3 = 'bsharp.meaning.v3'
    PROFILE_4 = 'bsharp.meaning.v4'
    PROFILE_5 = 'bsharp.meaning.v5'
    PROFILE_6 = 'bsharp.meaning.v6'
    PROFILE_7 = 'bsharp.meaning.v7'
    MANIFEST_FORMAT = 'bsharp.meaning.conformance.json'
    MANIFEST_FORMAT_VERSION = 1
    EXPECTED_FORMAT = 'bsharp.meaning.case.json'
    EXPECTED_FORMAT_VERSION = 1
    MEANING_KEYS = %w[kinds objects facts events if_rules].freeze
    MEANING_KEYS_3 = (MEANING_KEYS + %w[controls hover_declarations context_declarations]).freeze
    NON_MEANING_KEYS = %w[line_number raw].freeze
    FORBIDDEN_SERIALIZED_TERMS = %w[BasicSharp Struct ObjectSpace RubyVM].freeze

    module_function

    def compile_source(source)
      parser = Parser.new(source)
      program = parser.parse
      document = SemanticResolver.new(program, dictionary: parser.dictionary).resolve
      [program, document]
    end

    def observe_case(case_entry, root:, profile: PROFILE)
      source_path = File.expand_path(case_entry.fetch('source'), root)
      source = File.read(source_path, encoding: 'UTF-8')
      _program, document = compile_source(source)
      diagnostics = Array(document.diagnostics)
      errors = diagnostics.select { |entry| entry.severity == 'error' }.map { |entry| diagnostic_entry(entry) }
      warnings = diagnostics.select { |entry| entry.severity == 'warning' }.map { |entry| diagnostic_entry(entry) }

      observation = {
        'format' => EXPECTED_FORMAT,
        'format_version' => EXPECTED_FORMAT_VERSION,
        'profile' => profile,
        'case_id' => case_entry.fetch('id'),
        'compile' => {
          'errors' => errors,
          'warnings' => warnings,
          'meaning' => normalize_bsir(document)
        }
      }
      return canonicalize(observation) unless errors.empty?

      source_runtime = observe_runtime(document, case_entry)
      round_trip_document = JSON.parse(JSON.generate(document.to_h))
      bsir_runtime = observe_runtime(round_trip_document, case_entry)
      unless source_runtime == bsir_runtime
        raise MeaningProfileError, "#{case_entry.fetch('id')} source and BSharp IR observations disagree"
      end

      observation['execution'] = source_runtime
      observation['source_bsir_parity'] = true
      canonicalize(observation)
    end

    def observe_runtime(document, case_entry)
      runtime = Runtime.new(document)
      result = {
        'startup' => runtime_view(runtime),
        'events' => []
      }

      Array(case_entry['events']).each do |event_text|
        event_result = runtime.run_event(event_text)
        result['events'] << normalize_event_result(event_result)
      end

      questions = Array(case_entry['ask'])
      unless questions.empty?
        answers = Ask.new(runtime).answer_many(questions)
        result['ask'] = {
          'questions' => questions,
          'answers' => canonicalize(answers)
        }
      end

      if case_entry['save'] == true
        save_document = WorldSave.document_for(runtime)
        restored = Runtime.new(document, world_save: save_document)
        result['save'] = {
          'document' => normalize_save(save_document),
          'restored' => runtime_view(restored),
          'startup_replayed' => !restored.startup_ran.empty? || !restored.startup_if_rules.empty? || !restored.startup_follow_up_events.empty?
        }
      end

      result['final'] = runtime_view(runtime)
      result
    end

    def runtime_view(runtime)
      {
        'snapshot' => canonicalize(runtime.snapshot),
        'if_rules' => canonicalize(runtime.ask_if_rules),
        'save_ready' => runtime.save_ready?,
        'world' => canonicalize(runtime.ask_world_summary)
      }
    end

    def normalize_event_result(result)
      kept = %w[event matched matched_when understood ran steps selections if_rules context error follow_up_events event_trail]
      canonicalize(result.select { |key, _value| kept.include?(key.to_s) })
    end

    def normalize_bsir(document)
      hash = stringify_keys(document.respond_to?(:to_h) ? document.to_h : document)
      keys = [PROFILE_3, PROFILE_4, PROFILE_5, PROFILE_6, PROFILE_7].include?(hash['meaning_profile']) ? MEANING_KEYS_3 : MEANING_KEYS
      keys.each_with_object({}) do |key, result|
        result[key] = canonicalize(hash.fetch(key, []))
      end
    end

    def normalize_save(document)
      canonicalize(stringify_keys(document).reject { |key, _value| key == 'created_by_basic_sharp' })
    end

    def diagnostic_entry(diagnostic)
      {
        'severity' => diagnostic.severity,
        'line_number' => diagnostic.line_number,
        'message' => diagnostic.message
      }
    end

    def canonical_json(value)
      "#{JSON.pretty_generate(canonicalize(value))}\n"
    end

    def sha256(value)
      Digest::SHA256.hexdigest(value)
    end

    def canonicalize(value)
      case value
      when Hash
        stringify_keys(value).keys.sort.each_with_object({}) do |key, result|
          next if NON_MEANING_KEYS.include?(key)

          result[key] = canonicalize(stringify_keys(value).fetch(key))
        end
      when Array
        value.map { |entry| canonicalize(entry) }
      else
        value
      end
    end

    def stringify_keys(value)
      case value
      when Hash
        value.each_with_object({}) { |(key, entry), result| result[key.to_s] = stringify_keys(entry) }
      when Array
        value.map { |entry| stringify_keys(entry) }
      else
        value
      end
    end

    def validate_manifest!(manifest, root:)
      unless manifest.is_a?(Hash) && manifest['format'] == MANIFEST_FORMAT && manifest['format_version'] == MANIFEST_FORMAT_VERSION
        raise MeaningProfileError, 'Meaning conformance manifest format is not supported.'
      end
      unless [PROFILE, PROFILE_2, PROFILE_3, PROFILE_4, PROFILE_5, PROFILE_6, PROFILE_7].include?(manifest['profile'])
        raise MeaningProfileError, "Meaning conformance profile must be #{PROFILE}, #{PROFILE_2}, #{PROFILE_3}, #{PROFILE_4}, #{PROFILE_5}, #{PROFILE_6}, or #{PROFILE_7}."
      end
      cases = manifest['cases']
      expected_count = { PROFILE => 13, PROFILE_2 => 5, PROFILE_3 => 9, PROFILE_4 => 8, PROFILE_5 => 10, PROFILE_6 => 10, PROFILE_7 => 10 }.fetch(manifest['profile'])
      unless cases.is_a?(Array) && cases.length == expected_count
        raise MeaningProfileError, "#{manifest['profile']} must contain exactly #{expected_count} conformance cases."
      end

      ids = cases.map { |entry| entry['id'] }
      raise MeaningProfileError, 'Meaning conformance case identifiers must be unique.' unless ids.uniq.length == ids.length

      cases.each do |entry|
        %w[id source expected expected_sha256].each do |key|
          raise MeaningProfileError, "Meaning conformance case is missing #{key}." if entry[key].to_s.empty?
        end
        [entry['source'], entry['expected']].each do |relative|
          path = File.expand_path(relative, root)
          unless path.start_with?(File.expand_path(root) + File::SEPARATOR) && File.file?(path)
            raise MeaningProfileError, "Meaning conformance file is missing: #{relative}"
          end
        end
        expected_text = File.binread(File.expand_path(entry['expected'], root))
        unless sha256(expected_text) == entry['expected_sha256']
          raise MeaningProfileError, "Meaning conformance expected hash changed: #{entry['expected']}"
        end
      end
      true
    end

    def forbidden_serialized_data?(text)
      return true if FORBIDDEN_SERIALIZED_TERMS.any? { |term| text.include?(term) }
      return true if text.match?(%r{/(?:home|tmp|mnt|Users)/})
      return true if text.match?(/\b\d{4}-\d{2}-\d{2}T\d{2}:\d{2}/)

      false
    end
  end
end

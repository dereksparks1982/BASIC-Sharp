# frozen_string_literal: true

require 'digest'
require 'fileutils'
require 'json'
require 'tempfile'
require_relative 'ast_nodes'

module BasicSharp
  class WorldSaveError < ArgumentError; end

  module WorldSave
    FORMAT = 'bsharp.save.json'
    FORMAT_VERSION = 1
    FORMAT_VERSION_2 = 2
    FORMAT_VERSION_3 = 3
    FINGERPRINT_ALGORITHM = 'sha256-bsir-meaning-v1'
    FINGERPRINT_ALGORITHM_2 = 'sha256-bsir-meaning-v2'
    FINGERPRINT_ALGORITHM_3 = 'sha256-bsir-meaning-v3'
    MEANING_PROFILE_1 = 'bsharp.meaning.v1'
    MEANING_PROFILE_2 = 'bsharp.meaning.v2'
    MEANING_PROFILE_3 = 'bsharp.meaning.v3'
    MEANING_KEYS = %w[kinds objects facts events if_rules].freeze
    MEANING_KEYS_3 = (MEANING_KEYS + %w[controls hover_declarations context_declarations]).freeze

    module_function

    def read(path)
      JSON.parse(File.read(path))
    rescue JSON::ParserError
      raise WorldSaveError, 'BSharp Save cannot load because the file is not valid JSON.'
    rescue Errno::ENOENT
      raise WorldSaveError, "BSharp Save file not found: #{path}"
    rescue Errno::EACCES
      raise WorldSaveError, "BSharp Save cannot read: #{path}"
    end

    def save_file?(document)
      document.is_a?(Hash) && normalize(document['format']) == FORMAT
    end

    def program_fingerprint(document)
      source = stringify_keys(document.respond_to?(:to_h) ? document.to_h : document)
      keys = source['meaning_profile'] == MEANING_PROFILE_3 ? MEANING_KEYS_3 : MEANING_KEYS
      meaning = keys.each_with_object({}) do |key, result|
        result[key] = source.fetch(key, [])
      end
      Digest::SHA256.hexdigest(JSON.generate(canonicalize(meaning)))
    end

    def document_for(runtime)
      profile = runtime.respond_to?(:meaning_profile) ? runtime.meaning_profile : MEANING_PROFILE_1
      {
        'format' => FORMAT,
        'format_version' => save_format_version(profile),
        'created_by_basic_sharp' => VERSION,
        'program_fingerprint' => {
          'algorithm' => fingerprint_algorithm(profile),
          'value' => runtime.program_fingerprint
        },
        'world' => runtime.world_save_state
      }
    end

    def write(path, runtime)
      content = "#{JSON.pretty_generate(document_for(runtime))}\n"
      atomic_write(path, content)
      path
    end

    def validate_header!(document, program_document)
      profile = meaning_profile(program_document)
      validate_header_for_fingerprint!(document, program_fingerprint(program_document), meaning_profile: profile)
    end

    def validate_header_for_fingerprint!(document, expected_fingerprint, meaning_profile: MEANING_PROFILE_1)
      unless document.is_a?(Hash) && normalize(document['format']) == FORMAT
        raise WorldSaveError, 'BSharp Save cannot load because this is not a BSharp Save file.'
      end

      expected_version = save_format_version(meaning_profile)
      version = document['format_version']
      unless version == expected_version
        shown = version.nil? ? '(missing)' : version
        raise WorldSaveError, "This BSharp Save uses format version #{shown}.\nThis program requires BSharp Save format version #{expected_version}."
      end

      fingerprint = document['program_fingerprint']
      expected_algorithm = fingerprint_algorithm(meaning_profile)
      unless fingerprint.is_a?(Hash) && fingerprint['algorithm'] == expected_algorithm && fingerprint['value'].is_a?(String)
        raise WorldSaveError, 'BSharp Save cannot load because its program fingerprint is missing or invalid.'
      end

      return if fingerprint['value'] == expected_fingerprint

      raise WorldSaveError, "This BSharp Save belongs to a different BASIC# program.\nLoad it with the same .bsharp, .bsir.json, or .bsbc program that created it."
    end

    def atomic_write(path, content)
      destination = File.expand_path(path)
      directory = File.dirname(destination)
      FileUtils.mkdir_p(directory) unless Dir.exist?(directory)
      basename = File.basename(destination)
      temp_path = nil

      Tempfile.create([".#{basename}.", '.tmp'], directory) do |file|
        temp_path = file.path
        file.binmode
        file.write(content)
        file.flush
        file.fsync
        file.close
        File.rename(temp_path, destination)
        temp_path = nil
      end
    rescue SystemCallError => error
      raise WorldSaveError, "BSharp Save could not write '#{path}': #{error.message}"
    ensure
      File.delete(temp_path) if temp_path && File.exist?(temp_path)
    end

    def canonicalize(value)
      case value
      when Hash
        value.keys.reject { |key| key.to_s == 'line_number' }.sort.each_with_object({}) do |key, result|
          result[key] = canonicalize(value[key])
        end
      when Array
        value.map { |entry| canonicalize(entry) }
      else
        value
      end
    end

    def meaning_profile(document)
      source = stringify_keys(document.respond_to?(:to_h) ? document.to_h : document)
      return MEANING_PROFILE_3 if source['meaning_profile'] == MEANING_PROFILE_3
      source['meaning_profile'] == MEANING_PROFILE_2 ? MEANING_PROFILE_2 : MEANING_PROFILE_1
    end

    def save_format_version(profile)
      return FORMAT_VERSION_3 if profile == MEANING_PROFILE_3
      profile == MEANING_PROFILE_2 ? FORMAT_VERSION_2 : FORMAT_VERSION
    end

    def fingerprint_algorithm(profile)
      return FINGERPRINT_ALGORITHM_3 if profile == MEANING_PROFILE_3
      profile == MEANING_PROFILE_2 ? FINGERPRINT_ALGORITHM_2 : FINGERPRINT_ALGORITHM
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

    def normalize(value)
      value.to_s.strip.downcase.gsub(/\s+/, ' ')
    end
  end
end

# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'small_compiler_subset_parser'

module BasicSharp
  class SmallCompilerSubsetSymbolTableContract
    FORMAT = 'bsharp.small_compiler_subset.symbol_table_contract.record'
    STATUS = 'symbol_table_contract_under_ruby_referee'

    ErrorRecord = Struct.new(:id, :line_number, :severity, :plain_message, :source_message, keyword_init: true) do
      def to_h
        {
          id: id,
          line_number: line_number,
          severity: severity,
          plain_message: plain_message,
          source_message: source_message
        }
      end
    end

    attr_reader :source, :subset_parser

    def initialize(source)
      @source = source
      @subset_parser = SmallCompilerSubsetParser.new(source)
      @symbols = nil
      @errors = nil
    end

    def symbols
      build unless @symbols
      @symbols
    end

    def errors
      build unless @errors
      @errors
    end

    def to_h
      {
        format: FORMAT,
        version: BasicSharp::VERSION,
        status: STATUS,
        parser_ruby_referee_matches: subset_parser.parser_matches_ruby_referee?,
        symbols: symbols,
        errors: errors.map(&:to_h),
        symbols_sha256: self.class.digest_for(symbols),
        errors_sha256: self.class.digest_for(errors.map(&:to_h))
      }
    end

    def self.digest_for(value)
      Digest::SHA256.hexdigest(JSON.generate(normalize(value)))
    end

    def self.normalize(value)
      case value
      when Hash
        value.each_with_object({}) { |(key, child), result| result[key.to_s] = normalize(child) }.sort.to_h
      when Array
        value.map { |child| normalize(child) }
      else
        value
      end
    end

    private

    def build
      @symbols = {
        'kinds' => [],
        'objects' => [],
        'actions' => [],
        'values' => [],
        'scene_heads' => []
      }
      @errors = []
      kind_lines = {}
      object_lines = {}
      known_kinds = { 'thing' => 0 }
      known_objects = {}
      actions = {}
      values = {}
      scene_heads = []

      subset_parser.statements.each do |statement|
        case statement.starter
        when 'KINDS'
          statement.children.each { |child| read_kind(child, known_kinds, kind_lines) }
        when 'DEFINE'
          statement.children.each { |child| read_object(child, known_kinds, known_objects, object_lines) }
        when 'START'
          statement.children.each { |child| read_references(child.body, child.line_number, known_objects, values) }
        when 'WHEN', 'IF'
          scene_heads << { 'starter' => statement.starter, 'head' => statement.head.to_s, 'line_number' => statement.line_number }
          read_references(statement.head.to_s, statement.line_number, known_objects, values)
          statement.children.each { |child| read_action_child(child, known_objects, actions, values) }
        when 'OTHERWISE'
          statement.children.each { |child| read_action_child(child, known_objects, actions, values) }
        when 'HOVER', 'CONTEXT'
          read_subject_reference(statement.head.to_s, statement.line_number, known_objects)
          statement.children.each { |child| read_references(child.body, child.line_number, known_objects, values) }
        when 'CONTROLS'
          statement.children.each { |child| read_references(child.body, child.line_number, known_objects, values) }
        end
      end

      @symbols['kinds'] = known_kinds.reject { |name, _| name == 'thing' }.map { |name, line| { 'name' => name, 'line_number' => line } }.sort_by { |entry| [entry['name'], entry['line_number']] }
      @symbols['objects'] = known_objects.map { |name, entry| { 'name' => name, 'kind' => entry.fetch('kind'), 'line_number' => entry.fetch('line_number') } }.sort_by { |entry| [entry['name'], entry['line_number']] }
      @symbols['actions'] = actions.map { |name, line| { 'name' => name, 'line_number' => line } }.sort_by { |entry| [entry['name'], entry['line_number']] }
      @symbols['values'] = values.map { |name, line| { 'name' => name, 'line_number' => line } }.sort_by { |entry| [entry['name'], entry['line_number']] }
      @symbols['scene_heads'] = scene_heads
      @errors.sort_by! { |error| [error.line_number, error.id, error.source_message] }
    end

    def read_kind(child, known_kinds, kind_lines)
      if (root = child.body.match(/\A#(.+)\z/)) && !child.body.match?(/\s+is\s+/i)
        name = normalize_name(root[1])
        return if name == 'thing'
      end

      match = child.body.match(/\A#(.+?)\s+is\s+a\s+#(.+)\z/i)
      return unless match

      name = normalize_name(match[1])
      parent = normalize_name(match[2])
      if known_kinds.key?(name)
        @errors << error('BSS1001', child.line_number, "Kind '#{name}' is already defined.", "Duplicate Kind '#{name}'")
      else
        known_kinds[name] = child.line_number
        kind_lines[name] = child.line_number
      end
      unless known_kinds.key?(parent)
        @errors << error('BSS2001', child.line_number, "Kind '#{name}' names unknown parent Kind '#{parent}'.", "Unknown parent Kind '#{parent}'")
      end
    end

    def read_object(child, known_kinds, known_objects, object_lines)
      match = child.body.match(/\A@(.+?)\s+is\s+an?\s+#(.+)\z/i)
      return unless match

      name = normalize_name(match[1])
      kind = normalize_name(match[2])
      if known_objects.key?(name)
        @errors << error('BSS1002', child.line_number, "Thing '@#{name}' is already defined.", "Duplicate Thing '@#{name}'")
      else
        known_objects[name] = { 'kind' => kind, 'line_number' => child.line_number }
        object_lines[name] = child.line_number
      end
      unless known_kinds.key?(kind)
        @errors << error('BSS2002', child.line_number, "Thing '@#{name}' uses unknown Kind '#{kind}'.", "Unknown Kind '#{kind}'")
      end
    end

    def read_action_child(child, known_objects, actions, values)
      if (match = child.body.match(/\A\((\w+)\b\s*(.*)\z/))
        actions[match[1].downcase] ||= child.line_number
        read_references(match[2].to_s, child.line_number, known_objects, values)
      else
        read_references(child.body, child.line_number, known_objects, values)
      end
    end

    def read_references(text, line_number, known_objects, values)
      text.to_s.scan(/@([a-zA-Z0-9][a-zA-Z0-9 _-]*?)(?=\s+(?:is|isnt|has|to|by|when|and|or)\b|\.|\)|$)/).flatten.each do |raw|
        name = normalize_name(raw)
        next if name.empty?
        read_subject_reference("@#{name}", line_number, known_objects)
      end
      text.to_s.scan(/\bhas\s+(?:[-+]?\d+\s+)?([a-zA-Z][a-zA-Z0-9 _-]*?)\b(?:\.|$)/i).flatten.each do |raw|
        name = normalize_name(raw)
        values[name] ||= line_number unless name.empty?
      end
    end

    def read_subject_reference(text, line_number, known_objects)
      match = text.to_s.match(/\A@(.+)\z/)
      return unless match
      name = normalize_name(match[1])
      unless known_objects.key?(name)
        @errors << error('BSS2003', line_number, "Thing '@#{name}' is used before it is defined.", "Unknown Thing '@#{name}'")
      end
    end

    def error(id, line_number, plain_message, source_message)
      ErrorRecord.new(id: id, line_number: line_number, severity: 'error', plain_message: plain_message, source_message: source_message)
    end

    def normalize_name(value)
      value.to_s.strip.downcase.gsub(/\s+/, ' ')
    end
  end
end

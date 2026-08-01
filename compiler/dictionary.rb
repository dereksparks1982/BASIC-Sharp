# frozen_string_literal: true

module BasicSharp
  class CoreDictionary
    BUILTIN_KINDS = %w[
      thing place actor person creature door container supporter key weapon food clothing device guard table
    ].freeze
    CONFUSED_WORDS = { 'there' => 'there', 'their' => 'there' }.freeze

    attr_reader :kinds, :kind_parents, :states, :actions, :relations, :objects

    def initialize
      @kinds = BUILTIN_KINDS.dup
      @kind_parents = {}
      @kind_family_cache = {}
      @states = %w[
        open closed locked unlocked alive dead calm angry friendly hostile visible hidden carried dropped broken whole on off
      ]
      @actions = %w[
        take drop carry open close lock unlock attack damage change increase decrease speak give eat wear remove sound examine cause
      ]
      @relations = ['is', 'isnt', 'in', 'on', 'held by', 'worn by', 'connects', 'unlocks', 'owned by']
      @objects = {}
      add_object('player', 'person')
    end

    def add_kind(name, parent)
      normalized_name = normalize(name)
      normalized_parent = normalize(parent)
      @kinds << normalized_name unless @kinds.include?(normalized_name)
      @kind_parents[normalized_name] = normalized_parent
      @kind_family_cache.clear
    end

    def kind_parent(name)
      @kind_parents[normalize(name)]
    end

    def kind_family(name)
      normalized = normalize(name)
      @kind_family_cache[normalized] ||= build_kind_family(normalized).freeze
    end

    def kind_matches?(actual_kind, expected_kind)
      expected = normalize(expected_kind)
      kind_family(actual_kind).include?(expected)
    end

    def kind_cycle_with(name, parent)
      normalized_name = normalize(name)
      current = normalize(parent)
      path = [normalized_name]
      seen = {}

      until current.nil? || current.empty? || seen[current]
        path << current
        return path if current == normalized_name

        seen[current] = true
        current = kind_parent(current)
      end

      nil
    end

    def normalize_confused_word(word)
      normalized = normalize(word)
      CONFUSED_WORDS.fetch(normalized, normalized)
    end

    def known_kind?(word)
      @kinds.include?(normalize(word))
    end

    def known_state?(word)
      @states.include?(normalize(word))
    end

    def known_action?(word)
      @actions.include?(normalize_action(word))
    end

    def known_event_action?(word)
      action = normalize_action(word)
      action != 'cause' && @actions.include?(action)
    end

    def known_object?(name)
      @objects.key?(normalize_name(name))
    end

    def add_object(name, kind)
      @objects[normalize_name(name)] = normalize(kind)
    end

    def object_kind(name)
      @objects[normalize_name(name)]
    end

    def ambiguous_type?(kind)
      objects_by_kind(kind).length > 1
    end

    def objects_by_kind(kind)
      expected = normalize(kind)
      @objects.select { |_name, object_kind| kind_matches?(object_kind, expected) }.keys
    end

    private

    def build_kind_family(name)
      family = []
      seen = {}
      current = name

      while current && !current.empty? && !seen[current]
        family << current
        seen[current] = true
        current = kind_parent(current)
      end

      family
    end

    def normalize(word)
      word.to_s.strip.downcase
    end

    def normalize_action(word)
      normalize(word).sub(/^\(/, '')
    end

    def normalize_name(name)
      name.to_s.strip.downcase.gsub(/\s+/, ' ')
    end
  end
end

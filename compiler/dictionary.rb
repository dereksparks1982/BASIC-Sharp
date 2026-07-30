# frozen_string_literal: true

module DKScript
  class CoreDictionary
    CONFUSED_WORDS = { 'there' => 'there', 'their' => 'there' }.freeze
    attr_reader :kinds, :kind_parents, :states, :actions, :relations, :objects

    def initialize
      @kinds = %w[
        thing place actor person creature door container supporter key weapon food clothing device guard table
      ]
      @kind_parents = {}
      @states = %w[
        open closed locked unlocked alive dead calm angry friendly hostile visible hidden carried dropped broken whole on off
      ]
      @actions = %w[
        take drop carry open close lock unlock attack damage change speak give eat wear remove sound
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
    end

    def kind_parent(name)
      @kind_parents[normalize(name)]
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
      matches = objects_by_kind(kind)
      matches.length > 1
    end

    def objects_by_kind(kind)
      normalized = normalize(kind)
      @objects.select { |_name, object_kind| object_kind == normalized }.keys
    end

    private

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

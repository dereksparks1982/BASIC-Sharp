# frozen_string_literal: true

module BasicSharp
  class GameInteractionError < ArgumentError; end

  class GameInteraction
    def initialize(document, machine:)
      @document = stringify_keys(document.respond_to?(:to_h) ? document.to_h : document)
      @machine = machine
      @objects = Array(@document['objects']).each_with_object({}) { |entry, result| result[entry['name']] = entry }
      kinds = Array(@document['kinds'])
      @parents = kinds.each_with_index.each_with_object({}) do |(entry, _index), result|
        parent = entry['parent']
        if parent.nil? && entry['parent_index'].is_a?(Integer) && entry['parent_index'] != 0xFFFF_FFFF
          parent = kinds.fetch(entry['parent_index'])['name']
        end
        result[entry['name']] = parent
      end
    end

    def hover_for(object_name)
      thing = current_thing(object_name)
      declarations_for('hover_declarations', thing).flat_map { |entry| Array(entry['fields']) }.each_with_object([]) do |field, result|
        name = field.fetch('name')
        value = hover_value(name, thing)
        existing = result.index { |entry| entry['field'] == name }
        shown = { 'field' => name, 'value' => value }
        existing ? result[existing] = shown : result << shown
      end
    end

    def context_for(object_name)
      thing = current_thing(object_name)
      declarations_for('context_declarations', thing).flat_map { |entry| Array(entry['entries']) }.each_with_object([]) do |entry, result|
        next unless condition_true?(entry['condition'], thing)
        existing = result.index { |candidate| candidate['label'] == entry['label'] }
        shown = { 'label' => entry.fetch('label'), 'action' => entry.fetch('action') }
        existing ? result[existing] = shown : result << shown
      end
    end

    def execute(object_name, label)
      entry = context_for(object_name).find { |candidate| candidate['label'] == label.to_s }
      raise GameInteractionError, "#{object_name} does not currently offer '#{label}'." unless entry
      unless @machine.respond_to?(:execute_context_action)
        raise GameInteractionError, 'The selected BASIC# runtime cannot execute context actions.'
      end
      @machine.execute_context_action(entry.fetch('action'), object_name.to_s)
    end

    private

    def current_thing(name)
      thing = @machine.ask_thing(name.to_s)
      raise GameInteractionError, "BASIC# cannot show interaction information for unknown object '@#{name}'." unless thing
      thing
    end

    def declarations_for(key, thing)
      family = kind_family(thing.fetch('kind'))
      Array(@document[key]).select do |declaration|
        subject = declaration['subject'] || {}
        case subject['type']
        when 'kind_declaration' then family.include?(subject['kind_name'])
        when 'object' then subject['name'] == thing['name']
        else false
        end
      end.sort_by do |declaration|
        subject = declaration['subject'] || {}
        subject['type'] == 'object' ? family.length + 1 : family.reverse.index(subject['kind_name']).to_i
      end
    end

    def kind_family(kind)
      family = []
      current = kind
      while current && !family.include?(current)
        family << current
        current = @parents[current]
      end
      family
    end

    def hover_value(field, thing)
      case field
      when 'name' then thing.fetch('name')
      when 'kind' then thing.fetch('kind')
      when 'state' then Array(thing['states']).join(', ')
      when 'description'
        value = thing.fetch('values', {})['description']
        raise GameInteractionError, "@#{thing['name']} does not have description information." if value.nil?
        value
      else
        raise GameInteractionError, "Unknown hover information '#{field}'."
      end
    end

    def condition_true?(condition, thing)
      return true if condition.nil?
      state = condition.dig('value', 'name') || condition.dig('value', 'text')
      present = Array(thing['states']).include?(state)
      condition['relation'] == 'isnt' ? !present : present
    end

    def stringify_keys(value)
      case value
      when Hash then value.each_with_object({}) { |(key, entry), result| result[key.to_s] = stringify_keys(entry) }
      when Array then value.map { |entry| stringify_keys(entry) }
      else value
      end
    end
  end
end

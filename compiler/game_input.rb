# frozen_string_literal: true

require 'set'
require_relative 'host_adapter'

module BasicSharp
  class GameInputError < ArgumentError; end

  class GameInput
    HOLD_THRESHOLD_MS = 200
    DIAGONAL = 1.0 / Math.sqrt(2.0)
    DIRECTIONS = {
      'north' => [0.0, -1.0],
      'south' => [0.0, 1.0],
      'west' => [-1.0, 0.0],
      'east' => [1.0, 0.0]
    }.freeze

    def initialize(document, adapter: HostAdapter.new)
      @document = stringify_keys(document.respond_to?(:to_h) ? document.to_h : document)
      @adapter = adapter
      @pressed = Set.new
      @pointer = { 'x' => 0.0, 'y' => 0.0, 'distance' => 0.0, 'maximum_distance' => 1.0 }
      @right_down_at = nil
      @right_target = nil
      load_controls!
    end

    attr_reader :adapter

    def process(event)
      supplied = stringify_keys(event)
      type = supplied.fetch('type').to_s
      case type
      when 'key_down'
        @pressed.add(supplied.fetch('key').to_s.upcase)
      when 'key_up'
        @pressed.delete(supplied.fetch('key').to_s.upcase)
      when 'pointer_move'
        %w[x y distance maximum_distance].each do |name|
          @pointer[name] = numeric(supplied[name], name) if supplied.key?(name)
        end
        emit_facing if @face_pointer
      when 'right_mouse_down'
        @right_down_at = integer_time(supplied['time_ms'])
        @right_target = supplied['object']&.to_s
        if @right_target && !@right_target.empty?
          @adapter.emit('open_context', 'object' => @right_target)
        end
      when 'right_mouse_up'
        @right_down_at = nil
        @right_target = nil
      when 'frame'
        emit_movement(integer_time(supplied['time_ms']))
      else
        raise GameInputError, "Unknown input event '#{type}'."
      end
      @adapter.drain
    end

    private

    def load_controls!
      declarations = Array(@document['controls'])
      raise GameInputError, 'This BASIC# program does not declare CONTROLS for PLAYER.' if declarations.empty?
      speed_fact = Array(@document['facts']).find do |fact|
        fact.dig('subject', 'name') == 'player' && fact['relation'] == 'has' && fact['value_name'] == 'speed'
      end
      @speed = speed_fact && speed_fact['amount']
      unless @speed.is_a?(Numeric) && @speed.finite? && @speed.positive?
        raise GameInputError, 'PLAYER must possess a positive numeric speed in START.'
      end
      @key_directions = {}
      @face_pointer = false
      @right_mouse_move = false
      declarations.each do |declaration|
        Array(declaration['instructions']).each do |instruction|
          case instruction['type']
          when 'key_move' then @key_directions[instruction.fetch('key')] = instruction.fetch('direction')
          when 'face_pointer' then @face_pointer = true
          when 'right_mouse_move' then @right_mouse_move = true
          end
        end
      end
    end

    def emit_facing
      @adapter.emit('face_pointer', 'subject' => 'player', 'x' => @pointer['x'], 'y' => @pointer['y'])
    end

    def emit_movement(time_ms)
      if mouse_move_active?(time_ms)
        maximum = [@pointer['maximum_distance'], 1.0].max
        scale = [[@pointer['distance'] / maximum, 0.0].max, 1.0].min
        @adapter.emit(
          'move_toward_pointer',
          'subject' => 'player',
          'maximum_speed' => @speed,
          'speed_scale' => rounded(scale),
          'x' => @pointer['x'],
          'y' => @pointer['y']
        )
        return
      end

      x = 0.0
      y = 0.0
      @pressed.each do |key|
        direction = @key_directions[key]
        next unless direction
        vector = DIRECTIONS.fetch(direction)
        x += vector[0]
        y += vector[1]
      end
      if x != 0.0 && y != 0.0
        x *= DIAGONAL
        y *= DIAGONAL
      end
      @adapter.emit('move', 'subject' => 'player', 'maximum_speed' => @speed, 'x' => rounded(x), 'y' => rounded(y), 'speed_scale' => 1.0)
    end

    def mouse_move_active?(time_ms)
      @right_mouse_move && @right_down_at && @right_target.nil? && time_ms - @right_down_at >= HOLD_THRESHOLD_MS
    end

    def numeric(value, label)
      number = Float(value)
      raise GameInputError, "#{label} must be a finite number." unless number.finite?
      number
    rescue ArgumentError, TypeError
      raise GameInputError, "#{label} must be a number."
    end

    def integer_time(value)
      Integer(value || 0)
    rescue ArgumentError, TypeError
      raise GameInputError, 'time_ms must be a whole number.'
    end

    def rounded(value)
      value.round(12)
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

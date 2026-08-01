# frozen_string_literal: true

require 'set'
require_relative 'host_adapter'

module BasicSharp
  class GameInputError < ArgumentError; end

  class GameInput
    HOLD_THRESHOLD_MS = 200
    PLATFORM_GRAVITY = 30.0
    MAX_FRAME_MS = 250
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
      @last_frame_at = nil
      @vertical_velocity = 0.0
      @jump_requested = false
      load_controls!
    end

    attr_reader :adapter

    def process(event)
      supplied = stringify_keys(event)
      type = supplied.fetch('type').to_s
      case type
      when 'key_down'
        key = supplied.fetch('key').to_s.upcase
        newly_pressed = !@pressed.include?(key)
        @pressed.add(key)
        @jump_requested = true if newly_pressed && @platform_jump && key == @platform_jump.fetch('key')
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
        time_ms = integer_time(supplied['time_ms'])
        @platform_mode ? emit_platform_movement(time_ms, supplied) : emit_movement(time_ms)
      else
        raise GameInputError, "Unknown input event '#{type}'."
      end
      @adapter.drain
    end

    private

    def load_controls!
      declarations = Array(@document['controls'])
      raise GameInputError, 'This BASIC# program does not declare CONTROLS for PLAYER.' if declarations.empty?
      @key_directions = {}
      @face_pointer = false
      @right_mouse_move = false
      @platform_directions = {}
      @platform_jump = nil
      declarations.each do |declaration|
        Array(declaration['instructions']).each do |instruction|
          case instruction['type']
          when 'key_move' then @key_directions[instruction.fetch('key')] = instruction.fetch('direction')
          when 'face_pointer' then @face_pointer = true
          when 'right_mouse_move' then @right_mouse_move = true
          when 'platform_move' then @platform_directions[instruction.fetch('direction')] = instruction
          when 'platform_jump' then @platform_jump = instruction
          end
        end
      end
      @platform_mode = !@platform_directions.empty? || !@platform_jump.nil?
      return validate_platform_controls! if @platform_mode

      speed_fact = Array(@document['facts']).find do |fact|
        fact.dig('subject', 'name') == 'player' && fact['relation'] == 'has' && fact['value_name'] == 'speed'
      end
      @speed = speed_fact && speed_fact['amount']
      unless @speed.is_a?(Numeric) && @speed.finite? && @speed.positive?
        raise GameInputError, 'PLAYER must possess a positive numeric speed in START.'
      end
    end

    def validate_platform_controls!
      unless @key_directions.empty? && !@face_pointer && !@right_mouse_move
        raise GameInputError, 'Platform CONTROLS cannot be mixed with top-down CONTROLS.'
      end
      %w[left right].each do |direction|
        instruction = @platform_directions[direction]
        raise GameInputError, "Platform CONTROLS must declare PLAYER #{direction} movement." unless instruction
        validate_positive_speed!(instruction['speed'], "PLAYER #{direction} speed")
      end
      raise GameInputError, 'Platform CONTROLS must declare PLAYER jump movement.' unless @platform_jump
      validate_positive_speed!(@platform_jump['speed'], 'PLAYER jump speed')
    end

    def validate_positive_speed!(value, label)
      unless value.is_a?(Numeric) && value.finite? && value.positive?
        raise GameInputError, "#{label} must be a positive number."
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

    def emit_platform_movement(time_ms, frame)
      delta_ms = frame_delta_ms(time_ms)
      grounded = truth_value(frame['grounded'])
      hit_left = truth_value(frame['hit_left'])
      hit_right = truth_value(frame['hit_right'])
      hit_ceiling = truth_value(frame['hit_ceiling'])

      @vertical_velocity = 0.0 if grounded
      @vertical_velocity = 0.0 if hit_ceiling && @vertical_velocity.negative?
      if @jump_requested
        @vertical_velocity = -numeric(@platform_jump.fetch('speed'), 'PLAYER jump speed') if grounded
        @jump_requested = false
      end

      delta_seconds = delta_ms / 1000.0
      @vertical_velocity += PLATFORM_GRAVITY * delta_seconds unless grounded && @vertical_velocity >= 0.0

      left = @pressed.include?(@platform_directions.fetch('left').fetch('key'))
      right = @pressed.include?(@platform_directions.fetch('right').fetch('key'))
      horizontal = if left == right
                     0.0
                   elsif left
                     -numeric(@platform_directions.fetch('left').fetch('speed'), 'PLAYER left speed')
                   else
                     numeric(@platform_directions.fetch('right').fetch('speed'), 'PLAYER right speed')
                   end
      horizontal = 0.0 if (horizontal.negative? && hit_left) || (horizontal.positive? && hit_right)

      @adapter.emit(
        'move_with_collisions',
        'subject' => 'player',
        'velocity_x' => rounded(horizontal),
        'velocity_y' => rounded(@vertical_velocity),
        'delta_seconds' => rounded(delta_seconds),
        'gravity' => PLATFORM_GRAVITY,
        'grounded' => grounded
      )
    end

    def frame_delta_ms(time_ms)
      if @last_frame_at && time_ms < @last_frame_at
        raise GameInputError, 'frame time_ms cannot move backward.'
      end
      elapsed = @last_frame_at ? time_ms - @last_frame_at : 0
      @last_frame_at = time_ms
      [elapsed, MAX_FRAME_MS].min
    end

    def truth_value(value)
      return value if value == true || value == false
      return false if value.nil?
      raise GameInputError, 'Collision facts such as grounded must be true or false.'
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

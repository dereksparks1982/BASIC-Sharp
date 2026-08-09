# frozen_string_literal: true

require 'set'
require_relative 'host_adapter'

module BasicSharp
  class GameInputError < ArgumentError; end

  class GameInput
    HOLD_THRESHOLD_MS = 200
    PLATFORM_GRAVITY = 30.0
    MAX_FRAME_MS = 250
    AXIS_THRESHOLD = 0.5
    DIAGONAL = 1.0 / Math.sqrt(2.0)
    DIRECTIONS = {
      'north' => [0.0, -1.0],
      'south' => [0.0, 1.0],
      'west' => [-1.0, 0.0],
      'east' => [1.0, 0.0]
    }.freeze
    KEYBOARD_ACTIONS = {
      'W' => 'north',
      'UP' => 'north',
      'ARROWUP' => 'north',
      'UP_ARROW' => 'north',
      'S' => 'south',
      'DOWN' => 'south',
      'ARROWDOWN' => 'south',
      'DOWN_ARROW' => 'south',
      'A' => 'west',
      'LEFT' => 'west',
      'ARROWLEFT' => 'west',
      'LEFT_ARROW' => 'west',
      'D' => 'east',
      'RIGHT' => 'east',
      'ARROWRIGHT' => 'east',
      'RIGHT_ARROW' => 'east',
      'SPACE' => 'jump',
      'SPACEBAR' => 'jump',
      'E' => 'interact',
      'ENTER' => 'interact',
      'RETURN' => 'interact',
      'J' => 'attack',
      'F' => 'attack',
      'CTRL' => 'attack',
      'CONTROL' => 'attack',
      'LEFT_CTRL' => 'attack',
      'ESC' => 'pause',
      'ESCAPE' => 'pause',
      'P' => 'pause'
    }.freeze
    LOGICAL_ACTIONS = %w[jump attack interact pause].freeze
    MOUSE_ACTIONS = {
      'LEFT' => 'attack',
      'LEFT_BUTTON' => 'attack',
      'LEFT_MOUSE' => 'attack'
    }.freeze
    BUTTON_ACTIONS = {
      'ps5' => {
        'DPAD_UP' => 'north',
        'DPAD_DOWN' => 'south',
        'DPAD_LEFT' => 'west',
        'DPAD_RIGHT' => 'east',
        'LEFT_STICK_UP' => 'north',
        'LEFT_STICK_DOWN' => 'south',
        'LEFT_STICK_LEFT' => 'west',
        'LEFT_STICK_RIGHT' => 'east',
        'CROSS' => 'jump',
        'SQUARE' => 'attack',
        'R2' => 'attack',
        'RIGHT_TRIGGER' => 'attack',
        'TRIANGLE' => 'interact',
        'OPTIONS' => 'pause',
        'START' => 'pause'
      },
      'xbox' => {
        'DPAD_UP' => 'north',
        'DPAD_DOWN' => 'south',
        'DPAD_LEFT' => 'west',
        'DPAD_RIGHT' => 'east',
        'LEFT_STICK_UP' => 'north',
        'LEFT_STICK_DOWN' => 'south',
        'LEFT_STICK_LEFT' => 'west',
        'LEFT_STICK_RIGHT' => 'east',
        'A' => 'jump',
        'X' => 'attack',
        'RT' => 'attack',
        'RIGHT_TRIGGER' => 'attack',
        'Y' => 'interact',
        'MENU' => 'pause',
        'START' => 'pause'
      },
      'generic_gamepad' => {
        'DPAD_UP' => 'north',
        'DPAD_DOWN' => 'south',
        'DPAD_LEFT' => 'west',
        'DPAD_RIGHT' => 'east',
        'LEFT_STICK_UP' => 'north',
        'LEFT_STICK_DOWN' => 'south',
        'LEFT_STICK_LEFT' => 'west',
        'LEFT_STICK_RIGHT' => 'east',
        'BUTTON_SOUTH' => 'jump',
        'BUTTON_WEST' => 'attack',
        'RIGHT_TRIGGER' => 'attack',
        'BUTTON_NORTH' => 'interact',
        'START' => 'pause'
      }
    }.freeze
    AXIS_ACTIONS = {
      'LEFT_X' => { negative: 'west', positive: 'east' },
      'LX' => { negative: 'west', positive: 'east' },
      'LEFT_Y' => { negative: 'north', positive: 'south' },
      'LY' => { negative: 'north', positive: 'south' }
    }.freeze

    def initialize(document, adapter: HostAdapter.new)
      @document = stringify_keys(document.respond_to?(:to_h) ? document.to_h : document)
      @adapter = adapter
      @pressed = Set.new
      @action_sources = Hash.new { |hash, key| hash[key] = Set.new }
      @axis_actions = {}
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
        key = normalized_key(supplied.fetch('key'))
        newly_pressed = !@pressed.include?(key)
        @pressed.add(key)
        action = KEYBOARD_ACTIONS[key]
        add_action_source(action, "keyboard:#{key}", newly_pressed)
        emit_logical_action(action, "keyboard:#{key}") if newly_pressed
        @jump_requested = true if newly_pressed && @platform_jump && key == @platform_jump.fetch('key')
      when 'key_up'
        key = normalized_key(supplied.fetch('key'))
        @pressed.delete(key)
        remove_action_source(KEYBOARD_ACTIONS[key], "keyboard:#{key}")
      when 'button_down'
        action = button_action(supplied)
        source = button_source(supplied)
        add_action_source(action, source, true)
        emit_logical_action(action, source)
      when 'button_up'
        remove_action_source(button_action(supplied), button_source(supplied))
      when 'axis'
        process_axis(supplied)
      when 'pointer_move'
        %w[x y distance maximum_distance].each do |name|
          @pointer[name] = numeric(supplied[name], name) if supplied.key?(name)
        end
        emit_facing if @face_pointer
      when 'mouse_down'
        button = normalized_button(supplied.fetch('button'))
        emit_logical_action(MOUSE_ACTIONS[button], "mouse:#{button}")
      when 'mouse_up'
        # Reserved for host symmetry. Logical actions are edge-triggered on mouse_down.
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
        if @world_mode
          emit_world_movement(time_ms)
        elsif @platform_mode
          emit_platform_movement(time_ms, supplied)
        else
          emit_movement(time_ms)
        end
      else
        raise GameInputError, "Unknown input event '#{type}'."
      end
      @adapter.drain
    end

    private

    def normalized_key(value)
      value.to_s.upcase.tr(' -', '_')
    end

    def normalized_device(value)
      value.to_s.downcase.tr(' -', '_')
    end

    def normalized_button(value)
      value.to_s.upcase.tr(' -', '_')
    end

    def button_action(event)
      device = normalized_device(event['device'] || 'generic_gamepad')
      button = normalized_button(event.fetch('button'))
      BUTTON_ACTIONS.fetch(device) do
        raise GameInputError, "Unknown input device '#{device}'."
      end.fetch(button) do
        raise GameInputError, "Unknown #{device} button '#{button}'."
      end
    end

    def button_source(event)
      "button:#{normalized_device(event['device'] || 'generic_gamepad')}:#{normalized_button(event.fetch('button'))}"
    end

    def process_axis(event)
      device = normalized_device(event['device'] || 'generic_gamepad')
      axis = normalized_button(event.fetch('axis'))
      mapping = AXIS_ACTIONS.fetch(axis) do
        raise GameInputError, "Unknown #{device} axis '#{axis}'."
      end
      source = "axis:#{device}:#{axis}"
      old_action = @axis_actions[source]
      remove_action_source(old_action, source) if old_action

      value = numeric(event.fetch('value'), axis)
      new_action = if value <= -AXIS_THRESHOLD
                     mapping.fetch(:negative)
                   elsif value >= AXIS_THRESHOLD
                     mapping.fetch(:positive)
                   end
      @axis_actions[source] = new_action
      add_action_source(new_action, source, old_action != new_action) if new_action
    end

    def add_action_source(action, source, newly_pressed)
      return unless action

      previous_empty = @action_sources[action].empty?
      @action_sources[action].add(source)
      @jump_requested = true if action == 'jump' && newly_pressed && previous_empty
    end

    def remove_action_source(action, source)
      return unless action

      @action_sources[action].delete(source)
    end

    def action_active?(action)
      @action_sources[action] && !@action_sources[action].empty?
    end

    def emit_logical_action(action, source)
      return unless action && LOGICAL_ACTIONS.include?(action) && @enabled_actions.include?(action)

      @adapter.emit('input_action', 'subject' => 'player', 'action' => action, 'source' => source)
    end

    def directional_actions
      actions = Set.new
      %w[north south west east].each { |action| actions.add(action) if action_active?(action) }
      actions
    end

    def platform_left_active?
      @pressed.include?(@platform_directions.fetch('left').fetch('key')) || action_active?('west')
    end

    def platform_right_active?
      @pressed.include?(@platform_directions.fetch('right').fetch('key')) || action_active?('east')
    end

    def load_controls!
      declarations = Array(@document['controls'])
      raise GameInputError, 'This BASIC# program does not declare CONTROLS for PLAYER.' if declarations.empty?
      @key_directions = {}
      @face_pointer = false
      @right_mouse_move = false
      @platform_directions = {}
      @platform_jump = nil
      @world_directions = {}
      @enabled_actions = Set.new
      declarations.each do |declaration|
        Array(declaration['instructions']).each do |instruction|
          case instruction['type']
          when 'key_move' then @key_directions[instruction.fetch('key')] = instruction.fetch('direction')
          when 'face_pointer' then @face_pointer = true
          when 'right_mouse_move' then @right_mouse_move = true
          when 'platform_move' then @platform_directions[instruction.fetch('direction')] = instruction
          when 'platform_jump' then @platform_jump = instruction
          when 'world_move' then @world_directions[instruction.fetch('direction')] = instruction
          when 'input_action' then @enabled_actions.add(instruction.fetch('action'))
          end
        end
      end
      @world_mode = !@world_directions.empty?
      return validate_world_controls! if @world_mode

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

    def validate_world_controls!
      unless @key_directions.empty? && !@face_pointer && !@right_mouse_move && @platform_jump.nil? && @platform_directions.empty?
        raise GameInputError, '3D CONTROLS cannot be mixed with top-down or platform CONTROLS.'
      end
      %w[forward backward left right].each do |direction|
        instruction = @world_directions[direction]
        raise GameInputError, "3D CONTROLS must declare PLAYER #{direction} movement." unless instruction
        validate_positive_speed!(instruction['speed'], "PLAYER #{direction} speed")
      end
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
      active_directions = directional_actions
      @pressed.each do |key|
        direction = @key_directions[key]
        active_directions.add(direction) if direction
      end
      active_directions.each do |direction|
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

    def emit_world_movement(time_ms)
      x = 0.0
      z = 0.0
      x -= numeric(@world_directions.fetch('left').fetch('speed'), 'PLAYER left speed') if world_direction_active?('left')
      x += numeric(@world_directions.fetch('right').fetch('speed'), 'PLAYER right speed') if world_direction_active?('right')
      z += numeric(@world_directions.fetch('forward').fetch('speed'), 'PLAYER forward speed') if world_direction_active?('forward')
      z -= numeric(@world_directions.fetch('backward').fetch('speed'), 'PLAYER backward speed') if world_direction_active?('backward')
      if x != 0.0 && z != 0.0
        x *= DIAGONAL
        z *= DIAGONAL
      end
      @adapter.emit(
        'move_3d',
        'subject' => 'player',
        'velocity_x' => rounded(x),
        'velocity_z' => rounded(z),
        'x' => rounded(x.zero? ? 0.0 : x / [x.abs, z.abs].max),
        'z' => rounded(z.zero? ? 0.0 : z / [x.abs, z.abs].max)
      )
    end

    def world_direction_active?(direction)
      instruction = @world_directions.fetch(direction)
      return true if @pressed.include?(instruction.fetch('key'))

      aliases = {
        'forward' => %w[north],
        'backward' => %w[south],
        'left' => %w[west],
        'right' => %w[east]
      }.fetch(direction)
      aliases.any? { |action| action_active?(action) }
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

      left = platform_left_active?
      right = platform_right_active?
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

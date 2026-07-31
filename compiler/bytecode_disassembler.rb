# frozen_string_literal: true

module BasicSharp
  class BytecodeDisassembler
    def initialize(model)
      @model = model
      pair = [@model.fetch(:profile), @model.fetch(:meaning_profile)]
      supported = [
        [BytecodeContract::PROFILE, BytecodeContract::MEANING_PROFILE],
        [BytecodeContract::PROFILE_2, BytecodeContract::MEANING_PROFILE_2]
      ]
      raise ArgumentError, 'BSharp Bytecode disassembly requires a supported profile pair.' unless supported.include?(pair)
    end

    def render
      lines = []
      lines << "BSharp Bytecode #{@model.fetch(:profile)}"
      lines << "Meaning Profile: #{@model.fetch(:meaning_profile)}"
      lines << "Fingerprint: #{@model.fetch(:fingerprint)}"
      lines << ''

      @model.fetch(:kinds).each_with_index do |kind, index|
        parent = kind[:parent_index] == BytecodeContract::NO_REFERENCE_U32 ? 'NONE' : "KIND[#{@model.fetch(:kinds).fetch(kind[:parent_index]).fetch(:name)}]"
        lines << "KIND #{index} #{kind.fetch(:name)} PARENT #{parent}"
      end
      lines << '' unless @model.fetch(:kinds).empty?

      @model.fetch(:things).each_with_index do |thing, index|
        lines << "THING #{index} #{thing.fetch(:name)} KIND[#{@model.fetch(:kinds).fetch(thing.fetch(:kind_index)).fetch(:name)}]"
      end
      lines << '' unless @model.fetch(:things).empty?

      lines << 'START'
      @model.fetch(:start_records).each { |instruction| lines << "    #{render_instruction(instruction)}" }
      lines << 'END'
      lines << ''

      @model.fetch(:events).each do |event|
        lines << [
          'WHEN',
          "actor=#{render_selector(event.fetch(:actor_selector), event.fetch(:actor_reference))}",
          "action=#{event.fetch(:action)}",
          "target=#{render_selector(event.fetch(:target_selector), event.fetch(:target_reference))}",
          "BLOCK #{event.fetch(:block_index)}"
        ].join(' ')
      end
      lines << '' unless @model.fetch(:events).empty?

      @model.fetch(:if_rules).each do |rule|
        lines << "IF #{render_condition(rule.fetch(:condition))} BLOCK #{rule.fetch(:block_index)}"
      end
      lines << '' unless @model.fetch(:if_rules).empty?

      @model.fetch(:blocks).each do |block|
        lines << "BLOCK #{block.fetch(:id)}"
        block.fetch(:instructions).each { |instruction| lines << "    #{render_instruction(instruction)}" }
        lines << 'END'
        lines << ''
      end

      "#{lines.join("\n").rstrip}\n"
    end

    private

    def render_instruction(instruction)
      name = instruction.fetch(:name)
      values = instruction.fetch(:display)
      ([name] + values).join(' ')
    end

    def render_condition(condition)
      ([condition.fetch(:name)] + condition.fetch(:display)).join(' ')
    end

    def render_selector(selector, reference)
      case selector
      when 'EXACT_THING'
        "THING[#{@model.fetch(:things).fetch(reference).fetch(:name)}]"
      when 'ONE_KIND'
        "ONE_KIND[#{@model.fetch(:kinds).fetch(reference).fetch(:name)}]"
      when 'BOUND_THAT_KIND'
        "BOUND_THAT_KIND[#{@model.fetch(:kinds).fetch(reference).fetch(:name)}]"
      when 'EVERY_KIND'
        "EVERY_KIND[#{@model.fetch(:kinds).fetch(reference).fetch(:name)}]"
      when 'NO_REFERENCE'
        'NONE'
      else
        raise BytecodeEmitterError, "Unknown selector for disassembly: #{selector}"
      end
    end
  end
end

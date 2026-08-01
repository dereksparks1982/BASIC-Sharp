# frozen_string_literal: true

require 'digest'
require 'fileutils'
require 'json'
require 'tempfile'
require_relative 'bytecode_contract'
require_relative 'bytecode_disassembler'
require_relative 'dictionary'
require_relative 'meaning_profile'
require_relative 'text_literal'
require_relative 'world_save'

module BasicSharp
  class BytecodeEmitterError < ArgumentError; end

  class BytecodeEmitter
    PROFILE_FORMAT_VERSION = 1
    PROFILE_FORMAT_VERSION_2 = 2
    PROFILE_FORMAT_VERSION_3 = 3
    PROFILE_FORMAT_VERSION_4 = 4
    MANDATORY_STRINGS = [
      BytecodeContract::PROFILE,
      BytecodeContract::MEANING_PROFILE,
      WorldSave::FINGERPRINT_ALGORITHM
    ].freeze
    OPPOSITE_STATES = {
      'open' => 'closed', 'closed' => 'open',
      'locked' => 'unlocked', 'unlocked' => 'locked',
      'alive' => 'dead', 'dead' => 'alive',
      'calm' => 'angry', 'angry' => 'calm',
      'friendly' => 'hostile', 'hostile' => 'friendly',
      'visible' => 'hidden', 'hidden' => 'visible',
      'carried' => 'dropped', 'dropped' => 'carried',
      'broken' => 'whole', 'whole' => 'broken',
      'on' => 'off', 'off' => 'on'
    }.freeze
    FORBIDDEN_BINARY_TERMS = %w[BasicSharp RubyVM ObjectSpace Marshal].freeze

    attr_reader :model, :profile

    def initialize(document)
      @document = stringify_keys(document.respond_to?(:to_h) ? document.to_h : document)
      validate_document!
      @profile = case @document['meaning_profile']
                 when BytecodeContract::MEANING_PROFILE_4 then BytecodeContract::PROFILE_4
                 when BytecodeContract::MEANING_PROFILE_3 then BytecodeContract::PROFILE_3
                 when BytecodeContract::MEANING_PROFILE_2 then BytecodeContract::PROFILE_2
                 else BytecodeContract::PROFILE
                 end
      @meaning_profile = {
        BytecodeContract::PROFILE => BytecodeContract::MEANING_PROFILE,
        BytecodeContract::PROFILE_2 => BytecodeContract::MEANING_PROFILE_2,
        BytecodeContract::PROFILE_3 => BytecodeContract::MEANING_PROFILE_3,
        BytecodeContract::PROFILE_4 => BytecodeContract::MEANING_PROFILE_4
      }.fetch(@profile)
      @fingerprint_algorithm = {
        BytecodeContract::PROFILE => WorldSave::FINGERPRINT_ALGORITHM,
        BytecodeContract::PROFILE_2 => WorldSave::FINGERPRINT_ALGORITHM_2,
        BytecodeContract::PROFILE_3 => WorldSave::FINGERPRINT_ALGORITHM_3,
        BytecodeContract::PROFILE_4 => WorldSave::FINGERPRINT_ALGORITHM_4
      }.fetch(@profile)
      @profile_format_version = {
        BytecodeContract::PROFILE => PROFILE_FORMAT_VERSION,
        BytecodeContract::PROFILE_2 => PROFILE_FORMAT_VERSION_2,
        BytecodeContract::PROFILE_3 => PROFILE_FORMAT_VERSION_3,
        BytecodeContract::PROFILE_4 => PROFILE_FORMAT_VERSION_4
      }.fetch(@profile)
      @instruction_codes = BytecodeContract.instruction_codes(@profile)
      @condition_codes = BytecodeContract.condition_codes(@profile)
      @strings = []
      @string_indexes = {}
      @string_roles = []
      [@profile, @meaning_profile, @fingerprint_algorithm].each { |value| intern(value, role: :identifier) }
      @model = build_model
    end

    def binary
      @binary ||= build_binary
    end

    def disassembly
      @disassembly ||= BytecodeDisassembler.new(model).render
    end

    def write(path)
      destination = File.expand_path(path)
      unless destination.end_with?(BytecodeContract::EXTENSION)
        raise BytecodeEmitterError, "BSharp Bytecode output must end with #{BytecodeContract::EXTENSION}."
      end
      disassembly_path = "#{destination}.txt"
      atomic_write_pair(destination, binary, disassembly_path, disassembly)
      [destination, disassembly_path]
    end

    def fingerprint
      model.fetch(:fingerprint)
    end

    private

    def validate_document!
      unless @document.is_a?(Hash) && @document['format'].to_s == 'bsir.debug.json'
        raise BytecodeEmitterError, 'BSharp Bytecode emission requires resolved BSharp IR.'
      end
      diagnostics = Array(@document['diagnostics'])
      errors = diagnostics.select { |entry| diagnostic_severity(entry) == 'error' }
      warnings = diagnostics.select { |entry| diagnostic_severity(entry) == 'warning' }
      unless errors.empty?
        raise BytecodeEmitterError, "BSharp Bytecode was not written because the program has #{errors.length} error#{errors.length == 1 ? '' : 's'}."
      end
      unless warnings.empty?
        raise BytecodeEmitterError, "BSharp Bytecode was not written because the program has #{warnings.length} warning#{warnings.length == 1 ? '' : 's'}."
      end
      profile = @document['meaning_profile']
      unless profile.nil? || [BytecodeContract::MEANING_PROFILE, BytecodeContract::MEANING_PROFILE_2, BytecodeContract::MEANING_PROFILE_3, BytecodeContract::MEANING_PROFILE_4].include?(profile)
        raise BytecodeEmitterError, "BSharp Bytecode does not support meaning profile '#{profile}'."
      end
      text_used = document_uses_text_values?
      if text_used && ![BytecodeContract::MEANING_PROFILE_2, BytecodeContract::MEANING_PROFILE_3, BytecodeContract::MEANING_PROFILE_4].include?(profile)
        raise BytecodeEmitterError, 'Creator-facing text values require bsharp.meaning.v2 or later in BSharp IR.'
      end
      if profile == BytecodeContract::MEANING_PROFILE_2 && !text_used
        raise BytecodeEmitterError, 'bsharp.meaning.v2 requires at least one creator-facing text value.'
      end
      game_used = Array(@document['controls']).any? || Array(@document['hover_declarations']).any? || Array(@document['context_declarations']).any?
      if profile == BytecodeContract::MEANING_PROFILE_3 && !game_used
        raise BytecodeEmitterError, 'bsharp.meaning.v3 requires game input or interaction meaning.'
      end
      platform_used = Array(@document['controls']).any? do |declaration|
        Array(declaration['instructions']).any? { |instruction| instruction['type'].to_s.start_with?('platform_') }
      end
      if profile == BytecodeContract::MEANING_PROFILE_4 && !platform_used
        raise BytecodeEmitterError, 'bsharp.meaning.v4 requires platform movement meaning.'
      end
    end

    def diagnostic_severity(entry)
      entry.respond_to?(:severity) ? entry.severity.to_s : stringify_keys(entry)['severity'].to_s
    end

    def build_model
      kind_rows = build_kinds
      thing_rows = build_things(kind_rows)
      start_records = Array(@document['facts']).map { |fact| lower_start(fact) }

      # String interning follows the required section-semantic traversal:
      # KIND, THNG, STRT, EVNT, IFRL, then CODE.
      events = Array(@document['events']).each_with_index.map { |event, index| lower_event(event, index) }
      event_count = events.length
      if_rules = Array(@document['if_rules']).each_with_index.map do |rule, index|
        lower_if_rule(rule, event_count + index)
      end
      event_blocks = Array(@document['events']).map { |event| lower_actions(event.fetch('then')) }
      if_blocks = Array(@document['if_rules']).map { |rule| lower_actions(rule.fetch('then')) }
      blocks = (event_blocks + if_blocks).each_with_index.map do |instructions, index|
        { id: index, instructions: instructions }
      end

      {
        profile: @profile,
        meaning_profile: @meaning_profile,
        fingerprint_algorithm: @fingerprint_algorithm,
        fingerprint: WorldSave.program_fingerprint(@document),
        strings: @strings,
        string_roles: @string_roles,
        kinds: kind_rows,
        things: thing_rows,
        start_records: start_records,
        events: events,
        if_rules: if_rules,
        blocks: blocks,
        controls: canonical_game_data(Array(@document['controls'])),
        hover_declarations: canonical_game_data(Array(@document['hover_declarations'])),
        context_declarations: canonical_game_data(Array(@document['context_declarations']))
      }
    end

    def build_kinds
      @kind_parent_names = {}
      Array(@document['kinds']).each do |entry|
        @kind_parent_names[normalize(entry['name'])] = normalize(entry['parent'])
      end
      @kind_names = []
      @kind_indexes = {}

      semantic_kind_references.each { |name| add_kind_with_ancestors(name) }

      @kind_names.each_with_index.map do |name, index|
        parent = @kind_parent_names[name]
        {
          name: name,
          name_string_index: intern(name),
          parent_index: parent && !parent.empty? ? @kind_indexes.fetch(parent) : BytecodeContract::NO_REFERENCE_U32,
          source_order: index
        }
      end
    end

    def semantic_kind_references
      references = []
      Array(@document['kinds']).each do |entry|
        references << normalize(entry['parent'])
        references << normalize(entry['name'])
      end
      Array(@document['objects']).each { |entry| references << normalize(entry['kind']) }
      Array(@document['events']).each do |event|
        collect_reference_kind(event.dig('when', 'actor'), references)
        collect_reference_kind(event.dig('when', 'target'), references)
        Array(event['then']).each { |action| collect_action_kinds(action, references) }
      end
      Array(@document['if_rules']).each do |rule|
        Array(rule['then']).each { |action| collect_action_kinds(action, references) }
      end
      Array(@document['hover_declarations']).each { |entry| collect_reference_kind(entry['subject'], references) }
      Array(@document['context_declarations']).each { |entry| collect_reference_kind(entry['subject'], references) }
      references.reject(&:empty?)
    end

    def collect_action_kinds(action, references)
      collect_reference_kind(action['target'], references)
      event = action['event']
      return unless event

      collect_reference_kind(event['actor'], references)
      collect_reference_kind(event['target'], references)
    end

    def collect_reference_kind(reference, references)
      return unless reference.is_a?(Hash)

      kind_name = normalize(reference['kind_name'] || reference['object_kind'])
      references << kind_name unless kind_name.empty?
    end

    def add_kind_with_ancestors(name, visiting = {})
      normalized = normalize(name)
      return if normalized.empty? || @kind_indexes.key?(normalized)
      raise BytecodeEmitterError, "BSharp Bytecode cannot encode a Kind ancestry circle involving '#{normalized}'." if visiting[normalized]

      visiting[normalized] = true
      parent = @kind_parent_names[normalized]
      add_kind_with_ancestors(parent, visiting) if parent && !parent.empty?
      visiting.delete(normalized)
      @kind_indexes[normalized] = @kind_names.length
      @kind_names << normalized
    end

    def build_things(_kind_rows)
      @thing_indexes = {}
      Array(@document['objects']).each_with_index.map do |entry, index|
        name = normalize(entry['name'])
        raise BytecodeEmitterError, "Duplicate Thing '#{name}' cannot be emitted." if @thing_indexes.key?(name)

        @thing_indexes[name] = index
        kind_name = normalize(entry['kind'])
        {
          name: name,
          name_string_index: intern(name),
          kind_index: @kind_indexes.fetch(kind_name) { raise BytecodeEmitterError, "Thing '#{name}' uses missing Kind '#{kind_name}'." },
          definition_order: index
        }
      end
    end

    def lower_start(fact)
      relation = normalize(fact['relation'])
      subject = exact_thing_index(fact.fetch('subject'))
      case relation
      when 'is'
        state = normalize(fact.dig('value', 'name'))
        instruction('START_STATE', [subject, intern(state), optional_string_index(OPPOSITE_STATES[state])], ["THING[#{thing_name(subject)}]", state, remove_display(OPPOSITE_STATES[state])])
      when 'has'
        value_name = normalize(fact['value_name'])
        if fact.key?('text_value')
          raise BytecodeEmitterError, 'damage is a whole-number value and cannot store text.' if value_name == 'damage'
          text = text_value(fact['text_value'], 'START text value')
          instruction('START_TEXT_VALUE', [subject, intern(value_name), intern(text, role: :literal)], ["THING[#{thing_name(subject)}]", value_name, quote_text(text)])
        else
          amount = whole_number(fact['amount'], 'START value')
          instruction('START_VALUE', [subject, intern(value_name), amount], ["THING[#{thing_name(subject)}]", value_name, amount.to_s])
        end
      else
        target = exact_thing_index(fact.fetch('target'))
        instruction('START_RELATION', [subject, intern(relation), target], ["THING[#{thing_name(subject)}]", relation, "THING[#{thing_name(target)}]"])
      end
    rescue KeyError => error
      raise BytecodeEmitterError, "BSharp Bytecode cannot lower a START fact: #{error.message}"
    end

    def lower_event(event, block_index)
      actor_selector, actor_reference = lower_selector(event.dig('when', 'actor'), :event)
      target_selector, target_reference = lower_selector(event.dig('when', 'target'), :event, optional: true)
      {
        actor_selector: actor_selector,
        actor_reference: actor_reference,
        action: normalize(event.dig('when', 'action')),
        action_string_index: intern(normalize(event.dig('when', 'action'))),
        target_selector: target_selector,
        target_reference: target_reference,
        block_index: block_index,
        source_order: block_index
      }
    end

    def lower_if_rule(rule, block_index)
      condition = lower_condition(rule.fetch('if'))
      {
        condition: condition,
        block_index: block_index,
        source_order: block_index - Array(@document['events']).length
      }
    end

    def lower_condition(condition)
      relation = normalize(condition['relation'])
      subject = exact_thing_index(condition.fetch('subject'))
      case relation
      when 'is'
        state = normalize(condition.dig('value', 'name'))
        condition_record('STATE_IS', [subject, intern(state)], ["THING[#{thing_name(subject)}]", state])
      when 'isnt'
        state = normalize(condition.dig('value', 'name'))
        condition_record('STATE_ISNT', [subject, intern(state)], ["THING[#{thing_name(subject)}]", state])
      when 'has'
        name = normalize(condition['value_name'])
        if condition.key?('text_value')
          text = text_value(condition['text_value'], 'IF text value')
          condition_record('TEXT_VALUE_EQUALS', [subject, intern(name), intern(text, role: :literal)], ["THING[#{thing_name(subject)}]", name, quote_text(text)])
        else
          amount = whole_number(condition['amount'], 'IF value')
          condition_record('VALUE_EQUALS', [subject, intern(name), amount], ["THING[#{thing_name(subject)}]", name, amount.to_s])
        end
      else
        target = exact_thing_index(condition.fetch('target'))
        condition_record('RELATION_EXISTS', [subject, intern(relation), target], ["THING[#{thing_name(subject)}]", relation, "THING[#{thing_name(target)}]"])
      end
    rescue KeyError => error
      raise BytecodeEmitterError, "BSharp Bytecode cannot lower an IF condition: #{error.message}"
    end

    def lower_actions(actions)
      Array(actions).map { |action| lower_action(action) }
    end

    def lower_action(action)
      name = normalize(action['action'])
      case name
      when 'damage'
        selector, reference = lower_selector(action.fetch('target'), :action)
        amount = whole_number(action.fetch('amount', 1), 'damage amount', minimum: 1)
        instruction('DAMAGE', [selector_code(selector), reference, amount], [render_selector(selector, reference), amount.to_s])
      when 'change'
        selector, reference = lower_selector(action.fetch('target'), :action)
        if action.key?('value_name')
          value_name = normalize(action['value_name'])
          if action.key?('to_text')
            text = text_value(action['to_text'], 'text value change')
            instruction('CHANGE_TEXT_VALUE', [selector_code(selector), reference, intern(value_name), intern(text, role: :literal)], [render_selector(selector, reference), value_name, quote_text(text)])
          else
            amount = whole_number(action['to_amount'], 'exact value')
            instruction('CHANGE_VALUE', [selector_code(selector), reference, intern(value_name), amount], [render_selector(selector, reference), value_name, amount.to_s])
          end
        else
          state = normalize(action.dig('to', 'name'))
          raise BytecodeEmitterError, 'BSharp Bytecode cannot lower a state change without a state.' if state.empty?

          opposite = OPPOSITE_STATES[state]
          instruction('CHANGE_STATE', [selector_code(selector), reference, intern(state), optional_string_index(opposite)], [render_selector(selector, reference), state, remove_display(opposite)])
        end
      when 'carry'
        selector, reference = lower_selector(action.fetch('target'), :action)
        instruction('CARRY', [selector_code(selector), reference], [render_selector(selector, reference)])
      when 'unlock'
        selector, reference = lower_selector(action.fetch('target'), :action)
        instruction('UNLOCK', [selector_code(selector), reference], [render_selector(selector, reference)])
      when 'cause'
        caused = action.fetch('event')
        actor_selector, actor_reference = lower_selector(caused['actor'], :caused_event)
        target_selector, target_reference = lower_selector(caused['target'], :caused_event, optional: true)
        event_action = normalize(caused['action'])
        instruction(
          'CAUSE_EVENT',
          [selector_code(actor_selector), actor_reference, intern(event_action), selector_code(target_selector), target_reference],
          [render_selector(actor_selector, actor_reference), event_action, render_selector(target_selector, target_reference)]
        )
      else
        raise BytecodeEmitterError, "BSharp Bytecode Profile 1 does not support action '#{name}'."
      end
    rescue KeyError => error
      raise BytecodeEmitterError, "BSharp Bytecode cannot lower action '#{name}': #{error.message}"
    end

    def lower_selector(reference, context, optional: false)
      if reference.nil?
        return ['NO_REFERENCE', BytecodeContract::NO_REFERENCE_U32] if optional
        raise BytecodeEmitterError, "BSharp Bytecode requires a reference in #{context}."
      end

      type = normalize(reference['type'])
      case type
      when 'object'
        ['EXACT_THING', exact_thing_index(reference)]
      when 'kind_one', 'kind'
        ['ONE_KIND', kind_index(reference)]
      when 'previous'
        ['BOUND_THAT_KIND', kind_index(reference)]
      when 'kind_set'
        ['EVERY_KIND', kind_index(reference)]
      else
        raise BytecodeEmitterError, "BSharp Bytecode cannot encode reference type '#{type}' in #{context}."
      end
    end

    def kind_index(reference)
      name = normalize(reference['kind_name'] || reference['object_kind'])
      @kind_indexes.fetch(name) { raise BytecodeEmitterError, "BSharp Bytecode reference uses missing Kind '#{name}'." }
    end

    def exact_thing_index(reference)
      name = normalize(reference['name'] || reference['text'])
      @thing_indexes.fetch(name) { raise BytecodeEmitterError, "BSharp Bytecode reference uses missing Thing '#{name}'." }
    end

    def instruction(name, operands, display)
      expected = instruction_operand_count(name)
      raise BytecodeEmitterError, "#{name} requires #{expected} operands, got #{operands.length}." unless operands.length == expected
      operands.each { |operand| u32(operand) }
      { name: name, opcode: @instruction_codes.fetch(name), operands: operands, display: display.reject(&:empty?) }
    end

    def condition_record(name, operands, display)
      expected = condition_operand_count(name)
      raise BytecodeEmitterError, "#{name} requires #{expected} operands, got #{operands.length}." unless operands.length == expected
      operands.each { |operand| u32(operand) }
      { name: name, opcode: @condition_codes.fetch(name), operands: operands, display: display }
    end

    def instruction_operand_count(name)
      {
        'START_STATE' => 3, 'START_RELATION' => 3, 'START_VALUE' => 3, 'START_TEXT_VALUE' => 3,
        'DAMAGE' => 3, 'CHANGE_STATE' => 4, 'CHANGE_VALUE' => 4, 'CHANGE_TEXT_VALUE' => 4,
        'CARRY' => 2, 'UNLOCK' => 2, 'CAUSE_EVENT' => 5
      }.fetch(name)
    end

    def condition_operand_count(name)
      { 'STATE_IS' => 2, 'STATE_ISNT' => 2, 'RELATION_EXISTS' => 3, 'VALUE_EQUALS' => 3, 'TEXT_VALUE_EQUALS' => 3 }.fetch(name)
    end

    def build_binary
      section_data = {
        'STRS' => encode_strings,
        'META' => encode_meta,
        'KIND' => model.fetch(:kinds).map { |entry| pack_u32(entry[:name_string_index], entry[:parent_index], entry[:source_order]) }.join,
        'THNG' => model.fetch(:things).map { |entry| pack_u32(entry[:name_string_index], entry[:kind_index], entry[:definition_order]) }.join,
        'STRT' => model.fetch(:start_records).map { |entry| encode_record(entry) }.join,
        'EVNT' => model.fetch(:events).map { |entry| encode_event(entry) }.join,
        'IFRL' => model.fetch(:if_rules).map { |entry| encode_if_rule(entry) }.join,
        'CODE' => encode_code
      }
      record_counts = {
        'STRS' => model.fetch(:strings).length,
        'META' => 1,
        'KIND' => model.fetch(:kinds).length,
        'THNG' => model.fetch(:things).length,
        'STRT' => model.fetch(:start_records).length,
        'EVNT' => model.fetch(:events).length,
        'IFRL' => model.fetch(:if_rules).length,
        'CODE' => model.fetch(:blocks).length
      }

      if [BytecodeContract::PROFILE_3, BytecodeContract::PROFILE_4].include?(@profile)
        section_data['CTRL'] = encode_game_section(model.fetch(:controls))
        section_data['HOVR'] = encode_game_section(model.fetch(:hover_declarations))
        section_data['CTXT'] = encode_game_section(model.fetch(:context_declarations))
        record_counts['CTRL'] = model.fetch(:controls).length
        record_counts['HOVR'] = model.fetch(:hover_declarations).length
        record_counts['CTXT'] = model.fetch(:context_declarations).length
      end

      section_order = BytecodeContract.section_order(@profile)
      offset = BytecodeContract::HEADER_SIZE_BYTES + section_order.length * BytecodeContract::DIRECTORY_ENTRY_SIZE_BYTES
      entries = []
      body = +''
      section_order.each do |section_id|
        padding = padding_for(offset)
        body << "\x00" * padding
        offset += padding
        data = section_data.fetch(section_id)
        entries << [section_id, offset, data.bytesize, record_counts.fetch(section_id)]
        body << data
        offset += data.bytesize
      end
      file_size = offset
      header = [
        BytecodeContract::MAGIC,
        [BytecodeContract::BINARY_FORMAT_VERSION, @profile_format_version].pack('v2'),
        [BytecodeContract::HEADER_SIZE_BYTES, section_order.length, BytecodeContract::HEADER_SIZE_BYTES, BytecodeContract::DIRECTORY_ENTRY_SIZE_BYTES, file_size, 0].pack('V6')
      ].join
      directory = entries.map { |id, entry_offset, length, count| id + [entry_offset, length, count].pack('V3') }.join
      result = header + directory + body
      raise BytecodeEmitterError, 'BSharp Bytecode file-size calculation failed.' unless result.bytesize == file_size
      if @profile == BytecodeContract::PROFILE && FORBIDDEN_BINARY_TERMS.any? { |term| result.include?(term) }
        raise BytecodeEmitterError, 'BSharp Bytecode contains Ruby-specific serialized data.'
      end
      result.force_encoding(Encoding::BINARY)
    end

    def encode_strings
      model.fetch(:strings).map do |value|
        bytes = value.encode(Encoding::UTF_8).b
        [bytes.bytesize].pack('V') + bytes + ("\x00" * padding_for(4 + bytes.bytesize))
      end.join
    end

    def encode_meta
      fingerprint_bytes = [model.fetch(:fingerprint)].pack('H*')
      raise BytecodeEmitterError, 'Meaning fingerprint must be exactly 32 bytes.' unless fingerprint_bytes.bytesize == 32

      pack_u32(
        @string_indexes.fetch(@profile),
        @string_indexes.fetch(@meaning_profile),
        @string_indexes.fetch(@fingerprint_algorithm)
      ) + fingerprint_bytes + pack_u32(
        model.fetch(:kinds).length,
        model.fetch(:things).length,
        model.fetch(:start_records).length,
        model.fetch(:events).length,
        model.fetch(:if_rules).length,
        model.fetch(:blocks).length
      )
    end

    def encode_event(entry)
      pack_u32(
        selector_code(entry[:actor_selector]), entry[:actor_reference], entry[:action_string_index],
        selector_code(entry[:target_selector]), entry[:target_reference], entry[:block_index], entry[:source_order]
      )
    end

    def encode_if_rule(entry)
      condition = entry.fetch(:condition)
      encode_record(condition) + pack_u32(entry[:block_index], entry[:source_order])
    end

    def encode_code
      blocks = model.fetch(:blocks)
      encoded = blocks.map do |block|
        bytes = block.fetch(:instructions).map { |instruction| encode_record(instruction) }.join
        [block, bytes]
      end
      offset = 4 + blocks.length * 16
      directory = encoded.map do |block, bytes|
        row = pack_u32(block.fetch(:id), offset, bytes.bytesize, block.fetch(:instructions).length)
        offset += bytes.bytesize
        row
      end.join
      [blocks.length].pack('V') + directory + encoded.map(&:last).join
    end

    def encode_record(record)
      operands = record.fetch(:operands)
      [record.fetch(:opcode), operands.length, 0].pack('CCv') + pack_u32(*operands)
    end

    def encode_game_section(entries)
      JSON.generate(entries).encode(Encoding::UTF_8).b
    end

    def canonical_game_data(value)
      case value
      when Hash
        value.keys.map(&:to_s).reject { |key| %w[line_number raw].include?(key) }.sort.each_with_object({}) do |key, result|
          source_value = value[key] || value[key.to_sym]
          result[key.to_sym] = canonical_game_data(source_value)
        end
      when Array
        value.map { |entry| canonical_game_data(entry) }
      else
        value
      end
    end

    def pack_u32(*values)
      values.each { |value| u32(value) }
      values.pack("V#{values.length}")
    end

    def u32(value)
      unless value.is_a?(Integer) && value.between?(0, 0xFFFF_FFFF)
        raise BytecodeEmitterError, "BSharp Bytecode operand is outside u32: #{value.inspect}"
      end
      value
    end

    def whole_number(value, label, minimum: 0)
      unless value.is_a?(Integer) && value.between?(minimum, BytecodeContract::WHOLE_NUMBER_RANGE.end)
        raise BytecodeEmitterError, "#{label} is outside #{minimum} through #{BytecodeContract::WHOLE_NUMBER_RANGE.end}."
      end
      value
    end

    def intern(value, role: :identifier)
      string = value.to_s.encode(Encoding::UTF_8)
      if @string_indexes.key?(string)
        index = @string_indexes.fetch(string)
        @string_roles[index] = merge_string_role(@string_roles[index], role)
        return index
      end

      index = @strings.length
      @strings << string
      @string_roles << role
      @string_indexes[string] = index
      index
    rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
      raise BytecodeEmitterError, 'BSharp Bytecode strings must be valid UTF-8.'
    end

    def optional_string_index(value)
      value && !value.empty? ? intern(value) : BytecodeContract::NO_REFERENCE_U32
    end

    def selector_code(name)
      BytecodeContract::SELECTORS.fetch(name)
    end

    def render_selector(selector, reference)
      case selector
      when 'EXACT_THING' then "THING[#{thing_name(reference)}]"
      when 'ONE_KIND' then "ONE_KIND[#{kind_name(reference)}]"
      when 'BOUND_THAT_KIND' then "BOUND_THAT_KIND[#{kind_name(reference)}]"
      when 'EVERY_KIND' then "EVERY_KIND[#{kind_name(reference)}]"
      when 'NO_REFERENCE' then 'NONE'
      else selector
      end
    end

    def thing_name(index)
      Array(@document['objects']).fetch(index).fetch('name')
    end

    def kind_name(index)
      @kind_names.fetch(index)
    end

    def remove_display(opposite)
      opposite ? "REMOVE #{opposite}" : 'REMOVE NONE'
    end

    def padding_for(size)
      (BytecodeContract::ALIGNMENT_BYTES - (size % BytecodeContract::ALIGNMENT_BYTES)) % BytecodeContract::ALIGNMENT_BYTES
    end

    def normalize(value)
      value.to_s.strip.downcase.gsub(/\s+/, ' ')
    end

    def text_value(value, label)
      TextLiteral.new(value).value
    rescue TextLiteralError => error
      raise BytecodeEmitterError, "#{label} is invalid: #{error.message}"
    end

    def quote_text(value)
      %Q{"#{value}"}
    end

    def merge_string_role(existing, added)
      return existing if existing == added
      :identifier_and_literal
    end

    def document_uses_text_values?
      Array(@document['facts']).any? { |fact| fact.key?('text_value') } ||
        Array(@document['events']).any? { |event| Array(event['then']).any? { |action| action.key?('to_text') } } ||
        Array(@document['if_rules']).any? do |rule|
          rule.fetch('if', {}).key?('text_value') || Array(rule['then']).any? { |action| action.key?('to_text') }
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

    def atomic_write_pair(binary_path, binary_content, text_path, text_content)
      FileUtils.mkdir_p(File.dirname(binary_path))
      FileUtils.mkdir_p(File.dirname(text_path))
      temps = []
      backups = []
      begin
        binary_temp = create_temp(binary_path, binary_content, true)
        text_temp = create_temp(text_path, text_content, false)
        temps.concat([binary_temp, text_temp])

        [binary_path, text_path].each do |destination|
          next unless File.exist?(destination)

          backup = "#{destination}.bsharp-v0127-backup-#{Process.pid}"
          File.rename(destination, backup)
          backups << [destination, backup]
        end
        File.rename(binary_temp, binary_path)
        temps.delete(binary_temp)
        File.chmod(0o644, binary_path)
        File.rename(text_temp, text_path)
        temps.delete(text_temp)
        File.chmod(0o644, text_path)
        backups.each { |_destination, backup| File.delete(backup) if File.exist?(backup) }
      rescue SystemCallError => error
        [binary_path, text_path].each { |destination| File.delete(destination) if File.exist?(destination) }
        backups.reverse_each do |destination, backup|
          File.rename(backup, destination) if File.exist?(backup)
        end
        raise BytecodeEmitterError, "BSharp Bytecode could not write output: #{error.message}"
      ensure
        temps.each { |path| File.delete(path) if File.exist?(path) }
        backups.each { |_destination, backup| File.delete(backup) if File.exist?(backup) }
      end
    end

    def create_temp(destination, content, binary)
      directory = File.dirname(destination)
      basename = File.basename(destination)
      staged_path = nil
      Tempfile.create([".#{basename}.", '.tmp'], directory) do |file|
        file.binmode if binary
        file.write(content)
        file.flush
        file.fsync
        file.close
        staged_path = "#{file.path}.ready"
        File.rename(file.path, staged_path)
      end
      staged_path
    end
  end
end

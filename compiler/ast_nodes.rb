# frozen_string_literal: true

module BasicSharp
  VERSION = '0.1.68'

  Statement = Struct.new(:starter, :head, :children, :line_number, keyword_init: true) do
    def to_h
      {
        starter: starter,
        head: head,
        line_number: line_number,
        children: children.map(&:to_h)
      }
    end
  end

  ChildLine = Struct.new(:raw, :body, :line_command, :action, :line_number, :terminal, keyword_init: true) do
    def to_h
      {
        line_number: line_number,
        raw: raw,
        body: body,
        line_command: line_command,
        action: action,
        terminal: terminal
      }
    end
  end

  KindDefinition = Struct.new(:name, :parent, :line_number, keyword_init: true) do
    def to_h
      { name: name, parent: parent, line_number: line_number }
    end
  end

  Definition = Struct.new(:kind, :name, :line_number, keyword_init: true) do
    def to_h
      { kind: kind, name: name, line_number: line_number }
    end
  end

  Fact = Struct.new(:subject, :relation, :value, :value_name, :line_number, keyword_init: true) do
    def to_h
      result = {
        subject: subject,
        relation: relation,
        value: value.respond_to?(:to_h) ? value.to_h : value,
        line_number: line_number
      }
      result[:value_name] = value_name if value_name
      result
    end
  end

  ActionCall = Struct.new(:verb, :target, :tail, :text_literal, :line_number, keyword_init: true) do
    def to_h
      result = { verb: verb, target: target, tail: tail, line_number: line_number }
      result[:text_literal] = text_literal.to_h if text_literal
      result
    end
  end

  EventRule = Struct.new(:event, :actions, :line_number, keyword_init: true) do
    def to_h
      { event: event, line_number: line_number, actions: actions.map(&:to_h) }
    end
  end

  IfRule = Struct.new(:condition, :actions, :otherwise_actions, :line_number, :otherwise_line_number, keyword_init: true) do
    def to_h
      result = { condition: condition, line_number: line_number, actions: actions.map(&:to_h) }
      if otherwise_actions
        result[:otherwise_actions] = otherwise_actions.map(&:to_h)
        result[:otherwise_line_number] = otherwise_line_number
      end
      result
    end
  end

  ControlDeclaration = Struct.new(:subject, :instructions, :line_number, keyword_init: true) do
    def to_h
      { subject: subject, instructions: instructions, line_number: line_number }
    end
  end

  HoverDeclaration = Struct.new(:subject, :fields, :line_number, keyword_init: true) do
    def to_h
      { subject: subject, fields: fields, line_number: line_number }
    end
  end

  ContextEntry = Struct.new(:label, :condition, :action, :line_number, keyword_init: true) do
    def to_h
      { label: label, condition: condition, action: action&.to_h, line_number: line_number }
    end
  end

  ContextDeclaration = Struct.new(:subject, :entries, :line_number, keyword_init: true) do
    def to_h
      { subject: subject, entries: entries.map(&:to_h), line_number: line_number }
    end
  end

  Program = Struct.new(
    :statements, :kind_definitions, :definitions, :facts, :event_rules, :if_rules,
    :controls, :hover_declarations, :context_declarations, :diagnostics,
    keyword_init: true
  ) do
    def to_h
      {
        version: VERSION,
        statements: statements.map(&:to_h),
        kind_definitions: kind_definitions.map(&:to_h),
        definitions: definitions.map(&:to_h),
        facts: facts.map(&:to_h),
        event_rules: event_rules.map(&:to_h),
        if_rules: if_rules.map(&:to_h),
        controls: controls.map(&:to_h),
        hover_declarations: hover_declarations.map(&:to_h),
        context_declarations: context_declarations.map(&:to_h),
        diagnostics: diagnostics.map(&:to_h)
      }
    end
  end
end

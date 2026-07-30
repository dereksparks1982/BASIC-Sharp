# frozen_string_literal: true

module DKScript
  VERSION = '0.1.11'

  Statement = Struct.new(:starter, :children, :line_number, keyword_init: true) do
    def to_h
      {
        starter: starter,
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

  Fact = Struct.new(:subject, :relation, :value, :line_number, keyword_init: true) do
    def to_h
      { subject: subject, relation: relation, value: value, line_number: line_number }
    end
  end

  ActionCall = Struct.new(:verb, :target, :tail, :line_number, keyword_init: true) do
    def to_h
      { verb: verb, target: target, tail: tail, line_number: line_number }
    end
  end

  EventRule = Struct.new(:event, :actions, :line_number, keyword_init: true) do
    def to_h
      { event: event, line_number: line_number, actions: actions.map(&:to_h) }
    end
  end

  IfRule = Struct.new(:condition, :actions, :line_number, keyword_init: true) do
    def to_h
      { condition: condition, line_number: line_number, actions: actions.map(&:to_h) }
    end
  end

  Program = Struct.new(:statements, :kind_definitions, :definitions, :facts, :event_rules, :if_rules, :diagnostics, keyword_init: true) do
    def to_h
      {
        version: VERSION,
        statements: statements.map(&:to_h),
        kind_definitions: kind_definitions.map(&:to_h),
        definitions: definitions.map(&:to_h),
        facts: facts.map(&:to_h),
        event_rules: event_rules.map(&:to_h),
        if_rules: if_rules.map(&:to_h),
        diagnostics: diagnostics.map(&:to_h)
      }
    end
  end
end

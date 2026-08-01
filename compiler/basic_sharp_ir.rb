# frozen_string_literal: true

require_relative 'ast_nodes'

module BasicSharp
  module IR
    Document = Struct.new(
      :version, :meaning_profile, :kinds, :objects, :facts, :events, :if_rules,
      :controls, :hover_declarations, :context_declarations, :diagnostics,
      keyword_init: true
    ) do
      def to_h
        result = {
          version: version,
          format: 'bsir.debug.json',
          kinds: kinds,
          objects: objects,
          facts: facts,
          events: events,
          if_rules: if_rules,
          controls: controls,
          hover_declarations: hover_declarations,
          context_declarations: context_declarations,
          diagnostics: diagnostics.map(&:to_h)
        }
        result[:meaning_profile] = meaning_profile unless meaning_profile == 'bsharp.meaning.v1'
        result
      end

      def error_count
        diagnostics.count { |diagnostic| diagnostic.severity == 'error' }
      end

      def warning_count
        diagnostics.count { |diagnostic| diagnostic.severity == 'warning' }
      end
    end
  end
end

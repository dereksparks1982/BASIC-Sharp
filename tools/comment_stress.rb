#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../compiler/parser'

body = (1..10_000).map { |index| "comment line #{index}." }.join("\n")
source = "//#{body}\n/.\nSTART\n[\n    PLAYER has 3 speed\n].\n"
program = BasicSharp::Parser.new(source).parse
raise program.diagnostics.map(&:message).join("\n") unless program.diagnostics.none? { |entry| entry.severity == 'error' }
raise 'comment changed START parsing' unless program.facts.length == 1
puts 'BASIC# comment stress: PASS (10,000 comment lines)'

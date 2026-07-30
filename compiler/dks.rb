#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative 'parser'

if ARGV.empty?
  warn 'Usage: ruby compiler/dks.rb samples/first_room.dks [--json]'
  exit 64
end

path = ARGV[0]
json = ARGV.include?('--json')
source = File.read(path)
program = DKScript::Parser.new(source).parse

if json
  puts JSON.pretty_generate(program.to_h)
  exit(program.diagnostics.any? { |d| d.severity == 'error' } ? 1 : 0)
end

puts "DKScript Ruby Bootstrap Compiler v#{DKScript::VERSION}"
puts "file: #{path}"
puts "statements: #{program.statements.length}"
puts "definitions: #{program.definitions.length}"
puts "facts: #{program.facts.length}"
puts "events: #{program.event_rules.length}"
puts "if rules: #{program.if_rules.length}"
puts "actions: #{program.event_rules.sum { |r| r.actions.length } + program.if_rules.sum { |r| r.actions.length }}"
puts "errors: #{program.diagnostics.count { |d| d.severity == 'error' }}"
puts "warnings: #{program.diagnostics.count { |d| d.severity == 'warning' }}"

unless program.diagnostics.empty?
  puts
  puts 'Diagnostics:'
  program.diagnostics.each { |diagnostic| puts "  #{diagnostic}" }
end

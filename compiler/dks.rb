#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'parser'
require_relative 'resolver'
require_relative 'ir_emitter'

if ARGV.empty?
  warn 'Usage: ruby compiler/dks.rb samples/first_room.dks [--json|--emit-ast|--emit-ir] [--out path]'
  exit 64
end

path = ARGV.find { |arg| !arg.start_with?('--') }
out_index = ARGV.index('--out')
out_path = out_index ? ARGV[out_index + 1] : nil
emit_ast = ARGV.include?('--json') || ARGV.include?('--emit-ast')
emit_ir = ARGV.include?('--emit-ir')

if out_index && (out_path.nil? || out_path.start_with?('--'))
  warn 'Missing output path after --out'
  exit 64
end

unless path && File.file?(path)
  warn "DKScript source file not found: #{path || '(none)'}"
  exit 66
end

def write_output(path, content)
  dir = File.dirname(path)
  FileUtils.mkdir_p(dir) unless dir == '.' || Dir.exist?(dir)
  File.write(path, "#{content}
")
  puts "wrote: #{path}"
end

source = File.read(path)
parser = DKScript::Parser.new(source)
program = parser.parse
resolved = DKScript::SemanticResolver.new(program, dictionary: parser.dictionary).resolve

if emit_ast
  output = JSON.pretty_generate(program.to_h)
  out_path ? write_output(out_path, output) : puts(output)
  exit(program.diagnostics.any? { |d| d.severity == 'error' } ? 1 : 0)
end

if emit_ir
  emitter = DKScript::IREmitter.new(resolved)
  out_path ? emitter.write(out_path) : puts(emitter.to_json)
  exit(resolved.error_count.positive? ? 1 : 0)
end

puts "DKScript Ruby Bootstrap Compiler v#{DKScript::VERSION}"
puts "file: #{path}"
puts "statements: #{program.statements.length}"
puts "kinds: #{program.kind_definitions.length}"
puts "definitions: #{program.definitions.length}"
puts "facts: #{program.facts.length}"
puts "events: #{program.event_rules.length}"
puts "if rules: #{program.if_rules.length}"
puts "objects: #{resolved.objects.length}"
puts "actions: #{program.event_rules.sum { |rule| rule.actions.length } + program.if_rules.sum { |rule| rule.actions.length }}"
puts "errors: #{resolved.error_count}"
puts "warnings: #{resolved.warning_count}"

unless resolved.diagnostics.empty?
  puts
  puts 'Diagnostics:'
  resolved.diagnostics.each { |diagnostic| puts "  #{diagnostic}" }
end

exit(resolved.error_count.positive? ? 1 : 0)

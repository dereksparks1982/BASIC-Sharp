#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'parser'
require_relative 'resolver'
require_relative 'ir_emitter'
require_relative 'runtime'

if ARGV.empty?
  warn 'Usage: ruby compiler/basic_sharp.rb source.bsharp [--json|--emit-ast|--emit-ir] [--out path] [--run "event"]'
  warn '   or: ruby compiler/basic_sharp.rb existing.bsir.json --run "event"'
  exit 64
end

def option_value(arguments, flag)
  index = arguments.index(flag)
  index ? arguments[index + 1] : nil
end

out_index = ARGV.index('--out')
out_path = option_value(ARGV, '--out')
run_index = ARGV.index('--run')
run_event = option_value(ARGV, '--run')
emit_ast = ARGV.include?('--json') || ARGV.include?('--emit-ast')
emit_ir = ARGV.include?('--emit-ir')

consumed_values = [out_index && out_index + 1, run_index && run_index + 1].compact
path = ARGV.each_with_index.find do |argument, index|
  !argument.start_with?('--') && !consumed_values.include?(index)
end&.first

if out_index && (out_path.nil? || out_path.start_with?('--'))
  warn 'Missing output path after --out'
  exit 64
end

if run_index && (run_event.nil? || run_event.start_with?('--'))
  warn 'Missing event after --run'
  exit 64
end

unless path && File.file?(path)
  warn "BASIC# source file not found: #{path || '(none)'}"
  exit 66
end

def write_output(path, content)
  dir = File.dirname(path)
  FileUtils.mkdir_p(dir) unless dir == '.' || Dir.exist?(dir)
  File.write(path, "#{content}\n")
  puts "wrote: #{path}"
end

if run_index && File.extname(path).downcase == '.json'
  begin
    runtime = BasicSharp::Runtime.load(path)
    result = runtime.run_event(run_event)
    puts runtime.report(result)
    exit(result.fetch('matched') ? 0 : 1)
  rescue BasicSharp::RetiredDKIRFormatError => error
    warn error.message
    exit 1
  rescue JSON::ParserError, ArgumentError, KeyError => error
    warn "BSharp IR cannot run: #{error.message}"
    exit 1
  end
end

source = File.read(path)
parser = BasicSharp::Parser.new(source)
program = parser.parse
resolved = BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve

if emit_ast
  output = JSON.pretty_generate(program.to_h)
  out_path ? write_output(out_path, output) : puts(output)
  exit(program.diagnostics.any? { |diagnostic| diagnostic.severity == 'error' } ? 1 : 0)
end

if emit_ir
  emitter = BasicSharp::IREmitter.new(resolved)
  out_path ? emitter.write(out_path) : puts(emitter.to_json)
  exit(resolved.error_count.positive? ? 1 : 0)
end

if run_index
  if resolved.error_count.positive?
    resolved.diagnostics.each { |diagnostic| warn diagnostic.to_s }
    exit 1
  end

  runtime = BasicSharp::Runtime.new(resolved)
  result = runtime.run_event(run_event)
  puts runtime.report(result)
  exit(result.fetch('matched') ? 0 : 1)
end

puts "BASIC# Ruby Bootstrap Compiler v#{BasicSharp::VERSION}"
puts "file: #{path}"
puts "statements: #{program.statements.length}"
puts "kinds: #{program.kind_definitions.length}"
puts "definitions: #{program.definitions.length}"
puts "facts: #{program.facts.length}"
puts "events: #{program.event_rules.length}"
puts "if rules: #{program.if_rules.length}"
puts "objects: #{resolved.objects.length}"
puts "official words: #{program.event_rules.sum { |rule| rule.actions.length } + program.if_rules.sum { |rule| rule.actions.length }}"
puts "errors: #{resolved.error_count}"
puts "warnings: #{resolved.warning_count}"

unless resolved.diagnostics.empty?
  puts
  puts 'Diagnostics:'
  resolved.diagnostics.each { |diagnostic| puts "  #{diagnostic}" }
end

exit(resolved.error_count.positive? ? 1 : 0)

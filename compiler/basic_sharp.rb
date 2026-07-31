#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'parser'
require_relative 'resolver'
require_relative 'ir_emitter'
require_relative 'runtime'
require_relative 'world_save'

if ARGV.empty?
  warn 'Usage: ruby compiler/basic_sharp.rb source.bsharp [--json|--emit-ast|--emit-ir] [--out path] [--run "event"]'
  warn '       [--load-world path.bsave.json] [--save-world path.bsave.json]'
  warn '   or: ruby compiler/basic_sharp.rb existing.bsir.json [--run "event"] [--load-world path.bsave.json] [--save-world path.bsave.json]'
  exit 64
end

def option_value(arguments, flag)
  index = arguments.index(flag)
  index ? arguments[index + 1] : nil
end

def validate_option_value!(arguments, flag, label)
  index = arguments.index(flag)
  return [nil, nil] unless index

  value = arguments[index + 1]
  if value.nil? || value.start_with?('--')
    warn "Missing #{label} after #{flag}"
    exit 64
  end
  [index, value]
end

def write_output(path, content)
  dir = File.dirname(path)
  FileUtils.mkdir_p(dir) unless dir == '.' || Dir.exist?(dir)
  File.write(path, "#{content}\n")
  puts "wrote: #{path}"
end

out_index, out_path = validate_option_value!(ARGV, '--out', 'output path')
run_index, run_event = validate_option_value!(ARGV, '--run', 'event')
load_index, load_world_path = validate_option_value!(ARGV, '--load-world', 'world-save path')
save_index, save_world_path = validate_option_value!(ARGV, '--save-world', 'world-save path')
emit_ast = ARGV.include?('--json') || ARGV.include?('--emit-ast')
emit_ir = ARGV.include?('--emit-ir')

consumed_values = [out_index, run_index, load_index, save_index].compact.map { |index| index + 1 }
path = ARGV.each_with_index.find do |argument, index|
  !argument.start_with?('--') && !consumed_values.include?(index)
end&.first

unless path && File.file?(path)
  warn "BASIC# source file not found: #{path || '(none)'}"
  exit 66
end

json_input = File.extname(path).downcase == '.json'
json_document = nil
if json_input
  begin
    json_document = JSON.parse(File.read(path))
  rescue JSON::ParserError => error
    warn "BSharp IR cannot run: #{error.message}"
    exit 1
  end

  if BasicSharp::WorldSave.save_file?(json_document)
    warn 'A BSharp Save contains world state, not program rules.'
    warn 'Start BASIC# with the matching .bsharp or .bsir.json file and use --load-world.'
    exit 1
  end
end

program = nil
resolved = nil
unless json_input
  source = File.read(path)
  parser = BasicSharp::Parser.new(source)
  program = parser.parse
  resolved = BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
end

if emit_ast
  if json_input
    warn '--emit-ast requires a .bsharp source file'
    exit 64
  end
  output = JSON.pretty_generate(program.to_h)
  out_path ? write_output(out_path, output) : puts(output)
  exit(program.diagnostics.any? { |diagnostic| diagnostic.severity == 'error' } ? 1 : 0)
end

if emit_ir
  if json_input
    warn '--emit-ir requires a .bsharp source file'
    exit 64
  end
  emitter = BasicSharp::IREmitter.new(resolved)
  out_path ? emitter.write(out_path) : puts(emitter.to_json)
  exit(resolved.error_count.positive? ? 1 : 0)
end

runtime_mode = run_index || load_index || save_index
if runtime_mode
  begin
    if !json_input && resolved.error_count.positive?
      resolved.diagnostics.each { |diagnostic| warn diagnostic.to_s }
      exit 1
    end

    save_document = load_world_path ? BasicSharp::WorldSave.read(load_world_path) : nil
    runtime = if json_input
                BasicSharp::Runtime.new(json_document, world_save: save_document)
              else
                BasicSharp::Runtime.new(resolved, world_save: save_document)
              end

    puts "loaded world: #{load_world_path}" if load_world_path && !run_index

    result = nil
    if run_index
      result = runtime.run_event(run_event)
      puts runtime.report(result)
    end

    if save_world_path
      runtime.write_world_save(save_world_path)
      puts "saved world: #{save_world_path}"
    end

    success = result.nil? || (result.fetch('matched') && result['error'].nil?)
    exit(success ? 0 : 1)
  rescue BasicSharp::RetiredDKIRFormatError => error
    warn error.message
    exit 1
  rescue BasicSharp::WorldSaveError => error
    warn error.message
    exit 1
  rescue JSON::ParserError, ArgumentError, KeyError => error
    warn "BSharp IR cannot run: #{error.message}"
    exit 1
  end
end

if json_input
  begin
    runtime = BasicSharp::Runtime.new(json_document)
    puts "BASIC# Ruby Bootstrap Compiler v#{BasicSharp::VERSION}"
    puts "file: #{path}"
    puts 'BSharp IR: ready'
    exit(runtime.startup_if_error.nil? ? 0 : 1)
  rescue BasicSharp::RetiredDKIRFormatError => error
    warn error.message
    exit 1
  rescue JSON::ParserError, ArgumentError, KeyError => error
    warn "BSharp IR cannot run: #{error.message}"
    exit 1
  end
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

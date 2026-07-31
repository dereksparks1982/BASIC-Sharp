#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'parser'
require_relative 'resolver'
require_relative 'ir_emitter'
require_relative 'runtime'
require_relative 'world_save'
require_relative 'ask'
require_relative 'bytecode_emitter'

if ARGV.empty?
  warn 'Usage: ruby compiler/basic_sharp.rb source.bsharp [--json|--emit-ast|--emit-ir|--emit-bytecode] [--out path] [--run "event"]'
  warn '       [--load-world path.bsave.json] [--ask "question"]... [--ask-json] [--save-world path.bsave.json]'
  warn '   or: ruby compiler/basic_sharp.rb existing.bsir.json [--run "event"] [--load-world path.bsave.json]'
  warn '       [--ask "question"]... [--ask-json] [--save-world path.bsave.json]'
  exit 64
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

def repeated_option_values!(arguments, flag, label)
  entries = []
  arguments.each_with_index do |argument, index|
    next unless argument == flag

    value = arguments[index + 1]
    if value.nil? || value.start_with?('--')
      warn "Missing #{label} after #{flag}"
      exit 64
    end
    entries << [index, value]
  end
  entries
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
ask_entries = repeated_option_values!(ARGV, '--ask', 'ASK question')
ask_questions = ask_entries.map(&:last)
ask_json = ARGV.include?('--ask-json')
emit_ast = ARGV.include?('--json') || ARGV.include?('--emit-ast')
emit_ir = ARGV.include?('--emit-ir')
emit_bytecode = ARGV.include?('--emit-bytecode')

if ask_json && ask_questions.empty?
  warn '--ask-json requires at least one --ask question'
  exit 64
end
if ask_questions.length > BasicSharp::Ask::MAX_QUESTIONS
  warn "BASIC# ASK accepts at most #{BasicSharp::Ask::MAX_QUESTIONS} questions per command."
  exit 64
end

value_indexes = [out_index, run_index, load_index, save_index].compact + ask_entries.map(&:first)
consumed_values = value_indexes.map { |index| index + 1 }
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


if emit_bytecode
  incompatible = emit_ast || emit_ir || run_index || load_index || save_index || !ask_questions.empty? || ask_json
  if incompatible
    warn '--emit-bytecode cannot be combined with AST, BSIR, runtime, world-save, or ASK modes'
    exit 64
  end

  begin
    bytecode_document = if json_input
                          json_document
                        else
                          resolved
                        end
    if !json_input && (resolved.error_count.positive? || resolved.warning_count.positive?)
      resolved.diagnostics.each { |diagnostic| warn diagnostic.to_s }
      warn 'BSharp Bytecode was not written because the program has errors or warnings.'
      exit 1
    end

    output_path = out_path
    unless output_path
      output_path = if path.downcase.end_with?('.bsir.json')
                      path[0...-'.bsir.json'.length] + '.bsbc'
                    else
                      path.sub(/\.bsharp\z/i, '.bsbc')
                    end
    end
    unless output_path.downcase.end_with?('.bsbc')
      warn 'BSharp Bytecode output must end with .bsbc.'
      exit 64
    end

    emitter = BasicSharp::BytecodeEmitter.new(bytecode_document)
    binary_path, disassembly_path = emitter.write(output_path)
    puts "wrote: #{binary_path}"
    puts "wrote: #{disassembly_path}"
    exit 0
  rescue BasicSharp::BytecodeEmitterError => error
    warn error.message
    exit 1
  end
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

runtime_mode = run_index || load_index || save_index || !ask_questions.empty?
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

    puts "loaded world: #{load_world_path}" if load_world_path && !run_index && ask_questions.empty? && !ask_json

    result = nil
    if run_index
      result = runtime.run_event(run_event)
      puts runtime.report(result) unless ask_json
      unless result.fetch('matched') && result['error'].nil?
        exit 1
      end
    end

    unless ask_questions.empty?
      inspector = BasicSharp::Ask.new(runtime)
      answers = inspector.answer_many(ask_questions)
      if ask_json
        print inspector.to_json(answers)
      else
        puts if run_index
        puts inspector.report(answers)
      end
    end

    if save_world_path
      runtime.write_world_save(save_world_path)
      puts "saved world: #{save_world_path}" unless ask_json
    end

    exit 0
  rescue BasicSharp::RetiredDKIRFormatError => error
    warn error.message
    exit 1
  rescue BasicSharp::AskError => error
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

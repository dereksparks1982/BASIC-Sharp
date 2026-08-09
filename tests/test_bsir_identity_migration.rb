# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require_relative 'support/cli_capture'
require 'rbconfig'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'

class TestBSIRIdentityMigration < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  RUBY = RbConfig.ruby
  RETIRED_MESSAGE = <<~TEXT.chomp
    This file uses the retired DKIR format.
    BASIC# v0.1.20 uses BSharp IR.
    Recompile the original .bsharp source to create a new BSIR file.
  TEXT

  def bsir_document
    source = File.read(File.join(ROOT, 'samples/first_room.bsharp'), encoding: 'UTF-8')
    parser = BasicSharp::Parser.new(source)
    program = parser.parse
    BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve.to_h
  end

  def test_new_documents_use_bsharp_ir_identity
    document = bsir_document

    assert_equal '0.1.71', document.fetch(:version)
    assert_equal 'bsir.debug.json', document.fetch(:format)
  end

  def test_retired_dkir_is_rejected_with_the_approved_exact_message
    document = bsir_document
    document[:format] = 'dkir.debug.json'

    error = assert_raises(BasicSharp::RetiredDKIRFormatError) do
      BasicSharp::Runtime.new(document)
    end

    assert_equal RETIRED_MESSAGE, error.message
  end

  def test_cli_prints_the_retired_format_message_without_extra_wording
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'retired.dkir.json')
      document = bsir_document
      document[:format] = 'dkir.debug.json'
      File.write(path, JSON.pretty_generate(document))

      stdout, stderr, status = capture_cli(
        RUBY,
        File.join(ROOT, 'compiler/basic_sharp.rb'),
        path,
        '--run',
        'player attacks henry',
        chdir: ROOT
      )

      refute status.success?
      assert_empty stdout
      assert_equal "#{RETIRED_MESSAGE}\n", stderr
    end
  end

  def test_active_files_use_bsharp_ir_names
    assert File.file?(File.join(ROOT, 'BASIC_SHARP_PATCH_MANIFEST.json'))
    refute File.exist?(File.join(ROOT, 'DK_PATCH_MANIFEST.json'))

    assert_empty Dir[File.join(ROOT, 'samples/*.ir.json')]
    assert_empty Dir[File.join(ROOT, 'tests/fixtures/*.ir.json')]
    assert_empty Dir[File.join(ROOT, 'docs/ir/DKIR_*')]

    assert_operator Dir[File.join(ROOT, 'samples/*.bsir.json')].length, :>=, 3
    assert_operator Dir[File.join(ROOT, 'tests/fixtures/*.bsir.json')].length, :>=, 6
    assert_operator Dir[File.join(ROOT, 'docs/ir/BSIR_*')].length, :>=, 6
  end
end

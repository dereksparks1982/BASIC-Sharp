# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/dictionary'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'

class TestKindFamilyHardening < Minitest::Test
  def resolve(source)
    parser = BasicSharp::Parser.new(source)
    program = parser.parse
    document = BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
    errors = document.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }
    raise errors.map(&:message).join("\n") unless errors.empty?

    document
  end

  def base_document
    resolve(<<~BASIC_SHARP).to_h
      DEFINE
      [
          @henry is a #guard
      ].
    BASIC_SHARP
  end

  def deep_family_source(depth: 256)
    kinds = (1..depth).map do |number|
      parent = number == 1 ? 'thing' : format('kind%03d', number - 1)
      "##{format('kind%03d', number)} is a ##{parent}"
    end

    <<~BASIC_SHARP
      KINDS
      [
          #{kinds.join("\n")}
      ].

      DEFINE
      [
          @deep heir is a ##{format('kind%03d', depth)}
      ].

      WHEN PLAYER takes a ##{format('kind%03d', depth)}
      [
          |then (damage it
      ].

      WHEN PLAYER attacks a ##{format('kind%03d', depth - 1)}
      [
          |then (damage it
      ].

      WHEN PLAYER speaks a #kind128
      [
          |then (damage it
      ].

      WHEN PLAYER gives a #thing
      [
          |then (damage it
      ].
    BASIC_SHARP
  end

  def thing(snapshot, name)
    snapshot.find { |entry| entry.fetch('name') == name }
  end

  def test_dictionary_family_cache_is_invalidated_when_a_kind_parent_is_added
    dictionary = BasicSharp::CoreDictionary.new

    assert_equal ['creature'], dictionary.kind_family('creature')
    dictionary.add_kind('creature', 'thing')
    assert_equal %w[creature thing], dictionary.kind_family('creature')

    dictionary.add_kind('dragon', 'creature')
    assert_equal %w[dragon creature thing], dictionary.kind_family('dragon')
  end

  def test_two_hundred_fifty_six_level_family_matches_direct_near_distant_and_root
    machine = BasicSharp::Runtime.new(resolve(deep_family_source))

    direct = machine.run_event('player takes deep heir')
    near = machine.run_event('player attacks deep heir')
    distant = machine.run_event('player speaks deep heir')
    root = machine.run_event('player gives deep heir')

    assert_equal 'player takes a kind256', direct.fetch('matched_when')
    assert_equal({ 'kind256' => 'deep heir' }, direct.fetch('context'))
    assert_equal 'player attacks a kind255', near.fetch('matched_when')
    assert_equal({ 'kind255' => 'deep heir' }, near.fetch('context'))
    assert_equal 'player speaks a kind128', distant.fetch('matched_when')
    assert_equal({ 'kind128' => 'deep heir' }, distant.fetch('context'))
    assert_equal 'player gives a thing', root.fetch('matched_when')
    assert_equal({ 'thing' => 'deep heir' }, root.fetch('context'))

    distance_index = machine.instance_variable_get(:@kind_distance_index)
    assert_equal 257, distance_index.fetch('kind256').length
    assert_equal 128, distance_index.fetch('kind256').fetch('kind128')
    assert distance_index.frozen?
    assert distance_index.fetch('kind256').frozen?
    assert_equal 4, thing(root.fetch('state'), 'deep heir').fetch('damage')
  end

  def test_same_distance_kind_trigger_tie_keeps_first_source_rule
    source = deep_family_source + <<~BASIC_SHARP

      WHEN PLAYER wears a #kind255
      [
          |then (damage it
      ].

      WHEN PLAYER wears a #kind255
      [
          |then (change it to hostile
      ].
    BASIC_SHARP
    machine = BasicSharp::Runtime.new(resolve(source))
    result = machine.run_event('player wears deep heir')
    heir = thing(result.fetch('state'), 'deep heir')

    assert_equal true, result.fetch('matched')
    assert_equal 'player wears a kind255', result.fetch('matched_when')
    assert_equal ['(damage deep heir'], result.fetch('ran')
    assert_equal 1, heir.fetch('damage')
    refute_includes heir.fetch('states'), 'hostile'
  end

  def test_malformed_saved_bsir_kind_entries_are_rejected_plainly
    cases = [
      [[42], 'Kind family entry 1 must describe one Kind'],
      [[{ 'parent' => 'thing' }], 'Kind family entry 1 is missing its Kind name'],
      [[{ 'name' => 'shade' }], 'Kind family entry 1 is missing its parent Kind'],
      [[{ 'name' => ' ', 'parent' => 'thing' }], 'Kind family entry 1 has an empty Kind name'],
      [[{ 'name' => 'shade', 'parent' => ' ' }], 'Kind family entry 1 has an empty parent Kind'],
      [[{ 'name' => 17, 'parent' => 'thing' }], 'Kind family entry 1 has a Kind name that is not text'],
      [[{ 'name' => 'shade', 'parent' => 17 }], 'Kind family entry 1 has a parent Kind that is not text'],
      [
        [
          { 'name' => 'shade', 'parent' => 'thing' },
          { 'name' => 'shade', 'parent' => 'thing' }
        ],
        'Kind family has a duplicate: shade is listed more than once'
      ],
      [
        [
          { 'name' => 'shade', 'parent' => 'thing' },
          { 'name' => 'shade', 'parent' => 'actor' }
        ],
        'Kind family conflicts: shade has more than one parent: thing and actor'
      ],
      [[{ 'name' => 'shade', 'parent' => 'spirit' }], 'Kind family is broken: shade has unknown parent spirit'],
      [
        [
          { 'name' => 'shade', 'parent' => 'spirit' },
          { 'name' => 'spirit', 'parent' => 'shade' }
        ],
        'Kind family has a loop: shade -> spirit -> shade'
      ]
    ]

    cases.each do |kinds, expected|
      document = base_document
      document[:kinds] = kinds
      error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
      assert_equal expected, error.message
    end
  end

  def test_saved_bsir_rejects_a_thing_whose_kind_is_unknown
    document = base_document
    henry = document.fetch(:objects).find { |object| object.fetch('name') == 'henry' }
    henry['kind'] = 'wyrm'

    error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
    assert_equal 'henry says it is a wyrm, but wyrm is not a known Kind', error.message
  end

  def test_accepted_saved_bsir_fixtures_still_run
    root = File.expand_path('..', __dir__)

    {
      '0.1.13' => File.join(root, 'tests/fixtures/first_room_v0_1_13.bsir.json'),
      '0.1.15' => File.join(root, 'tests/fixtures/first_room_v0_1_15.bsir.json'),
      '0.1.16' => File.join(root, 'tests/fixtures/first_room_v0_1_16.bsir.json'),
      '0.1.17' => File.join(root, 'tests/fixtures/first_room_v0_1_17.bsir.json'),
      '0.1.18' => File.join(root, 'tests/fixtures/first_room_v0_1_18.bsir.json'),
      '0.1.19' => File.join(root, 'tests/fixtures/first_room_v0_1_19.bsir.json')
    }.each do |version, path|
      document = JSON.parse(File.read(path))
      assert_equal version, document.fetch('version')

      machine = BasicSharp::Runtime.load(path)
      result = machine.run_event('player attacks henry')
      assert_equal true, result.fetch('matched')
      assert_equal 'player attacks a guard', result.fetch('matched_when')
    end
  end
end

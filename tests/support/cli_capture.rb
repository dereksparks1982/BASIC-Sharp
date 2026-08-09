# frozen_string_literal: true

require 'open3'

module BasicSharpTestCliCapture
  def capture_cli(*command, **options)
    stdout, stderr, status = Open3.capture3(*command, **options)
    stdout.force_encoding(Encoding::UTF_8)
    stderr.force_encoding(Encoding::UTF_8)
    [stdout, stderr, status]
  end
end

Minitest::Test.include(BasicSharpTestCliCapture) if defined?(Minitest::Test)

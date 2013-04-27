require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class TextDecorationTest < MiniTest::Unit::TestCase
  def test_decorate_text
    test_line = 'this is a test line'

    assert_equal "#{color.underline}#{test_line}#{color.reset}",
      ::Styles::Properties::TextDecoration.new(:underline).apply(test_line)

    assert_equal "#{color.strikethrough}#{test_line}#{color.reset}",
      ::Styles::Properties::TextDecoration.new(:strikethrough).apply(test_line)

    assert_equal "#{color.strikethrough}#{test_line}#{color.reset}",
      ::Styles::Properties::TextDecoration.new(:line_through).apply(test_line)

    assert_equal test_line,
      ::Styles::Properties::TextDecoration.new(:none).apply(test_line)
  end

  private

  def color
    ::Term::ANSIColor
  end
end

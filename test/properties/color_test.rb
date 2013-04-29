require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class ColorTest < MiniTest::Unit::TestCase
  def test_applies_correct_colors_to_lines
    test_line = 'this is a test line, to be colored'

    assert_equal "#{color.red}#{test_line}#{color.reset}",
      ::Styles::Properties::Color.new(:red).apply(test_line)

    assert_equal "#{color.blue}#{test_line}#{color.reset}",
      ::Styles::Properties::Color.new(:blue).apply(test_line)
  end

  def test_line_passes_through_with_invalid_color
    test_line = 'this is a test line, to be colored?'
    assert_equal test_line, ::Styles::Properties::Color.new(:sunshine).apply(test_line)
  end

  def test_none_value_removes_color
    test_line = 'this line should not have color'
    assert_equal "#{color.reset}#{test_line}", ::Styles::Properties::Color.new(:none).apply(test_line)
  end

  private

  def color
    ::Term::ANSIColor
  end
end

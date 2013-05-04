require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class ColorTest < MiniTest::Unit::TestCase
  def test_applies_correct_colors_to_lines
    test_line = 'this is a test line, to be colored'

    assert_equal "#{color.red}#{test_line}#{color.reset}", apply(:red, test_line)
    assert_equal "#{color.blue}#{test_line}#{color.reset}", apply(:blue, test_line)

    assert_equal "#{color.red}#{test_line}#{color.reset}", process_with_sub_engine(:red, test_line)
    assert_equal "#{color.blue}#{test_line}#{color.reset}", process_with_sub_engine(:blue, test_line)
  end

  def test_line_passes_through_with_invalid_color
    test_line = 'this is a test line, to be colored?'
    assert_equal test_line, apply(:sunshine, test_line)
    assert_equal test_line, process_with_sub_engine(:sunshine, test_line)
  end

  private

  def apply(value, line)
    ::Styles::Properties::Color.new(value).apply(line)
  end

  def process_with_sub_engine(value, line)
    sub_engine = ::Styles::SubEngines::Color.new
    sub_engine.process [::Styles::Properties::Color.new(value)], line
  end

  def color
    ::Term::ANSIColor
  end
end

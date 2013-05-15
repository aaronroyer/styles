require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class ColorTest < MiniTest::Unit::TestCase
  def test_applies_correct_colors_to_lines
    test_line = 'this is a test line, to be colored'

    assert_equal "#{color.red}#{test_line}#{color.reset}", process(:red, 'test', test_line)
    assert_equal "#{color.blue}#{test_line}#{color.reset}", process(:blue, 'test', test_line)
  end

  def test_line_passes_through_with_invalid_color
    test_line = 'this is a test line, to be colored?'
    assert_equal test_line, process(:sunshine, 'test', test_line)
  end

  private

  def process(value, selector, line)
    sub_engine = ::Styles::SubEngines::Color.new
    line = ::Styles::Line.new(line, [::Styles::Properties::Color.new(value, selector)])
    sub_engine.process(line).to_s
  end

  def color
    ::Term::ANSIColor
  end
end

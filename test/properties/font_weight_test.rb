require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class FontWeightTest < MiniTest::Unit::TestCase
  def test_can_embolden_a_line
    test_line = 'this is a test line'

    assert_equal "#{color.bold}#{test_line}#{color.reset}", process(:bold, 'test', test_line)
    assert_equal test_line, process(:normal, 'test', test_line)
    assert_equal test_line, process(:invalid, 'test', test_line)
  end

  private

  def process(value, selector, line)
    sub_engine = ::Styles::SubEngines::Color.new
    line = ::Styles::Line.new(line, [::Styles::Properties::FontWeight.new(value, selector)])
    sub_engine.process(line).to_s
  end

  def color
    ::Term::ANSIColor
  end
end

require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class FontWeightTest < MiniTest::Unit::TestCase
  def test_can_embolden_a_line
    test_line = 'this is a test line'

    assert_equal "#{color.bold}#{test_line}#{color.reset}", apply(:bold, test_line)
    assert_equal test_line, apply(:normal, test_line)
    assert_equal test_line, apply(:invalid, test_line)

    assert_equal "#{color.bold}#{test_line}#{color.reset}", process_with_sub_engine(:bold, test_line)
    assert_equal test_line, process_with_sub_engine(:normal, test_line)
    assert_equal test_line, process_with_sub_engine(:invalid, test_line)
  end

  private

  def apply(value, line)
    ::Styles::Properties::FontWeight.new(value).apply(line)
  end

  def process_with_sub_engine(value, line)
    sub_engine = ::Styles::SubEngines::Color.new
    sub_engine.process [::Styles::Properties::FontWeight.new(value)], line
  end

  def color
    ::Term::ANSIColor
  end
end

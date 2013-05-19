require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class FontWeightTest < MiniTest::Unit::TestCase
  def test_can_embolden_a_line
    test_line = 'this is a test line'

    assert_equal "#{color.bold}#{test_line}#{color.reset}", process('test', :bold, test_line)
    assert_equal test_line, process('test', :normal, test_line)
    assert_equal test_line, process('test', :invalid, test_line)
  end

  private

  def process(selector, value, line)
    sub_engine = ::Styles::SubEngines::Color.new
    line = ::Styles::Line.new(line, [::Styles::Properties::FontWeight.new(selector, :font_weight, value)])
    sub_engine.process(line).to_s
  end

  def color
    ::Term::ANSIColor
  end
end

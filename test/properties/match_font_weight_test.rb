require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class MatchFontWeightTest < MiniTest::Unit::TestCase
  def test_can_embolden_a_match
    test_line = 'this is a test line'

    assert_equal "this is a #{color.bold}test#{color.reset} line", process('test', :bold, test_line)
    assert_equal "this is a #{color.bold}test#{color.reset} line", process(/test/, :bold, test_line)
    assert_equal test_line, process('test', :normal, test_line)
    assert_equal test_line, process(/test/, :normal, test_line)
    assert_equal test_line, process('test', :invalid, test_line)
  end

  def test_can_embolden_multiple_matches
    test_line = 'this is another test line'
    assert_equal "this is #{color.bold}another#{color.reset} #{color.bold}test#{color.reset} line",
      process(/(another) (test)/, [:bold, :bold], test_line)
    assert_equal "this is #{color.bold}another#{color.reset} test line",
      process(/(another) (test)/, [:bold, :normal], test_line)
  end

  private

  def process(selector, value, line)
    sub_engine = ::Styles::SubEngines::Color.new
    line = ::Styles::Line.new(line, [::Styles::Properties::MatchFontWeight.new(selector, :match_font_weight, value)])
    sub_engine.process(line).to_s
  end

  def color
    ::Term::ANSIColor
  end
end

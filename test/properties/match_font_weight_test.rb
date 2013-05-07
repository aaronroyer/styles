require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class MatchFontWeightTest < MiniTest::Unit::TestCase
  def test_can_embolden_a_match
    test_line = 'this is a test line'

    assert_equal "this is a #{color.bold}test#{color.reset} line", process(:bold, 'test', test_line)
    assert_equal "this is a #{color.bold}test#{color.reset} line", process(:bold, /test/, test_line)
    assert_equal test_line, process(:normal, 'test', test_line)
    assert_equal test_line, process(:normal, /test/, test_line)
    assert_equal test_line, process(:invalid, 'test', test_line)
  end

  def test_can_embolden_multiple_matches
    test_line = 'this is another test line'
    assert_equal "this is #{color.bold}another#{color.reset} #{color.bold}test#{color.reset} line",
      process([:bold, :bold], /(another) (test)/, test_line)
    assert_equal "this is #{color.bold}another#{color.reset} test line",
      process([:bold, :normal], /(another) (test)/, test_line)
  end

  private

  def process(value, selector, line)
    sub_engine = ::Styles::SubEngines::Color.new
    sub_engine.process [::Styles::Properties::MatchFontWeight.new(value, selector)], line
  end

  def color
    ::Term::ANSIColor
  end
end

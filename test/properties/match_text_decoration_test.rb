require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class MatchTextDecorationTest < MiniTest::Unit::TestCase
  def test_decorate_match_text
    test_line = 'this is a test line'

    assert_equal "this is a #{color.underline}test#{color.reset} line", process('test', :underline, test_line)
    assert_equal "this is a #{color.strikethrough}test#{color.reset} line", process('test', :strikethrough, test_line)
    assert_equal "this is a #{color.strikethrough}test#{color.reset} line", process('test', :line_through, test_line)
    assert_equal "this is a #{color.blink}test#{color.reset} line", process('test', :blink, test_line)
    assert_equal "this is a #{color.underline}test#{color.reset} line", process(/test/, :underline, test_line)
    assert_equal "this is a #{color.underline}test#{color.reset} line", process(/(test)/, :underline, test_line)
    assert_equal test_line, process('test', :none, test_line)
    assert_equal test_line, process('test', :invalid, test_line)
  end

  def test_decorate_multiple_matches
    test_line = 'this is a another test line'

    assert_equal "this is a #{color.underline}another#{color.reset} #{color.strikethrough}test#{color.reset} line",
      process(/(another) (test)/, [:underline, :strikethrough], test_line)
    assert_equal "this is a #{color.underline}another#{color.reset} test line",
      process(/(another) (test)/, [:underline, :none], test_line)
  end

  private

  def process(selector, value, line)
    sub_engine = ::Styles::SubEngines::Color.new
    line = ::Styles::Line.new(line, [::Styles::Properties::MatchTextDecoration.new(selector, :match_text_decoration, value)])
    sub_engine.process(line).to_s
  end

  def color
    ::Term::ANSIColor
  end
end

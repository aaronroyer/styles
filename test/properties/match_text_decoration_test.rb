require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class MatchTextDecorationTest < MiniTest::Unit::TestCase
  def test_decorate_match_text
    test_line = 'this is a test line'

    assert_equal "this is a #{color.underline}test#{color.reset} line", process(:underline, 'test', test_line)
    assert_equal "this is a #{color.strikethrough}test#{color.reset} line", process(:strikethrough, 'test', test_line)
    assert_equal "this is a #{color.strikethrough}test#{color.reset} line", process(:line_through, 'test', test_line)
    assert_equal "this is a #{color.blink}test#{color.reset} line", process(:blink, 'test', test_line)
    assert_equal "this is a #{color.underline}test#{color.reset} line", process(:underline, /test/, test_line)
    assert_equal "this is a #{color.underline}test#{color.reset} line", process(:underline, /(test)/, test_line)
    assert_equal test_line, process(:none, 'test', test_line)
    assert_equal test_line, process(:invalid, 'test', test_line)
  end

  def test_decorate_multiple_matches
    test_line = 'this is a another test line'

    assert_equal "this is a #{color.underline}another#{color.reset} #{color.strikethrough}test#{color.reset} line",
      process([:underline, :strikethrough], /(another) (test)/, test_line)
    assert_equal "this is a #{color.underline}another#{color.reset} test line",
      process([:underline, :none], /(another) (test)/, test_line)
  end

  private

  def process(value, selector, line)
    sub_engine = ::Styles::SubEngines::Color.new
    line = ::Styles::Line.new(line, [::Styles::Properties::MatchTextDecoration.new(value, selector)])
    sub_engine.process(line).to_s
  end

  def color
    ::Term::ANSIColor
  end
end

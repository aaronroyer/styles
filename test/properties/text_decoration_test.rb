require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class TextDecorationTest < MiniTest::Unit::TestCase
  def test_decorate_text
    test_line = 'this is a test line'

    assert_equal "#{color.underline}#{test_line}#{color.reset}", process('test', :underline, test_line)
    assert_equal "#{color.strikethrough}#{test_line}#{color.reset}", process('test', :strikethrough, test_line)
    assert_equal "#{color.strikethrough}#{test_line}#{color.reset}", process('test', :line_through, test_line)
    assert_equal test_line, process('test', :none, test_line)
  end

  private

  def process(selector, value, line)
    sub_engine = ::Styles::SubEngines::Color.new
    line = ::Styles::Line.new(line, [::Styles::Properties::TextDecoration.new(selector, :text_decoration, value)])
    sub_engine.process(line).to_s
  end

  def color
    ::Term::ANSIColor
  end
end

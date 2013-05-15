require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class TextDecorationTest < MiniTest::Unit::TestCase
  def test_decorate_text
    test_line = 'this is a test line'

    assert_equal "#{color.underline}#{test_line}#{color.reset}", process_with_sub_engine(:underline, 'test', test_line)
    assert_equal "#{color.strikethrough}#{test_line}#{color.reset}", process_with_sub_engine(:strikethrough, 'test', test_line)
    assert_equal "#{color.strikethrough}#{test_line}#{color.reset}", process_with_sub_engine(:line_through, 'test', test_line)
    assert_equal test_line, process_with_sub_engine(:none, 'test', test_line)
  end

  private

  def process_with_sub_engine(value, selector, line)
    sub_engine = ::Styles::SubEngines::Color.new
    line = ::Styles::Line.new(line, [::Styles::Properties::TextDecoration.new(value, selector)])
    sub_engine.process(line).to_s
  end

  def color
    ::Term::ANSIColor
  end
end

require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class TextDecorationTest < MiniTest::Unit::TestCase
  def test_decorate_text
    test_line = 'this is a test line'

    assert_equal "#{color.underline}#{test_line}#{color.reset}", apply(:underline, test_line)
    assert_equal "#{color.strikethrough}#{test_line}#{color.reset}", apply(:strikethrough, test_line)
    assert_equal "#{color.strikethrough}#{test_line}#{color.reset}", apply(:line_through, test_line)
    assert_equal test_line, apply(:none, test_line)

    assert_equal "#{color.underline}#{test_line}#{color.reset}", process_with_sub_engine(:underline, test_line)
    assert_equal "#{color.strikethrough}#{test_line}#{color.reset}", process_with_sub_engine(:strikethrough, test_line)
    assert_equal "#{color.strikethrough}#{test_line}#{color.reset}", process_with_sub_engine(:line_through, test_line)
    assert_equal test_line, process_with_sub_engine(:none, test_line)
  end

  private

  def apply(value, line)
    ::Styles::Properties::TextDecoration.new(value).apply(line)
  end

  def process_with_sub_engine(value, line)
    sub_engine = ::Styles::SubEngines::Color.new
    sub_engine.process [::Styles::Properties::TextDecoration.new(value)], line
  end

  def color
    ::Term::ANSIColor
  end
end

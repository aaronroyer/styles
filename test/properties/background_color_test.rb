require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class BackgroundColorTest < MiniTest::Unit::TestCase
  def test_applies_correct_background_colors_to_lines
    test_line = 'this is a test line, to be background colored'

    assert_equal "#{color.on_blue}#{test_line}#{color.reset}", apply(:blue, test_line)
    assert_equal "#{color.on_cyan}#{test_line}#{color.reset}", apply(:cyan, test_line)

    assert_equal "#{color.on_blue}#{test_line}#{color.reset}", process_with_sub_engine(:blue, test_line)
    assert_equal "#{color.on_cyan}#{test_line}#{color.reset}", process_with_sub_engine(:cyan, test_line)
  end

  def test_works_with_on_prefixed_colors
    test_line = 'this is a test line, to be background colored'

    assert_equal "#{color.on_red}#{test_line}#{color.reset}", apply(:on_red, test_line)
    assert_equal "#{color.on_cyan}#{test_line}#{color.reset}", apply(:on_cyan, test_line)

    assert_equal "#{color.on_red}#{test_line}#{color.reset}", process_with_sub_engine(:on_red, test_line)
    assert_equal "#{color.on_cyan}#{test_line}#{color.reset}", process_with_sub_engine(:on_cyan, test_line)
  end

  def test_line_passes_through_with_invalid_color
    test_line = 'this is a test line, to be colored?'
    assert_equal test_line, apply(:sunshine, test_line)
    assert_equal test_line, process_with_sub_engine(:sunshine, test_line)
  end

  private

  def apply(value, line)
    ::Styles::Properties::BackgroundColor.new(value).apply(line)
  end

  def process_with_sub_engine(value, line)
    sub_engine = ::Styles::SubEngines::Color.new
    sub_engine.process [::Styles::Properties::BackgroundColor.new(value)], line
  end

  def color
    ::Term::ANSIColor
  end
end

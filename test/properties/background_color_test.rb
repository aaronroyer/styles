require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class BackgroundColorTest < MiniTest::Unit::TestCase
  def test_applies_correct_background_colors_to_lines
    test_line = 'this is a test line, to be background colored'

    assert_equal "#{color.on_blue}#{test_line}#{color.reset}", process_with_sub_engine(:blue, 'test', test_line)
    assert_equal "#{color.on_cyan}#{test_line}#{color.reset}", process_with_sub_engine(:cyan, 'test', test_line)
    assert_equal test_line, process_with_sub_engine(:none, 'test', test_line)
  end

  def test_works_with_on_prefixed_colors
    test_line = 'this is a test line, to be background colored'

    assert_equal "#{color.on_red}#{test_line}#{color.reset}", process_with_sub_engine(:on_red, 'test', test_line)
    assert_equal "#{color.on_cyan}#{test_line}#{color.reset}", process_with_sub_engine(:on_cyan, 'test', test_line)
  end

  def test_line_passes_through_with_invalid_color
    test_line = 'this is a test line, to be colored?'
    assert_equal test_line, process_with_sub_engine(:sunshine, 'test', test_line)
  end

  private

  def process_with_sub_engine(value, selector, line)
    sub_engine = ::Styles::SubEngines::Color.new
    line = ::Styles::Line.new(line, [::Styles::Properties::BackgroundColor.new(value, selector)])
    sub_engine.process(line).to_s
  end

  def color
    ::Term::ANSIColor
  end
end

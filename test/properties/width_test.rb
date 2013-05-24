require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class WidthTest < MiniTest::Unit::TestCase
  def setup
    @sub_engine = ::Styles::SubEngines::Layout.new 
  end

  def test_basic_width
    test_line = 'test line'
    assert_equal test_line + (' ' * 11), process('test', 20, test_line)
  end

  def test_applies_background_color_to_full_width
    test_line = "#{color.on_blue}test line#{color.reset}"
    assert_equal "#{test_line}#{color.on_blue}#{(' ' * 11)}#{color.reset}", process_with_bg_color('test', 20, :blue, test_line)
  end

  private

  attr_reader :sub_engine

  def process(selector, value, line)
    line = ::Styles::Line.new(line, [::Styles::Properties::Width.new(selector, :text_align, value)])
    result = sub_engine.process(line)
    result.to_s
  end

  def process_with_bg_color(selector, width_value, bg_color_value, line)
    line = ::Styles::Line.new(line, [
      ::Styles::Properties::Width.new(selector, :width, width_value),
      ::Styles::Properties::BackgroundColor.new(selector, :background_color, bg_color_value)
    ])
    result = sub_engine.process(line)
    result.to_s
  end

  def color
    ::Term::ANSIColor
  end
end

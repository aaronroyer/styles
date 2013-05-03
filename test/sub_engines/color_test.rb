require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class ColorSubEngineTest < MiniTest::Unit::TestCase
  def test_can_combine_line_properties_correctly
    test_line = 'this line has a certain word in it'
    color_prop = ::Styles::Properties::Color.new(:blue, 'word')
    text_decor_prop = ::Styles::Properties::TextDecoration.new(:underline, 'word')
    font_weight_prop = ::Styles::Properties::FontWeight.new(:bold, 'word')
    sub_engine = ::Styles::SubEngines::Color.new

    assert_equal "#{color.blue}#{test_line}#{color.reset}",
      sub_engine.process([color_prop], test_line)

    assert_equal "#{color.blue}#{color.underline}#{test_line}#{color.reset}",
      sub_engine.process([color_prop, text_decor_prop], test_line)

    assert_equal "#{color.blue}#{color.bold}#{color.underline}#{test_line}#{color.reset}",
      sub_engine.process([color_prop, text_decor_prop, font_weight_prop], test_line)
  end

  private

  def color
    ::Term::ANSIColor
  end
end

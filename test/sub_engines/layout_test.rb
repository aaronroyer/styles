require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class LayoutSubEngineTest < MiniTest::Unit::TestCase
  def test_can_combine_padding_and_margin
    test_line = 'here it is'
    margin_left = ::Styles::Properties::Margin.new('here', :margin_left, 2)
    padding_left = ::Styles::Properties::Padding.new('here', :padding_left, 2)
    margin = ::Styles::Properties::Margin.new('here', :margin, 1)
    padding = ::Styles::Properties::Padding.new('here', :padding, 2)

    assert_equal "    #{test_line}", process([margin_left, padding_left], test_line)
    blank = "#{' ' * 16}\n"
    assert_equal "#{blank * 3}   #{test_line}   \n#{blank * 3}", process([margin, padding], test_line)
  end

  def test_can_combine_padding_and_background_color
    # TODO: implement
  end

  private

  def process(properties, line)
    sub_engine.process(::Styles::Line.new(line, properties)).to_s
  end

  def sub_engine
    @sub_engine ||= ::Styles::SubEngines::Layout.new
  end

  def color
    ::Term::ANSIColor
  end
end

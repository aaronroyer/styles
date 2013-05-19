require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class TextAlignTest < MiniTest::Unit::TestCase
  def setup
    @sub_engine = ::Styles::SubEngines::Layout.new 
  end

  def test_left_align
    test_line = 'this is a test line that should be left aligned'

    sub_engine.stubs(:terminal_width).returns(80)
    assert_equal test_line, process('test', :left, test_line)

    sub_engine.stubs(:terminal_width).returns(10)
    assert_equal test_line, process('test', :left, test_line)
  end

  def test_right_align
    test_line = 'this is a test line that should be right aligned'
    test_line_color = "this is a test line that #{color.red}should#{color.reset} be right aligned"

    sub_engine.stubs(:terminal_width).returns(80)
    assert_equal "#{' ' * 32}#{test_line}", process('test', :right, test_line)
    assert_equal "#{' ' * 32}#{test_line_color}", process('test', :right, test_line_color)

    sub_engine.stubs(:terminal_width).returns(10)
    assert_equal test_line, process('test', :right, test_line)
    assert_equal test_line_color, process('test', :right, test_line_color)
  end

  def test_center_align
    test_line = 'this is a test'
    test_line_color = "this is a #{color.blue}test#{color.reset}"

    sub_engine.stubs(:terminal_width).returns(80)
    assert_equal "#{' ' * 33}#{test_line}#{' ' * 33}", process('test', :center, test_line)
    assert_equal "#{' ' * 33}#{test_line_color}#{' ' * 33}", process('test', :center, test_line_color)

    odd_test_line = 'odd'
    sub_engine.stubs(:terminal_width).returns(10)
    assert_equal '   odd    ', process('odd', :center, odd_test_line)

    sub_engine.stubs(:terminal_width).returns(10)
    assert_equal test_line, process('test', :center, test_line)
    assert_equal test_line_color, process('test', :center, test_line_color)
  end

  private

  attr_reader :sub_engine

  def process(selector, value, line)
    line = ::Styles::Line.new(line, [::Styles::Properties::TextAlign.new(selector, :text_align, value)])
    result = sub_engine.process(line)
    result.to_s
  end

  def color
    ::Term::ANSIColor
  end
end


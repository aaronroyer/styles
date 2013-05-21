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

  def test_can_combine_padding_and_border
    test_line = 'here it is'
    s = ::Styles::Properties::Border::SOLID_CHARS

    border = ::Styles::Properties::Border.new('here', :border, :solid)
    padding_1 = ::Styles::Properties::Padding.new('here', :padding, 1)
    padding_2 = ::Styles::Properties::Padding.new('here', :padding, 2)

    output = <<RESULT
#{s[:top_left]}#{s[:top] * (1 + test_line.size + 1)}#{s[:top_right]}
#{s[:left]}#{' ' * (1 + test_line.size + 1)}#{s[:right]}
#{s[:left]} #{test_line} #{s[:right]}
#{s[:left]}#{' ' * (1 + test_line.size + 1)}#{s[:right]}
#{s[:bottom_left]}#{s[:bottom] * (1 + test_line.size + 1)}#{s[:bottom_right]}
RESULT

    assert_equal output, process([padding_1, border], test_line)

    output = <<RESULT
#{s[:top_left]}#{s[:top] * (2 + test_line.size + 2)}#{s[:top_right]}
#{s[:left]}#{' ' * (2 + test_line.size + 2)}#{s[:right]}
#{s[:left]}#{' ' * (2 + test_line.size + 2)}#{s[:right]}
#{s[:left]}  #{test_line}  #{s[:right]}
#{s[:left]}#{' ' * (2 + test_line.size + 2)}#{s[:right]}
#{s[:left]}#{' ' * (2 + test_line.size + 2)}#{s[:right]}
#{s[:bottom_left]}#{s[:bottom] * (2 + test_line.size + 2)}#{s[:bottom_right]}
RESULT

    assert_equal output, process([padding_2, border], test_line)

    output = <<RESULT
#{s[:top_left]}#{s[:top] * (test_line.size + 1)}#{s[:top_right]}
#{s[:left]}#{' ' * (test_line.size + 1)}#{s[:right]}
#{s[:left]}#{' ' * (test_line.size + 1)}#{s[:right]}
#{s[:left]}#{test_line} #{s[:right]}
#{s[:bottom_left]}#{s[:bottom] * (test_line.size + 1)}#{s[:bottom_right]}
RESULT

    top_padding = ::Styles::Properties::Padding.new('here', :padding_top, 2)
    right_padding = ::Styles::Properties::Padding.new('here', :padding_right, 1)
    top_and_right_padding = ::Styles::Properties::Padding.new([top_padding, right_padding])
    assert_equal output, process([top_and_right_padding, border], test_line)
  end

  def test_can_combine_padding_and_margin_and_border
    test_line = 'here it is'
    s = ::Styles::Properties::Border::SOLID_CHARS

    margin_1 = ::Styles::Properties::Margin.new('here', :margin, 1)
    padding_1 = ::Styles::Properties::Padding.new('here', :padding, 1)

    # Add trailing whitespace in a peculiar way so it doesn't get stripped by tools
    output = <<RESULT
#{' ' * (2 + test_line.size + 2)}
 #{s[:top_left]}#{s[:top] * (1 + test_line.size + 1)}#{s[:top_right]}#{' '}
 #{s[:left]}#{' ' * (1 + test_line.size + 1)}#{s[:right]}#{' '}
 #{s[:left]} #{test_line} #{s[:right]}#{' '}
 #{s[:left]}#{' ' * (1 + test_line.size + 1)}#{s[:right]}#{' '}
 #{s[:bottom_left]}#{s[:bottom] * (1 + test_line.size + 1)}#{s[:bottom_right]}#{' '}
#{' ' * (2 + test_line.size + 2)}
RESULT
  end

  def test_can_combine_padding_and_background_color
    # TODO
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

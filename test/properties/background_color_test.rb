require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class BackgroundColorTest < MiniTest::Unit::TestCase
  def test_applies_correct_background_colors_to_lines
    test_line = 'this is a test line, to be background colored'

    assert_equal "#{color.on_blue}#{test_line}#{color.reset}",
      ::Styles::Properties::BackgroundColor.new(:blue).apply(test_line)

    assert_equal "#{color.on_cyan}#{test_line}#{color.reset}",
      ::Styles::Properties::BackgroundColor.new(:cyan).apply(test_line)
  end

  def test_works_with_on_prefixed_colors
    test_line = 'this is a test line, to be background colored'

    assert_equal "#{color.on_red}#{test_line}#{color.reset}",
      ::Styles::Properties::BackgroundColor.new(:on_red).apply(test_line)

    assert_equal "#{color.on_cyan}#{test_line}#{color.reset}",
      ::Styles::Properties::BackgroundColor.new(:on_cyan).apply(test_line)
  end

  def test_line_passes_through_with_invalid_color
    test_line = 'this is a test line, to be colored?'
    assert_equal test_line, ::Styles::Properties::BackgroundColor.new(:sunshine).apply(test_line)
  end

  private

  def color
    ::Term::ANSIColor
  end
end

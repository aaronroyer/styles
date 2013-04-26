require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class MatchColorTest < MiniTest::Unit::TestCase
  def test_applies_correct_colors_to_string_selector_matches
    test_line = 'this is a test line, to be colored'

    assert_equal "this is a #{color.red}test#{color.reset} line, to be colored",
      ::Styles::Properties::MatchColor.new(:red, 'test').apply(test_line)

    assert_equal "#{color.blue}this is#{color.reset} a test line, to be colored",
      ::Styles::Properties::MatchColor.new(:blue, 'this is').apply(test_line)
  end

  def test_applies_correct_colors_to_multiple_string_selector_matches
    assert_equal "#{color.green}the#{color.reset} word #{color.green}the#{color.reset} is repeated",
      ::Styles::Properties::MatchColor.new(:green, 'the').apply('the word the is repeated')
  end

  def test_applies_correct_colors_to_regex_matches
    assert_equal "the number #{color.green}89#{color.reset} is in this line",
      ::Styles::Properties::MatchColor.new(:green, /\d\d/).apply('the number 89 is in this line')
  end

  def test_applies_correct_colors_to_multiple_regex_matches
    assert_equal "the numbers #{color.blue}89#{color.reset} and #{color.blue}22#{color.reset} are in this line",
      ::Styles::Properties::MatchColor.new(:blue, /\d\d/).apply('the numbers 89 and 22 are in this line')
  end

  private

  def color
    ::Term::ANSIColor
  end
end

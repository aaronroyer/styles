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

  def test_can_use_multiple_colors_to_match_groups
    $snap = false
    assert_equal "this has some color: #{color.red}this#{color.reset}",
      ::Styles::Properties::MatchColor.new([:red], /color: (\w+)/).apply('this has some color: this')

    assert_equal "numbers #{color.green}one#{color.reset} and #{color.yellow}two#{color.reset}",
      ::Styles::Properties::MatchColor.new([:green, :yellow], /(one)[\s\w]+(two)/).apply('numbers one and two')

    assert_equal "#{color.cyan}1#{color.reset} #{color.magenta}2#{color.reset} #{color.black}3#{color.reset}",
      ::Styles::Properties::MatchColor.new([:cyan, :magenta, :black], /(\d) (\d) (\d)/).apply('1 2 3')
  end

  def test_applies_colors_correctly_with_different_numbers_of_colors_and_match_groups
    $snap = true
    assert_equal "numbers #{color.green}one#{color.reset} and two",
      ::Styles::Properties::MatchColor.new([:green, :yellow], /(one)[\s\w]+two/).apply('numbers one and two')

    assert_equal "numbers #{color.green}one#{color.reset} and two",
      ::Styles::Properties::MatchColor.new([:green], /(one)[\s\w]+(two)/).apply('numbers one and two')

    assert_equal "numbers #{color.green}one#{color.reset} and #{color.red}two#{color.reset} and three",
      ::Styles::Properties::MatchColor.new([:green, :red], /(one)[\s\w]+(two)[\s\w]+three/).apply('numbers one and two and three')
    $snap = false
  end

  private

  def color
    ::Term::ANSIColor
  end
end

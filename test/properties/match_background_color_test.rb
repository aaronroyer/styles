require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class MatchBackgroundColorTest < MiniTest::Unit::TestCase
  def test_applies_correct_colors_to_string_selector_matches
    test_line = 'this is a test line'

    assert_equal "this is a #{color.on_red}test#{color.reset} line",
      process('test', :red, test_line)
    assert_equal "#{color.on_blue}this is#{color.reset} a test line",
      process('this is', :blue, test_line)
  end

  def test_applies_correct_colors_to_multiple_string_selector_matches
    assert_equal "#{color.on_green}the#{color.reset} word #{color.on_green}the#{color.reset} is repeated",
      process('the', :green, 'the word the is repeated')
  end

  def test_applies_correct_colors_to_regex_matches
    assert_equal "the number #{color.on_green}89#{color.reset} is in this line",
      process(/\d\d/, :green, 'the number 89 is in this line')
  end

  def test_applies_correct_colors_to_multiple_regex_matches
    assert_equal "the numbers #{color.on_blue}89#{color.reset} and #{color.on_blue}22#{color.reset} are in this line",
      process(/\d\d/, :blue, 'the numbers 89 and 22 are in this line')
  end

  def test_can_use_multiple_colors_to_match_groups
    assert_equal "this has some color: #{color.on_red}this#{color.reset}",
      process(/color: (\w+)/, [:red], 'this has some color: this')
    assert_equal "numbers #{color.on_green}one#{color.reset} and #{color.on_yellow}two#{color.reset}",
      process(/(one)[\s\w]+(two)/, [:green, :yellow], 'numbers one and two')
    assert_equal "#{color.on_cyan}1#{color.reset} #{color.on_magenta}2#{color.reset} #{color.on_black}3#{color.reset}",
      process(/(\d) (\d) (\d)/, [:cyan, :magenta, :black], '1 2 3')
  end

  def test_applies_colors_correctly_with_different_numbers_of_colors_and_match_groups
    assert_equal "numbers #{color.on_green}one#{color.reset} and two",
      process(/(one)[\s\w]+two/, [:green, :yellow], 'numbers one and two')
    assert_equal "numbers #{color.on_green}one#{color.reset} and two",
      process(/(one)[\s\w]+(two)/, [:green], 'numbers one and two')
    assert_equal "numbers #{color.on_green}one#{color.reset} and #{color.on_red}two#{color.reset} and three",
      process(/(one)[\s\w]+(two)[\s\w]+three/, [:green, :red], 'numbers one and two and three')
  end

  def test_can_specify_no_color_for_match
    assert_equal 'no color here', process('color', :none, 'no color here')
    assert_equal 'no color here', process(/color/, :none, 'no color here')
  end

  def test_can_specify_no_color_for_match_groups
    assert_equal 'no color here', process(/(color)/, [:none], 'no color here')
    assert_equal "the first and #{color.on_red}second#{color.reset} matches",
      process(/(first)[\s\w]+(second)/, [:none, :red], 'the first and second matches')
    assert_equal "the #{color.on_red}first#{color.reset} and second matches",
      process(/(first)[\s\w]+(second)/, [:red, :none], 'the first and second matches')
  end

  private

  def process(selector, value, line)
    sub_engine = ::Styles::SubEngines::Color.new
    line = ::Styles::Line.new(line, [::Styles::Properties::MatchBackgroundColor.new(selector, :match_background_color, value)])
    sub_engine.process(line).to_s
  end

  def color
    ::Term::ANSIColor
  end
end

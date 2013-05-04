require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class MatchColorTest < MiniTest::Unit::TestCase
  def test_applies_correct_colors_to_string_selector_matches
    test_line = 'this is a test line, to be colored'

    assert_equal "this is a #{color.red}test#{color.reset} line, to be colored",
      apply(:red, 'test', test_line)
    assert_equal "#{color.blue}this is#{color.reset} a test line, to be colored",
      apply(:blue, 'this is', test_line)

    assert_equal "this is a #{color.red}test#{color.reset} line, to be colored",
      process_with_sub_engine(:red, 'test', test_line)
    assert_equal "#{color.blue}this is#{color.reset} a test line, to be colored",
      process_with_sub_engine(:blue, 'this is', test_line)
  end

  def test_applies_correct_colors_to_multiple_string_selector_matches
    assert_equal "#{color.green}the#{color.reset} word #{color.green}the#{color.reset} is repeated",
      apply(:green, 'the', 'the word the is repeated')

    assert_equal "#{color.green}the#{color.reset} word #{color.green}the#{color.reset} is repeated",
      process_with_sub_engine(:green, 'the', 'the word the is repeated')
  end

  def test_applies_correct_colors_to_regex_matches
    assert_equal "the number #{color.green}89#{color.reset} is in this line",
      apply(:green, /\d\d/, 'the number 89 is in this line')

    assert_equal "the number #{color.green}89#{color.reset} is in this line",
      process_with_sub_engine(:green, /\d\d/, 'the number 89 is in this line')
  end

  def test_applies_correct_colors_to_multiple_regex_matches
    assert_equal "the numbers #{color.blue}89#{color.reset} and #{color.blue}22#{color.reset} are in this line",
      apply(:blue, /\d\d/, 'the numbers 89 and 22 are in this line')

    assert_equal "the numbers #{color.blue}89#{color.reset} and #{color.blue}22#{color.reset} are in this line",
      process_with_sub_engine(:blue, /\d\d/, 'the numbers 89 and 22 are in this line')
  end

  def test_can_use_multiple_colors_to_match_groups
    assert_equal "this has some color: #{color.red}this#{color.reset}",
      apply([:red], /color: (\w+)/, 'this has some color: this')
    assert_equal "numbers #{color.green}one#{color.reset} and #{color.yellow}two#{color.reset}",
      apply([:green, :yellow], /(one)[\s\w]+(two)/, 'numbers one and two')
    assert_equal "#{color.cyan}1#{color.reset} #{color.magenta}2#{color.reset} #{color.black}3#{color.reset}",
      apply([:cyan, :magenta, :black], /(\d) (\d) (\d)/, '1 2 3')

    assert_equal "this has some color: #{color.red}this#{color.reset}",
      process_with_sub_engine([:red], /color: (\w+)/, 'this has some color: this')
    assert_equal "numbers #{color.green}one#{color.reset} and #{color.yellow}two#{color.reset}",
      process_with_sub_engine([:green, :yellow], /(one)[\s\w]+(two)/, 'numbers one and two')
    assert_equal "#{color.cyan}1#{color.reset} #{color.magenta}2#{color.reset} #{color.black}3#{color.reset}",
      process_with_sub_engine([:cyan, :magenta, :black], /(\d) (\d) (\d)/, '1 2 3')
  end

  def test_applies_colors_correctly_with_different_numbers_of_colors_and_match_groups
    assert_equal "numbers #{color.green}one#{color.reset} and two",
      apply([:green, :yellow], /(one)[\s\w]+two/, 'numbers one and two')
    assert_equal "numbers #{color.green}one#{color.reset} and two",
      apply([:green], /(one)[\s\w]+(two)/, 'numbers one and two')
    assert_equal "numbers #{color.green}one#{color.reset} and #{color.red}two#{color.reset} and three",
      apply([:green, :red], /(one)[\s\w]+(two)[\s\w]+three/, 'numbers one and two and three')

    assert_equal "numbers #{color.green}one#{color.reset} and two",
      process_with_sub_engine([:green, :yellow], /(one)[\s\w]+two/, 'numbers one and two')
    assert_equal "numbers #{color.green}one#{color.reset} and two",
      process_with_sub_engine([:green], /(one)[\s\w]+(two)/, 'numbers one and two')
    assert_equal "numbers #{color.green}one#{color.reset} and #{color.red}two#{color.reset} and three",
      process_with_sub_engine([:green, :red], /(one)[\s\w]+(two)[\s\w]+three/, 'numbers one and two and three')
  end

  private

  def apply(value, selector, line)
    ::Styles::Properties::MatchColor.new(value, selector).apply(line)
  end

  def process_with_sub_engine(value, selector, line)
    sub_engine = ::Styles::SubEngines::Color.new
    sub_engine.process [::Styles::Properties::MatchColor.new(value, selector)], line
  end

  def color
    ::Term::ANSIColor
  end
end

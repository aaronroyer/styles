require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class ColorSubEngineTest < MiniTest::Unit::TestCase
  def test_can_combine_line_properties
    test_line = 'this line has a certain word in it'
    color_prop = ::Styles::Properties::Color.new(:blue, 'word')
    text_decor_prop = ::Styles::Properties::TextDecoration.new(:underline, 'word')
    font_weight_prop = ::Styles::Properties::FontWeight.new(:bold, 'word')
    no_back_color_prop = ::Styles::Properties::BackgroundColor.new(:none, 'word')

    assert_equal "#{color.blue}#{test_line}#{color.reset}", process([color_prop], test_line)

    assert_equal "#{color.blue}#{color.underline}#{test_line}#{color.reset}",
      process([color_prop, text_decor_prop], test_line)

    assert_equal "#{color.blue}#{color.bold}#{color.underline}#{test_line}#{color.reset}",
      process([color_prop, text_decor_prop, font_weight_prop], test_line)

    assert_equal "#{color.blue}#{test_line}#{color.reset}",
      process([color_prop, no_back_color_prop], test_line)
  end

  def test_can_combine_line_and_match_properties
    test_line = 'this line has a certain word in it'
    color_prop = ::Styles::Properties::Color.new(:blue, 'word')
    bg_color_prop = ::Styles::Properties::BackgroundColor.new(:blue, 'word')
    string_match_color_prop = ::Styles::Properties::MatchColor.new(:green, 'word')
    string_match_no_color_prop = ::Styles::Properties::MatchColor.new(:none, 'word')
    regex_match_color_prop = ::Styles::Properties::MatchColor.new(:green, /word/)
    regex_match_no_color_prop = ::Styles::Properties::MatchColor.new(:none, /word/)

    assert_equal "#{color.blue}this line has a certain #{color.green}word#{color.blue} in it#{color.reset}",
      process([color_prop, string_match_color_prop], test_line)
    assert_equal "#{color.blue}this line has a certain #{color.green}word#{color.blue} in it#{color.reset}",
      process([color_prop, regex_match_color_prop], test_line)

    assert_equal "#{color.on_blue}this line has a certain #{color.green}word#{color.reset}#{color.on_blue} in it#{color.reset}",
      process([bg_color_prop, string_match_color_prop], test_line)
    assert_equal "#{color.on_blue}this line has a certain #{color.green}word#{color.reset}#{color.on_blue} in it#{color.reset}",
      process([bg_color_prop, regex_match_color_prop], test_line)

    assert_equal "#{color.blue}this line has a certain #{color.reset}word#{color.blue} in it#{color.reset}",
      process([color_prop, string_match_no_color_prop], test_line)
    assert_equal "#{color.blue}this line has a certain #{color.reset}word#{color.blue} in it#{color.reset}",
      process([color_prop, regex_match_no_color_prop], test_line)
  end

  def test_can_combine_line_and_match_properties_with_multiple_matches
    test_line = 'this line has the number 12 and the number 89 in it'
    color_prop = ::Styles::Properties::Color.new(:blue, 'line')
    string_match_color_prop = ::Styles::Properties::MatchColor.new(:green, 'number')
    regex_match_color_prop = ::Styles::Properties::MatchColor.new(:green, /\d\d/)

    assert_equal "#{color.blue}this line has the #{color.green}number#{color.blue}" +
      " 12 and the #{color.green}number#{color.blue} 89 in it#{color.reset}",
      process([color_prop, string_match_color_prop], test_line)

    assert_equal "#{color.blue}this line has the number #{color.green}12#{color.blue}" +
      " and the number #{color.green}89#{color.blue} in it#{color.reset}",
      process([color_prop, regex_match_color_prop], test_line)
  end

  def test_can_combine_line_and_match_properties_with_multiple_match_colors
    test_line = 'this line has the number 12 in it'
    color_prop = ::Styles::Properties::Color.new(:blue, 'line')
    regex_match_color_prop = ::Styles::Properties::MatchColor.new([:green, :red], /(number) (\d\d)/)
    regex_match_color_prop_with_none = ::Styles::Properties::MatchColor.new([:green, :none], /(number) (\d\d)/)

    assert_equal "#{color.blue}this line has the #{color.green}number#{color.blue}" +
      " #{color.red}12#{color.blue} in it#{color.reset}",
      process([color_prop, regex_match_color_prop], test_line)
    assert_equal "#{color.blue}this line has the #{color.green}number#{color.blue}" +
      " #{color.reset}12#{color.blue} in it#{color.reset}",
      process([color_prop, regex_match_color_prop_with_none], test_line)
  end

  def test_can_combine_misc_line_and_match_properties
    test_line = 'this line has the number 12 in it'
    underline_prop = ::Styles::Properties::TextDecoration.new(:underline, 'number')
    blink_match_prop = ::Styles::Properties::MatchTextDecoration.new(:blink, 'number')

    assert_equal "#{color.underline}this line has the #{color.reset}#{color.blink}number#{color.reset}" +
      "#{color.underline} 12 in it#{color.reset}",
      process([underline_prop, blink_match_prop], test_line)
  end

  def test_background_colors_for_line_applies_to_matches_if_no_background_color_of_their_own
    test_line = 'this line has a certain word in it'
    bg_color_prop = ::Styles::Properties::BackgroundColor.new(:blue, 'word')
    string_match_color_prop = ::Styles::Properties::MatchColor.new(:green, 'word')
    regex_match_color_prop = ::Styles::Properties::MatchColor.new(:green, /word/)
    regex_groups_match_color_prop = ::Styles::Properties::MatchColor.new([:green, :red], /(certain) (word)/)
    regex_groups_match_color_prop_with_none = ::Styles::Properties::MatchColor.new([:green, :none], /(certain) (word)/)

    assert_equal "#{color.on_blue}this line has a certain #{color.green}word#{color.reset}#{color.on_blue} in it#{color.reset}",
      process([bg_color_prop, string_match_color_prop], test_line)
    assert_equal "#{color.on_blue}this line has a certain #{color.green}word#{color.reset}#{color.on_blue} in it#{color.reset}",
      process([bg_color_prop, regex_match_color_prop], test_line)

    assert_equal "#{color.on_blue}this line has a #{color.green}certain#{color.reset}#{color.on_blue}" +
      " #{color.red}word#{color.reset}#{color.on_blue} in it#{color.reset}",
      process([bg_color_prop, regex_groups_match_color_prop], test_line)
    assert_equal "#{color.on_blue}this line has a #{color.green}certain#{color.reset}#{color.on_blue}" +
      " word in it#{color.reset}",
      process([bg_color_prop, regex_groups_match_color_prop_with_none], test_line)
  end

  def test_color_for_line_applies_to_matches_if_no_color_of_their_own
    test_line = 'this line has a certain word in it'
    bg_color_prop = ::Styles::Properties::Color.new(:blue, 'word')
    string_match_color_prop = ::Styles::Properties::MatchBackgroundColor.new(:green, 'word')
    regex_match_color_prop = ::Styles::Properties::MatchBackgroundColor.new(:green, /word/)
    regex_groups_match_color_prop = ::Styles::Properties::MatchBackgroundColor.new([:green, :red], /(certain) (word)/)
    regex_groups_match_color_prop_with_none = ::Styles::Properties::MatchBackgroundColor.new([:green, :none], /(certain) (word)/)

    assert_equal "#{color.blue}this line has a certain #{color.on_green}word#{color.reset}#{color.blue} in it#{color.reset}",
      process([bg_color_prop, string_match_color_prop], test_line)
    assert_equal "#{color.blue}this line has a certain #{color.on_green}word#{color.reset}#{color.blue} in it#{color.reset}",
      process([bg_color_prop, regex_match_color_prop], test_line)

    assert_equal "#{color.blue}this line has a #{color.on_green}certain#{color.reset}#{color.blue}" +
      " #{color.on_red}word#{color.reset}#{color.blue} in it#{color.reset}",
      process([bg_color_prop, regex_groups_match_color_prop], test_line)
    assert_equal "#{color.blue}this line has a #{color.on_green}certain#{color.reset}#{color.blue} word in it#{color.reset}",
      process([bg_color_prop, regex_groups_match_color_prop_with_none], test_line)
  end

  private

  def process(*args)
    sub_engine.process(*args)
  end

  def sub_engine
    @sub_engine ||= ::Styles::SubEngines::Color.new
  end

  def color
    ::Term::ANSIColor
  end
end

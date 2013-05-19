require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class ColorSubEngineTest < MiniTest::Unit::TestCase
  def test_can_combine_line_properties
    test_line = 'this line has a certain word in it'
    color_prop = ::Styles::Properties::Color.new('word', :color, :blue)
    text_decor_prop = ::Styles::Properties::TextDecoration.new('word', :text_decoration, :underline)
    font_weight_prop = ::Styles::Properties::FontWeight.new('word', :font_weight, :bold)
    no_back_color_prop = ::Styles::Properties::BackgroundColor.new('word', :background_color, :none)

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
    color_prop = ::Styles::Properties::Color.new('word', :color, :blue)
    bg_color_prop = ::Styles::Properties::BackgroundColor.new('word', :background_color, :blue)
    string_match_color_prop = ::Styles::Properties::MatchColor.new('word', :match_color, :green)
    string_match_no_color_prop = ::Styles::Properties::MatchColor.new('word', :match_color, :none)
    regex_match_color_prop = ::Styles::Properties::MatchColor.new(/word/, :match_color, :green)
    regex_match_no_color_prop = ::Styles::Properties::MatchColor.new(/word/, :match_color, :none)

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
    color_prop = ::Styles::Properties::Color.new('line', :color, :blue)
    string_match_color_prop = ::Styles::Properties::MatchColor.new('number', :match_color, :green)
    regex_match_color_prop = ::Styles::Properties::MatchColor.new(/\d\d/, :match_color, :green)

    assert_equal "#{color.blue}this line has the #{color.green}number#{color.blue}" +
      " 12 and the #{color.green}number#{color.blue} 89 in it#{color.reset}",
      process([color_prop, string_match_color_prop], test_line)

    assert_equal "#{color.blue}this line has the number #{color.green}12#{color.blue}" +
      " and the number #{color.green}89#{color.blue} in it#{color.reset}",
      process([color_prop, regex_match_color_prop], test_line)
  end

  def test_can_combine_line_and_match_properties_with_multiple_match_colors
    test_line = 'this line has the number 12 in it'
    color_prop = ::Styles::Properties::Color.new('line', :color, :blue)
    regex_match_color_prop = ::Styles::Properties::MatchColor.new(/(number) (\d\d)/, :match_color, [:green, :red])
    regex_match_color_prop_with_none = ::Styles::Properties::MatchColor.new(/(number) (\d\d)/, :match_color, [:green, :none])

    assert_equal "#{color.blue}this line has the #{color.green}number#{color.blue}" +
      " #{color.red}12#{color.blue} in it#{color.reset}",
      process([color_prop, regex_match_color_prop], test_line)
    assert_equal "#{color.blue}this line has the #{color.green}number#{color.blue}" +
      " #{color.reset}12#{color.blue} in it#{color.reset}",
      process([color_prop, regex_match_color_prop_with_none], test_line)
  end

  def test_can_combine_misc_line_and_match_properties
    test_line = 'this line has the number 12 in it'
    underline_prop = ::Styles::Properties::TextDecoration.new('number', :text_decoration, :underline)
    blink_match_prop = ::Styles::Properties::MatchTextDecoration.new('number', :match_text_decoration, :blink)

    assert_equal "#{color.underline}this line has the #{color.reset}#{color.blink}number#{color.reset}" +
      "#{color.underline} 12 in it#{color.reset}",
      process([underline_prop, blink_match_prop], test_line)
  end

  def test_background_colors_for_line_applies_to_matches_if_no_background_color_of_their_own
    test_line = 'this line has a certain word in it'
    bg_color_prop = ::Styles::Properties::BackgroundColor.new('word', :background_color, :blue)
    string_match_color_prop = ::Styles::Properties::MatchColor.new('word', :match_color, :green)
    regex_match_color_prop = ::Styles::Properties::MatchColor.new(/word/, :match_color, :green)
    regex_groups_match_color_prop = ::Styles::Properties::MatchColor.new(/(certain) (word)/, :match_color, [:green, :red])
    regex_groups_match_color_prop_with_none = ::Styles::Properties::MatchColor.new(/(certain) (word)/, :match_color, [:green, :none])

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
    bg_color_prop = ::Styles::Properties::Color.new('word', :color, :blue)
    string_match_color_prop = ::Styles::Properties::MatchBackgroundColor.new('word', :match_background_color, :green)
    regex_match_color_prop = ::Styles::Properties::MatchBackgroundColor.new(/word/, :match_background_color, :green)
    regex_groups_match_color_prop = ::Styles::Properties::MatchBackgroundColor.new(/(certain) (word)/,
      :match_background_color, [:green, :red])
    regex_groups_match_color_prop_with_none = ::Styles::Properties::MatchBackgroundColor.new(/(certain) (word)/,
      :match_background_color, [:green, :none])

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

  def process(properties, line)
    sub_engine.process(::Styles::Line.new(line, properties)).to_s
  end

  def sub_engine
    @sub_engine ||= ::Styles::SubEngines::Color.new
  end

  def color
    ::Term::ANSIColor
  end
end

require File.expand_path('../../test_helper', __FILE__)
require 'term/ansicolor'

class ColorSubEngineTest < MiniTest::Unit::TestCase
  def test_can_combine_line_properties
    test_line = 'this line has a certain word in it'
    color_prop = ::Styles::Properties::Color.new(:blue, 'word')
    text_decor_prop = ::Styles::Properties::TextDecoration.new(:underline, 'word')
    font_weight_prop = ::Styles::Properties::FontWeight.new(:bold, 'word')
    no_back_color_prop = ::Styles::Properties::BackgroundColor.new(:none, 'word')
    sub_engine = ::Styles::SubEngines::Color.new

    assert_equal "#{color.blue}#{test_line}#{color.reset}",
      sub_engine.process([color_prop], test_line)

    assert_equal "#{color.blue}#{color.underline}#{test_line}#{color.reset}",
      sub_engine.process([color_prop, text_decor_prop], test_line)

    assert_equal "#{color.blue}#{color.bold}#{color.underline}#{test_line}#{color.reset}",
      sub_engine.process([color_prop, text_decor_prop, font_weight_prop], test_line)

    assert_equal test_line, sub_engine.process([no_back_color_prop], test_line)
  end

  def test_can_combine_line_and_match_properties
    test_line = 'this line has a certain word in it'
    color_prop = ::Styles::Properties::Color.new(:blue, 'word')
    string_match_color_prop = ::Styles::Properties::MatchColor.new(:green, 'word')
    regex_match_color_prop = ::Styles::Properties::MatchColor.new(:green, /word/)
    sub_engine = ::Styles::SubEngines::Color.new

    assert_equal "#{color.blue}this line has a certain #{color.reset}#{color.green}word#{color.reset}#{color.blue} in it#{color.reset}",
      sub_engine.process([color_prop, string_match_color_prop], test_line)
    assert_equal "#{color.blue}this line has a certain #{color.reset}#{color.green}word#{color.reset}#{color.blue} in it#{color.reset}",
      sub_engine.process([color_prop, regex_match_color_prop], test_line)
  end

  def test_can_combine_line_and_match_properties_with_multiple_matches
    test_line = 'this line has the number 12 and the number 89 in it'
    color_prop = ::Styles::Properties::Color.new(:blue, 'line')
    string_match_color_prop = ::Styles::Properties::MatchColor.new(:green, 'number')
    regex_match_color_prop = ::Styles::Properties::MatchColor.new(:green, /\d\d/)
    sub_engine = ::Styles::SubEngines::Color.new

    assert_equal "#{color.blue}this line has the #{color.reset}#{color.green}number#{color.reset}#{color.blue}" +
      " 12 and the #{color.reset}#{color.green}number#{color.reset}#{color.blue} 89 in it#{color.reset}",
      sub_engine.process([color_prop, string_match_color_prop], test_line)

    assert_equal "#{color.blue}this line has the number #{color.reset}#{color.green}12#{color.reset}#{color.blue}" +
      " and the number #{color.reset}#{color.green}89#{color.reset}#{color.blue} in it#{color.reset}",
      sub_engine.process([color_prop, regex_match_color_prop], test_line)
  end

  def test_can_combine_line_and_match_properties_with_multiple_match_colors
    test_line = 'this line has the number 12 in it'
    color_prop = ::Styles::Properties::Color.new(:blue, 'line')
    regex_match_color_prop = ::Styles::Properties::MatchColor.new([:green, :red], /(number) (\d\d)/)
    sub_engine = ::Styles::SubEngines::Color.new

    assert_equal "#{color.blue}this line has the #{color.reset}#{color.green}number#{color.reset}#{color.blue}" +
      " #{color.reset}#{color.red}12#{color.reset}#{color.blue} in it#{color.reset}",
      sub_engine.process([color_prop, regex_match_color_prop], test_line)
  end

  def test_background_colors_for_line_applies_to_matches_if_no_background_color_of_their_own
    test_line = 'this line has a certain word in it'
    color_prop = ::Styles::Properties::BackgroundColor.new(:blue, 'word')
    string_match_color_prop = ::Styles::Properties::MatchColor.new(:green, 'word')
    regex_match_color_prop = ::Styles::Properties::MatchColor.new(:green, /word/)
    sub_engine = ::Styles::SubEngines::Color.new

    # assert_equal "#{color.on_blue}this line has a certain #{color.green}word#{color.reset}#{color.on_blue} in it#{color.reset}",
    #   sub_engine.process([color_prop, string_match_color_prop], test_line)
    # assert_equal "#{color.blue}this line has a certain #{color.green}word#{color.reset}#{color.blue} in it#{color.reset}",
    #   sub_engine.process([color_prop, regex_match_color_prop], test_line)
  end

  private

  def color
    ::Term::ANSIColor
  end
end

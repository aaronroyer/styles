require File.expand_path('../test_helper', __FILE__)
require 'term/ansicolor'

class ColorsTest < MiniTest::Unit::TestCase

  def test_can_access_basic_colors_with_brackets
    assert_equal ansi.red, c[:red]
    assert_equal ansi.blue, c[:blue]
    assert_equal ansi.on_cyan, c[:on_cyan]

    assert_nil c[:bogus]
  end

  def test_can_access_compound_colors_with_brackets
    assert_equal ansi.on_white + ansi.red , c[:red_on_white]
    assert_equal ansi.blue + ansi.on_blue, c[:blue_on_blue]

    assert_nil c[:red_on_bogus]
    assert_nil c[:bogus_on_bogus]
    assert_nil c[:bogus_on_red]
  end

  def test_can_access_multiple_colors_with_brackets
    assert_equal ansi.red + ansi.white, c[:red, :white]
    assert_equal ansi.blue + ansi.red + ansi.white, c[:red, :white, :blue]
    assert_equal ansi.on_blue + ansi.red + ansi.white, c[:red, :white_on_blue]
  end

  def test_can_use_arrays_of_colors_with_brackets
    assert_equal ansi.red + ansi.white, c[[:red, :white]]
    assert_equal ansi.blue + ansi.red + ansi.white, c[[:red, :white, :blue]]
    assert_equal ansi.on_blue + ansi.red + ansi.white, c[[:red, :white_on_blue]]
  end

  def test_maps_certain_css_values_to_ansi
    assert_equal ansi.strikethrough, c[:line_through]
  end

  def test_basic_colors_are_valid
    assert c.valid?(:red)
    assert c.valid?(:on_red)
    assert c.valid?(:green)
    assert c.valid?(:on_green)
    assert c.valid?(:magenta)
    assert c.valid?(:on_magenta)

    assert !c.valid?(:bogus)
    assert !c.valid?(:on_bogus)
  end

  def test_compound_colors_are_valid
    assert c.valid?(:red_on_white)
    assert c.valid?(:blue_on_blue)
    assert c.valid?(:black_on_blue)

    assert !c.valid?(:blue_on_bogus)
    assert !c.valid?(:bogus_on_blue)
  end

  def test_various_other_ansi_escape_codes_are_valid
    assert c.valid?(:bold)
    assert c.valid?(:line_through), 'Mapped values are also valid'
  end

  def test_hard_color_transitions
    assert_equal ansi.red, c.color_transition([:blue], [:red])
    assert_equal ansi.red, c.color_transition(:blue, :red)
    assert_equal ansi.reset + ansi.red, c.color_transition(:on_blue, :red)
    assert_equal ansi.red + ansi.on_white, c.color_transition([:green, :on_blue], [:red, :on_white])
    assert_equal ansi.reset + ansi.underline, c.color_transition(:blue, :underline)
    assert_equal ansi.reset + ansi.blue, c.color_transition(:underline, :blue)
  end

  def test_soft_color_transitions
    assert_equal ansi.red, c.color_transition([:blue], [:red], false)
    assert_equal ansi.red, c.color_transition([:on_blue], [:red], false)
    assert_equal ansi.on_red, c.color_transition([:blue], [:on_red], false)
    assert_equal ansi.red, c.color_transition([:green, :on_blue], [:red], false)
    assert_equal ansi.underline, c.color_transition(:blue, :underline, false)
    assert_equal ansi.blue, c.color_transition(:underline, :blue, false)

    assert_equal ansi.red, c.color_transition([:blue], [:red], false)
    assert_equal '', c.color_transition([:blue], [:blue], false)
  end

  def test_color_transitions_blank_when_not_necessary
    assert_equal '', c.color_transition([:blue], [:blue])
    assert_equal '', c.color_transition([:on_white], [:on_white])
    assert_equal '', c.color_transition([:underline], [:underline])
    assert_equal '', c.color_transition([:blue, :on_white], [:blue, :on_white])
    assert_equal '', c.color_transition([:blue, :on_white, :underline], [:blue, :on_white, :underline])
    assert_equal '', c.color_transition([:blue, :on_white], [:on_white, :blue])
  end

  def test_color_transition_with_negations
    assert_equal ansi.reset, c.color_transition(:blue, :no_fg_color)
    assert_equal ansi.reset, c.color_transition(:on_blue, :no_bg_color)
    assert_equal ansi.reset, c.color_transition(:blue, :no_bg_color)

    assert_equal ansi.reset, c.color_transition([:blue, :on_white], :no_bg_color)
    assert_equal ansi.reset + ansi.red, c.color_transition([:blue, :on_white], [:red, :no_bg_color])
    assert_equal ansi.reset + ansi.blue, c.color_transition([:blue, :on_white], [:blue, :no_bg_color])

    assert_equal ansi.reset + ansi.red, c.color_transition([:blue, :on_white], [:red, :no_bg_color])
    assert_equal ansi.reset + ansi.blue, c.color_transition([:blue, :on_white], [:blue, :no_bg_color])

    assert_equal ansi.blue, c.color_transition(:no_fg_color, :blue)
    assert_equal ansi.on_red, c.color_transition(:no_bg_color, :on_red)
    assert_equal '', c.color_transition([:blue, :no_bg_color], :blue)
    assert_equal ansi.on_blue, c.color_transition(:no_fg_color, :on_blue)
    assert_equal '', c.color_transition([:no_fg_color, :on_blue], :on_blue)


    assert_equal ansi.reset, c.color_transition(:blue, :no_fg_color, false)
    assert_equal ansi.reset, c.color_transition(:on_blue, :no_bg_color, false)
    assert_equal '', c.color_transition(:blue, :no_bg_color, false)

    assert_equal ansi.reset + ansi.blue, c.color_transition([:blue, :on_white], :no_bg_color, false)
    assert_equal ansi.reset + ansi.red, c.color_transition([:blue, :on_white], [:red, :no_bg_color], false)
    assert_equal ansi.reset + ansi.blue, c.color_transition([:blue, :on_white], [:blue, :no_bg_color], false)

    assert_equal ansi.reset + ansi.red, c.color_transition([:blue, :on_white], [:red, :no_bg_color], false)
    assert_equal ansi.reset + ansi.blue, c.color_transition([:blue, :on_white], [:blue, :no_bg_color], false)

    assert_equal ansi.blue, c.color_transition(:no_fg_color, :blue, false)
    assert_equal ansi.on_red, c.color_transition(:no_bg_color, :on_red, false)
    assert_equal '', c.color_transition([:blue, :no_bg_color], :blue, false)
    assert_equal ansi.on_blue, c.color_transition(:no_fg_color, :on_blue, false)
    assert_equal '', c.color_transition([:no_fg_color, :on_blue], :on_blue, false)
  end

  def test_can_color_strings_with_auto_reset
    assert_equal ansi.blue + 'hello' + ansi.reset, c.color('hello', :blue)
    assert_equal ansi.blue + ansi.on_green + 'hello' + ansi.reset, c.color('hello', :blue, :on_green)
    assert_equal ansi.blue + ansi.on_green + 'hello' + ansi.reset, c.color('hello', [:blue, :on_green])
    assert_equal ansi.underline + 'hello' + ansi.reset, c.color('hello', :underline)
    assert_equal 'hello', c.color('hello', :invalid)
    assert_equal 'hello', c.color('hello', :none)
    assert_equal ansi.red + 'hello' + ansi.reset, c.color('hello', :none, :red)
    assert_equal '', c.color('', :red)
  end

  def test_force_color
    str = "has #{ansi.red}some#{ansi.reset} red"
    assert_equal "#{ansi.on_blue}has #{ansi.red}some#{ansi.reset}#{ansi.on_blue} red#{ansi.reset}",
      c.force_color(str, :on_blue)

    assert_equal ansi.blue + 'hello' + ansi.reset, c.force_color('hello', :blue)
    assert_equal '', c.force_color('', :red)
  end

  private

  def c
    ::Styles::Colors
  end

  def ansi
    ::Term::ANSIColor
  end
end


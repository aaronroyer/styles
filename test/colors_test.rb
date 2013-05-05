require File.expand_path('../test_helper', __FILE__)
require 'term/ansicolor'

class ColorsTest < MiniTest::Unit::TestCase

  def test_can_access_basic_colors_with_brackets
    assert_equal color.red, c[:red]
    assert_equal color.blue, c[:blue]
    assert_equal color.on_cyan, c[:on_cyan]

    assert_nil c[:bogus]
  end

  def test_can_access_compound_colors_with_brackets
    assert_equal color.red + color.on_white, c[:red_on_white]
    assert_equal color.blue + color.on_blue, c[:blue_on_blue]

    assert_nil c[:red_on_bogus]
    assert_nil c[:bogus_on_bogus]
    assert_nil c[:bogus_on_red]
  end

  def test_can_access_multiple_colors_with_brackets
    assert_equal color.red + color.white, c[:red, :white]
    assert_equal color.red + color.white + color.blue, c[:red, :white, :blue]
    assert_equal color.red + color.white + color.on_blue, c[:red, :white_on_blue]
  end

  def test_can_use_arrays_of_colors_with_brackets
    assert_equal color.red + color.white, c[[:red, :white]]
    assert_equal color.red + color.white + color.blue, c[[:red, :white, :blue]]
    assert_equal color.red + color.white + color.on_blue, c[[:red, :white_on_blue]]
  end

  def test_maps_certain_css_values_to_ansi
    assert_equal color.strikethrough, c[:line_through]
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
    assert_equal color.red, c.color_transition([:blue], [:red])
    assert_equal color.red, c.color_transition(:blue, :red)
    assert_equal color.reset + color.red, c.color_transition(:on_blue, :red)
    assert_equal color.red + color.on_white, c.color_transition([:green, :on_blue], [:red, :on_white])
    assert_equal color.reset + color.underline, c.color_transition(:blue, :underline)
    assert_equal color.reset + color.blue, c.color_transition(:underline, :blue)
  end

  def test_soft_color_transitions
    assert_equal color.red, c.color_transition([:blue], [:red], false)
    assert_equal color.red, c.color_transition([:on_blue], [:red], false)
    assert_equal color.on_red, c.color_transition([:blue], [:on_red], false)
    assert_equal color.red, c.color_transition([:green, :on_blue], [:red], false)
    assert_equal color.underline, c.color_transition(:blue, :underline, false)
    assert_equal color.blue, c.color_transition(:underline, :blue, false)

    assert_equal color.red, c.color_transition([:blue], [:red], false)
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

  private

  def c
    ::Styles::Colors
  end

  def color
    ::Term::ANSIColor
  end
end


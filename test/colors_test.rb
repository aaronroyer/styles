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

  private

  def c
    ::Styles::Colors
  end

  def color
    ::Term::ANSIColor
  end
end


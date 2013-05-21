require File.expand_path('../../test_helper', __FILE__)

class BorderTest < MiniTest::Unit::TestCase
  def setup
    @sub_engine = ::Styles::SubEngines::Layout.new 
  end

  def test_can_use_all_property_names
    [:border, :border_left, :border_right, :border_top, :border_bottom].each do |prop_name|
      assert_equal ::Styles::Properties::Border, ::Styles::Properties.find_class_by_property_name(prop_name)
    end
  end

  def test_gives_correct_border_values
    bl = prop(:border_left, 'solid green')
    assert_equal :none, bl.top
    assert_equal :none, bl.right
    assert_equal :none, bl.bottom
    assert_equal [:solid, :green], bl.left
    assert_equal [:none, :none, :none, [:solid, :green]], bl.all_border_values

    assert_equal [[:solid, :default], [:solid, :default], [:solid, :default], [:solid, :default]], prop(:border, :solid).all_border_values
    assert_equal [[:solid, :default], [:solid, :default], [:solid, :default], [:solid, :default]], prop(:border, 'solid').all_border_values
    assert_equal [[:solid, :blue], [:solid, :blue], [:solid, :blue], [:solid, :blue]], prop(:border, 'solid blue').all_border_values

    assert_equal [:none, :none, :none, :none], prop(:border, :none).all_border_values
    assert_equal [:none, :none, :none, :none], prop(:border_right, :none).all_border_values
  end

  def test_can_combine_border_properties
    assert_equal [:none, [:dotted, :default], :none, [:solid, :default]],
      combine([prop(:border_left, :solid), prop(:border_right, :dotted)]).all_border_values
    assert_equal [:none, [:dotted, :green], :none, [:solid, :red]],
      combine([prop(:border_left, 'solid red'), prop(:border_right, 'dotted green')]).all_border_values
    assert_equal [[:double, :cyan], [:solid, :white], [:solid, :white], [:solid, :white]],
      combine([prop(:border, 'solid white'), prop(:border_top, 'double cyan')]).all_border_values
    assert_equal [[:double, :cyan], [:dotted, :red], [:solid, :white], [:solid, :white]],
      combine([prop(:border, 'solid white'), prop(:border_top, 'double cyan'), prop(:border_right, 'dotted red')]).all_border_values
    assert_equal [[:solid, :white], [:solid, :white], [:solid, :white], [:solid, :white]],
      combine([prop(:border_top, 'double cyan'), prop(:border, 'solid white')]).all_border_values
    assert_equal [:none, :none, :none, :none],
      combine([prop(:border_top, 'double cyan'), prop(:border, :none)]).all_border_values
    assert_equal [:none, [:solid, :white], [:solid, :white], [:solid, :white]],
      combine([prop(:border, 'solid white'), prop(:border_top, :none)]).all_border_values
  end

  def test_produces_correct_border_characters
    solid = ::Styles::Properties::Border::SOLID_CHARS

    solid_prop = prop(:border, :solid)
    assert_equal solid[:top], solid_prop.top_char
    assert_equal solid[:left], solid_prop.left_char
    assert_equal solid[:top_left], solid_prop.top_left_char
    assert_equal solid[:top] * 4, solid_prop.top_char(4)

    assert_equal "#{solid[:top_left]}#{solid[:top] * 4}#{solid[:top_right]}", solid_prop.top_line_chars(4)
    assert_equal "#{solid[:bottom_left]}#{solid[:bottom] * 4}#{solid[:bottom_right]}", solid_prop.bottom_line_chars(4)

    solid_green_prop = prop(:border, 'solid green')
    assert_equal "#{color.green}#{solid[:top]}#{color.reset}", solid_green_prop.top_char
    assert_equal "#{color.green}#{solid[:left]}#{color.reset}", solid_green_prop.left_char
    assert_equal "#{color.green}#{solid[:top_left]}#{color.reset}", solid_green_prop.top_left_char
    assert_equal "#{color.green}#{solid[:top] * 4}#{color.reset}", solid_green_prop.top_char(4)

    assert_equal "#{color.green}#{solid[:top_left]}#{color.reset}#{color.green}#{solid[:top] * 4}" +
      "#{color.reset}#{color.green}#{solid[:top_right]}#{color.reset}", solid_green_prop.top_line_chars(4)
    assert_equal "#{color.green}#{solid[:bottom_left]}#{color.reset}#{color.green}#{solid[:bottom] * 4}" +
      "#{color.reset}#{color.green}#{solid[:bottom_right]}#{color.reset}", solid_green_prop.bottom_line_chars(4)

    none_prop = prop(:border, :none)
    assert_equal '', none_prop.top_char
    assert_equal '', none_prop.left_char
    assert_equal '', none_prop.top_char(4)

    none_prop = prop(:border_right, :solid)
    assert_equal '', none_prop.top_char
    assert_equal '', none_prop.left_char
    assert_equal solid[:right], none_prop.right_char

    bottom_right_prop = combine([prop(:border_bottom, :solid), prop(:border_right, :solid)])
    assert_equal '', bottom_right_prop.top_char
    assert_equal '', bottom_right_prop.left_char
    assert_equal '', bottom_right_prop.top_left_char
    assert_equal '', bottom_right_prop.top_right_char
    assert_equal '', bottom_right_prop.bottom_left_char
    assert_equal solid[:right], bottom_right_prop.right_char
    assert_equal solid[:bottom_right], bottom_right_prop.bottom_right_char
    assert_equal solid[:bottom], bottom_right_prop.bottom_char
    assert_equal "#{solid[:bottom] * 4}#{solid[:bottom_right]}", bottom_right_prop.bottom_line_chars(4)
  end

  def test_can_apply_a_border
    test_line = 'line for U'
    solid = ::Styles::Properties::Border::SOLID_CHARS

    solid_border_box = <<SOLID_BORDER
#{solid[:top_left]}#{solid[:top] * test_line.size}#{solid[:top_right]}
#{solid[:left]}#{test_line}#{solid[:right]}
#{solid[:bottom_left]}#{solid[:bottom] * test_line.size}#{solid[:bottom_right]}
SOLID_BORDER

    assert_equal solid_border_box, process('line', :border, :solid, test_line)
  end

  def test_can_apply_a_colored_border
    test_line = 'line for U, with color'
    solid = ::Styles::Properties::Border::SOLID_CHARS

    solid_blue_border_box = <<SOLID_BORDER
#{color.blue}#{solid[:top_left]}#{color.reset}#{color.blue}#{solid[:top] * test_line.size}#{color.reset}#{color.blue}#{solid[:top_right]}#{color.reset}
#{color.blue}#{solid[:left]}#{color.reset}#{test_line}#{color.blue}#{solid[:right]}#{color.reset}
#{color.blue}#{solid[:bottom_left]}#{color.reset}#{color.blue}#{solid[:bottom] * test_line.size}#{color.reset}#{color.blue}#{solid[:bottom_right]}#{color.reset}
SOLID_BORDER

    assert_equal solid_blue_border_box, process('line', :border, 'solid blue', test_line)
  end

  def test_can_apply_partial_borders
    test_line = 'line for U'
    solid = ::Styles::Properties::Border::SOLID_CHARS

    partial_border = <<PARTIAL_BORDER
#{test_line}#{solid[:right]}
#{solid[:bottom] * test_line.size}#{solid[:bottom_right]}
PARTIAL_BORDER

    line = ::Styles::Line.new(test_line, [::Styles::Properties::Border.new([prop(:border_right, :solid), prop(:border_bottom, :solid)])])
    assert_equal partial_border, @sub_engine.process(line).to_s
  end

  private

  def process(selector, property_name, value, line)
    line = ::Styles::Line.new(line, [::Styles::Properties::Border.new(selector, property_name, value)])
    result = @sub_engine.process(line)
    result.to_s
  end

  def prop(name, value, selector='test')
    ::Styles::Properties::Border.new(selector, name, value)
  end

  def combine(*props)
    ::Styles::Properties::Border.new(props.flatten)
  end

  def stub_term_width(width)
    @sub_engine.stubs(:terminal_width).returns(width)
  end

  def color
    ::Term::ANSIColor
  end
end

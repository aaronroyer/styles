require File.expand_path('../../test_helper', __FILE__)

class PaddingTest < MiniTest::Unit::TestCase
  def setup
    @sub_engine = ::Styles::SubEngines::Layout.new 
  end

  def test_can_use_all_property_names
    [:padding, :padding_left, :padding_right, :padding_top, :padding_bottom].each do |prop_name|
      assert_equal ::Styles::Properties::Padding, ::Styles::Properties.find_class_by_property_name(prop_name)
    end
  end

  def test_gives_correct_padding_values
    p = prop(:padding_left, 2)
    assert_equal 0, p.top
    assert_equal 0, p.right
    assert_equal 0, p.bottom
    assert_equal 2, p.left
    assert_equal [0, 0, 0, 2], p.all_padding

    assert_equal [4, 4, 4, 4], prop(:padding, 4).all_padding
    assert_equal [2, 2, 2, 2], prop(:padding, 2).all_padding
    assert_equal [5, 0, 0, 0], prop(:padding_top, 5).all_padding
    assert_equal [0, 3, 0, 0], prop(:padding_right, 3).all_padding
    assert_equal [0, 0, 10, 0], prop(:padding_bottom, 10).all_padding

    assert_equal [0, 0, 0, 0], prop(:padding, :none).all_padding
    assert_equal [0, 0, 0, 0], prop(:padding_right, :none).all_padding
  end

  def test_can_combine_padding_properties
    assert_equal [0, 3, 0, 2], combine([prop(:padding_left, 2), prop(:padding_right, 3)]).all_padding
    assert_equal [0, 0, 0, 2], combine([prop(:padding_left, 2)]).all_padding
    assert_equal [5, 2, 2, 2], combine([prop(:padding, 2), prop(:padding_top, 5)]).all_padding
    assert_equal [5, 4, 2, 2], combine([prop(:padding, 2), prop(:padding_top, 5), prop(:padding_right, 4)]).all_padding
    assert_equal [2, 2, 2, 2], combine([prop(:padding_top, 5), prop(:padding, 2)]).all_padding
    assert_equal [0, 2, 2, 2], combine([prop(:padding, 2), prop(:padding_top, 0)]).all_padding

    assert_equal [4, 0, 0, 0], combine([prop(:padding, :none), prop(:padding_top, 4)]).all_padding
    assert_equal [0, 4, 4, 4], combine([prop(:padding, 4), prop(:padding_top, :none)]).all_padding

    no_top = combine([prop(:padding, 3), prop(:padding_top, 0)])
    left_and_right = combine([prop(:padding_left, 2), prop(:padding_right, 5)])
    assert_equal [0, 5, 3, 2], combine([no_top, left_and_right]).all_padding
  end

  def test_can_configure_with_side_values
    assert_equal [1, 2, 3, 4], prop(:padding, '1 2 3 4').all_padding
    assert_equal [1, 2, 3, 0], prop(:padding, '1 2 3').all_padding
    assert_equal [1, 2, 0, 0], prop(:padding, '1 2').all_padding
    assert_equal [1, 0, 0, 0], prop(:padding, '1').all_padding
  end

  def test_padding_left
    test_line = 'line tests'
    stub_term_width(80)
    assert_equal "  #{test_line}", process('line', :padding_left, 2, test_line)
    assert_equal "          #{test_line}", process('line', :padding_left, 10, test_line)
  end

  def test_all_padding
    test_line = 'line tests'
    stub_term_width(80)
    assert_equal "#{' ' * 12}\n line tests \n#{' ' * 12}\n", process('line', :padding, 1, test_line)
  end

  private

  def process(selector, property_name, value, line)
    line = ::Styles::Line.new(line, [::Styles::Properties::Padding.new(selector, property_name, value)])
    result = @sub_engine.process(line)
    result.to_s
  end

  def prop(name, value, selector='test')
    ::Styles::Properties::Padding.new(selector, name, value)
  end

  def combine(*props)
    ::Styles::Properties::Padding.new(props.flatten)
  end

  def stub_term_width(width)
    @sub_engine.stubs(:terminal_width).returns(width)
  end
end

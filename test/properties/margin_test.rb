require File.expand_path('../../test_helper', __FILE__)

class MarginTest < MiniTest::Unit::TestCase
  def setup
    @sub_engine = ::Styles::SubEngines::Layout.new 
  end

  def test_can_use_all_property_names
    [:margin, :margin_left, :margin_right, :margin_top, :margin_bottom].each do |prop_name|
      assert_equal ::Styles::Properties::Margin, ::Styles::Properties.find_class_by_property_name(prop_name)
    end
  end

  def test_gives_correct_margin_values
    ml = prop(:margin_left, 2)
    assert_equal 0, ml.top
    assert_equal 0, ml.right
    assert_equal 0, ml.bottom
    assert_equal 2, ml.left
    assert_equal [0, 0, 0, 2], ml.all_margins

    assert_equal [4, 4, 4, 4], prop(:margin, 4).all_margins
    assert_equal [2, 2, 2, 2], prop(:margin, 2).all_margins
    assert_equal [5, 0, 0, 0], prop(:margin_top, 5).all_margins
    assert_equal [0, 3, 0, 0], prop(:margin_right, 3).all_margins
    assert_equal [0, 0, 10, 0], prop(:margin_bottom, 10).all_margins

    assert_equal [0, 0, 0, 0], prop(:margin, :none).all_margins
    assert_equal [0, 0, 0, 0], prop(:margin, :wat).all_margins
    assert_equal [0, 0, 0, 0], prop(:margin_right, :none).all_margins

    assert_equal [:auto, :auto, :auto, :auto], prop(:margin, :auto).all_margins
  end

  def test_can_configure_with_side_values
    assert_equal [1, 2, 3, 4], prop(:margin, '1 2 3 4').all_margins
    assert_equal [1, 2, 3, 0], prop(:margin, '1 2 3').all_margins
    assert_equal [1, 2, 0, 0], prop(:margin, '1 2').all_margins
    assert_equal [1, 0, 0, 0], prop(:margin, '1').all_margins

    assert_equal [1, :auto, 0, 0], prop(:margin, '1 auto').all_margins
    assert_equal [1, :auto, 3, :auto], prop(:margin, '1 auto 3 auto').all_margins
    assert_equal [1, 0, 3, 0], prop(:margin, '1 wat 3 huh').all_margins
  end

  def test_can_combine_margin_properties
    assert_equal [0, 3, 0, 2], combine([prop(:margin_left, 2), prop(:margin_right, 3)]).all_margins
    assert_equal [0, 0, 0, 2], combine([prop(:margin_left, 2)]).all_margins
    assert_equal [5, 2, 2, 2], combine([prop(:margin, 2), prop(:margin_top, 5)]).all_margins
    assert_equal [5, 4, 2, 2], combine([prop(:margin, 2), prop(:margin_top, 5), prop(:margin_right, 4)]).all_margins
    assert_equal [2, 2, 2, 2], combine([prop(:margin_top, 5), prop(:margin, 2)]).all_margins
    assert_equal [0, 2, 2, 2], combine([prop(:margin, 2), prop(:margin_top, 0)]).all_margins

    assert_equal [4, 0, 0, 0], combine([prop(:margin, :none), prop(:margin_top, 4)]).all_margins
    assert_equal [0, 4, 4, 4], combine([prop(:margin, 4), prop(:margin_top, :none)]).all_margins

    no_top = combine([prop(:margin, 3), prop(:margin_top, 0)])
    left_and_right = combine([prop(:margin_left, 2), prop(:margin_right, 5)])
    assert_equal [0, 5, 3, 2], combine([no_top, left_and_right]).all_margins
  end

  def test_margin_left
    test_line = 'line needs margin'
    stub_term_width(80)
    assert_equal "  #{test_line}", process('line', :margin_left, 2, test_line)
    assert_equal "          #{test_line}", process('line', :margin_left, 10, test_line)
  end

  def test_auto
    test_line = 'the line'
    stub_term_width(20)
    assert_equal "      #{test_line}      ", process('line', :margin, :auto, test_line)
    assert_equal "      #{test_line}      ", process('line', :margin_left, :auto, test_line)
    assert_equal "      #{test_line}      ", process('line', :margin_right, :auto, test_line)
    assert_equal "      #{test_line}      ", process('line', :margin, '0 auto', test_line)
    assert_equal "      #{test_line}      ", process('line', :margin, '0 auto 0 auto', test_line)
  end

  private

  def process(selector, property_name, value, line)
    line = ::Styles::Line.new(line, [::Styles::Properties::Margin.new(selector, property_name, value)])
    result = @sub_engine.process(line)
    result.to_s
  end

  def prop(name, value, selector='test')
    ::Styles::Properties::Margin.new(selector, name, value)
  end

  def combine(*props)
    ::Styles::Properties::Margin.new(props.flatten)
  end

  def stub_term_width(width)
    @sub_engine.stubs(:terminal_width).returns(width)
  end
end

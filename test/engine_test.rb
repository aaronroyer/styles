require File.expand_path('../test_helper', __FILE__)
require 'term/ansicolor'

class EngineTest < MiniTest::Unit::TestCase
  def test_later_rules_from_same_stylesheet_take_precedence
    hide_all_rule = ':all - { display: none }'
    show_line_rule = "'show' - { display: block }"

    hide_all_stylesheet = Styles::Stylesheet.from_string("#{show_line_rule}\n#{hide_all_rule}")

    hide_all_engine = Styles::Engine.new(hide_all_stylesheet)
    assert_equal nil, hide_all_engine.process('show this line')

    show_a_line_stylesheet = Styles::Stylesheet.from_string("#{hide_all_rule}\n#{show_line_rule}")

    show_a_line_engine = Styles::Engine.new(show_a_line_stylesheet)
    assert_equal 'show this line', show_a_line_engine.process('show this line')
  end

  def test_rules_from_later_stylesheets_take_precedence
    hide_all_rule = ':all - { display: none }'
    show_line_rule = "'show' - { display: block }"

    hide_all_stylesheet = Styles::Stylesheet.from_string(hide_all_rule)
    show_stylesheet = Styles::Stylesheet.from_string(show_line_rule)

    # First one stylesheet at a time
    assert_equal nil, Styles::Engine.new(hide_all_stylesheet).process('just some text')
    assert_equal 'show this line', Styles::Engine.new(show_stylesheet).process('show this line')

    # Now use multiple Stylesheets and make sure the Rules of the last one takes precedence
    assert_equal nil, Styles::Engine.new(show_stylesheet, hide_all_stylesheet).process('show this line')
    assert_equal 'show this line', Styles::Engine.new(hide_all_stylesheet, show_stylesheet).process('show this line')
  end

  def test_rules_can_hide_lines
    stylesheet_text = <<-STYLESHEET
      'ANNOYING' - {
        display: none
      }

      /hide this/ - {
        display: none
      }
    STYLESHEET

    engine = Styles::Engine.new(Styles::Stylesheet.from_string(stylesheet_text))

    assert_equal 'this is a line', engine.process('this is a line')
    assert_nil engine.process('THIS LINE IS ANNOYING')
    assert_nil engine.process('this line has hide this in it')
  end

  def test_original_colors_stripped_for_correct_properties
    test_line = "this line #{color.red}had color#{color.reset}"
    test_line_without_color = 'this line had color'

    do_not_strip_sheet = Styles::Stylesheet.from_string(':all - { display: block }')
    do_strip_sheet = Styles::Stylesheet.from_string(':all - { font_weight: normal }')

    assert_equal test_line, Styles::Engine.new(do_not_strip_sheet).process(test_line)
    assert_equal test_line_without_color, Styles::Engine.new(do_strip_sheet).process(test_line)
  end

  private

  def color
    ::Term::ANSIColor
  end
end

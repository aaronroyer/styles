require File.expand_path('../test_helper', __FILE__)
require 'term/ansicolor'

class EngineTest < MiniTest::Unit::TestCase
  def teardown
    Styles::Stylesheets.constants.each { |const| Styles::Stylesheets.send(:remove_const, const) }
  end

  def test_later_rules_from_same_stylesheet_take_precedence
    hide_all_rule = ':all - { display: none }'
    show_line_rule = "'show' - { display: block }"

    hide_all_stylesheet = Styles::Stylesheet.from_string('HideAllStylesheet',
      "#{show_line_rule}\n#{hide_all_rule}").new

    hide_all_engine = Styles::Engine.new(hide_all_stylesheet)
    assert_equal nil, hide_all_engine.process('show this line')

    show_a_line_stylesheet = Styles::Stylesheet.from_string('ShowALineStylesheet',
      "#{hide_all_rule}\n#{show_line_rule}").new

    show_a_line_engine = Styles::Engine.new(show_a_line_stylesheet)
    assert_equal 'show this line', show_a_line_engine.process('show this line')
  end

  def test_rules_from_later_stylesheets_take_precedence
    hide_all_rule = ':all - { display: none }'
    show_line_rule = "'show' - { display: block }"

    hide_all_stylesheet = Styles::Stylesheet.from_string('HideAllStylesheet', hide_all_rule).new
    show_stylesheet = Styles::Stylesheet.from_string('ShowTestStylesheet', show_line_rule).new

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

    engine = Styles::Engine.new(Styles::Stylesheet.from_string('DisplayStylesheet', stylesheet_text).new)

    assert_equal 'this is a line', engine.process('this is a line')
    assert_nil engine.process('THIS LINE IS ANNOYING')
    assert_nil engine.process('this line has hide this in it')
  end
end

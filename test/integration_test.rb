require File.expand_path('../test_helper', __FILE__)
require 'stringio'
require 'term/ansicolor'

# Tests everything together.
# Parse stylesheet text, apply those to input, and confirm correct output.
class IntegrationTest < MiniTest::Unit::TestCase
  def test_rules_can_hide_lines
    @stylesheet = <<-STYLESHEET
      'ANNOYING' - {
        display: none
      }

      /hide this/ - {
        display: none
      }

      :blank - {
        display: none
      }
    STYLESHEET

    @input = <<-INPUT
this is a line
THIS LINE IS ANNOYING
this line has hide this in it
this one is also visible

the line before this is blank
    INPUT

    @expected_output = <<-OUTPUT
this is a line
this one is also visible
the line before this is blank
    OUTPUT

    assert_correct_output
  end

  def test_various_line_colors_and_styles
    @stylesheet = <<-STYLESHEET
      'red' - {
        color: red
      }

      'fantastic' - {
        color: cyan,
        background_color: yellow
      }

      /important/ - {
        font_weight: bold
      }

      /tons/i - {
        color: green,
        background_color: red,
        font_weight: bold,
        text_decoration: underline
      }
    STYLESHEET

    @input = <<-INPUT
this line is red
no color here
this has fantastic colors
this line is important
this has TONS going on
    INPUT

    @expected_output = <<-OUTPUT
#{color.red}this line is red#{color.reset}
no color here
#{color.cyan}#{color.on_yellow}this has fantastic colors#{color.reset}
#{color.bold}this line is important#{color.reset}
#{color.bold}#{color.green}#{color.on_red}#{color.underline}this has TONS going on#{color.reset}
    OUTPUT

    assert_correct_output
  end

  def test_various_line_and_match_color_combos
    @stylesheet = <<-STYLESHEET
      'cyanify' - {
        match_color: cyan
      }

      /(number) (\\d\\d)/ - {
        match_color: [red, green]
      }

      'blue' - {
        color: blue
      }

      'on yellow' - {
        background_color: yellow
      }
    STYLESHEET

    @input = <<-INPUT
cyanify this
the number 25 is here
the number 25 is here, blue otherwise
the number 25 is here on yellow
    INPUT

    @expected_output = <<-OUTPUT
#{color.cyan}cyanify#{color.reset} this
the #{color.red}number#{color.reset} #{color.green}25#{color.reset} is here
#{color.blue}the #{color.red}number#{color.blue} #{color.green}25#{color.blue} is here, blue otherwise#{color.reset}
#{color.on_yellow}the #{color.red}number#{color.reset}#{color.on_yellow} #{color.green}25#{color.reset}#{color.on_yellow} is here on yellow#{color.reset}
    OUTPUT

    assert_correct_output
  end

  private

  def assert_correct_output
    engine = Styles::Engine.new(Styles::Stylesheet.from_string(@stylesheet))

    output = StringIO.new
    @input.each_line do |line|
      processed_line = engine.process(line)
      output.puts processed_line if processed_line
    end

    assert_equal @expected_output, output.string
  end

  def color
    ::Term::ANSIColor
  end
end

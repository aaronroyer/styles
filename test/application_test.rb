require File.expand_path('../test_helper', __FILE__)
require 'term/ansicolor'
require 'tmpdir'
require 'stringio'
require 'fileutils'
require 'timecop'

class ApplicationTest < MiniTest::Unit::TestCase
  def setup
    ENV['STYLES_DIR'] = @stylesheets_dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry_secure(@stylesheets_dir) if File.directory?(@stylesheets_dir)
    ENV['STYLES_DIR'] = nil
  end

  def test_run_with_default_stylesheet
    File.open(File.join(stylesheets_dir, 'default.rb'), 'w') do |f|
      f.write " 'hide' - { display: none } "
    end

    input = StringIO.new "hide this\nnot this\n", 'r'
    output = StringIO.new

    app = ::Styles::Application.new input_stream: input, output_stream: output
    app.send :read_stylesheets
    app.send :process

    assert_equal "not this\n", output.string
  end

  def test_auto_reload_updated_stylesheet
    default_stylesheet = File.join stylesheets_dir, 'default.rb'
    File.open(default_stylesheet, 'w') { |f| f.write " 'word' - { color: green } " }

    input = StringIO.new "has a word\nhas a word\n", 'r'
    output = StringIO.new
    app = ::Styles::Application.new input_stream: input, output_stream: output

    app.send :read_stylesheets
    app.send :process_next_line
    assert_equal "#{color.green}has a word#{color.reset}\n", output.string

    orig_time = Time.now

    output.truncate(output.rewind)

    File.open(default_stylesheet, 'w') { |f| f.write " 'word' - { color: red } " }
    FileUtils.touch(default_stylesheet, mtime: orig_time + 2)

    Timecop.freeze(orig_time + 4) do
      app.send :process_next_line
    end
    assert_equal "#{color.red}has a word#{color.reset}\n", output.string
  end

  def test_does_not_auto_reload_updated_stylesheet_inside_check_interval
    interval = ::Styles::Application::STYLESHEET_CHECK_INTERVAL_SECONDS

    default_stylesheet = File.join stylesheets_dir, 'default.rb'
    File.open(default_stylesheet, 'w') { |f| f.write " 'word' - { color: green } " }

    input = StringIO.new "has a word\nhas a word\n", 'r'
    output = StringIO.new
    app = ::Styles::Application.new input_stream: input, output_stream: output

    app.send :read_stylesheets
    app.send :process_next_line
    assert_equal "#{color.green}has a word#{color.reset}\n", output.string

    orig_time = Time.now

    output.truncate(output.rewind)

    File.open(default_stylesheet, 'w') { |f| f.write " 'word' - { color: red } " }
    FileUtils.touch(default_stylesheet, mtime: orig_time + (interval - 1))

    Timecop.freeze(orig_time + (interval - 1)) do
      app.send :process_next_line
    end
    assert_equal "#{color.green}has a word#{color.reset}\n", output.string
  end

  private

  attr_reader :stylesheets_dir

  def color
    ::Term::ANSIColor
  end
end

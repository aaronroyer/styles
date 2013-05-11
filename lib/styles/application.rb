require 'optparse'
require 'pathname'

module Styles
  class Application
    STYLESHEET_CHECK_INTERVAL_SECONDS = 2

    def initialize(options={})
      @input_stream = options[:input_stream] || $stdin
      @output_stream = options[:output_stream] || $stdout
      @quiet = false
    end

    def run
      create_stylesheets_dir
      parse_args
      read_stylesheets
      process
    end

    private

    attr_accessor :last_stylesheet_check_time
    attr_reader :input_stream, :output_stream

    def process
      ['INT', 'TERM'].each { |signal| trap(signal) { exit } }

      while process_next_line
        # no-op
      end
    end

    def process_next_line
      reload_stylesheets_if_outdated if check_interval_elapsed?

      line = input_stream.gets
      return nil unless line
      result = engine.process line
      output_stream.puts result if result
      line
    end

    def engine
      @engine ||= Styles::Engine.new(stylesheets)
    end

    def stylesheets
      @stylesheets ||= []
    end

    def stylesheet_names
      @stylesheet_names ||= []
    end

    def parse_args
      OptionParser.new do |opts|
        opts.on('--edit [NAME]', 'Edit stylesheet with given NAME (\'default\' by default)') do |name|
          safe_exec which_editor, stylesheet_file(name ||= 'default')
        end
        opts.on('--list', 'List names of available stylesheets') do
          Dir.entries(stylesheets_dir).grep(/\.rb$/).each { |ss| puts ss.sub(/\.rb$/, '') }
          exit
        end
        opts.on('--quiet', 'Suppress stylesheet warning messages') do
          @quiet = true
        end
        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
        opts.on_tail('--version', 'Show version') do
          puts "Styles version: #{Styles::VERSION}"
          exit
        end
      end.parse!

      stylesheet_names.concat ARGV.dup
    end

    def read_stylesheets
      stylesheet_names << 'default' if stylesheet_names.empty?

      stylesheet_names.each do |name|
        file = stylesheet_file(name)
        begin
          stylesheets << ::Styles::Stylesheet.new(file)
          self.last_stylesheet_check_time = Time.now
          print_stylesheet_warnings
        rescue Errno::ENOENT => e
          $stderr.puts "Stylesheet '#{name}.rb' does not exist in #{stylesheets_dir}"
          exit 1
        rescue SyntaxError => se
          $stderr.puts "Could not parse stylesheet: #{file}"
          $stderr.puts se.message.sub(/^\(eval\):/, 'line ')
          exit 1
        end
      end
    end

    def reload_stylesheets_if_outdated
      before_times = stylesheets.map(&:last_updated).sort
      stylesheets.each &:reload_if_outdated
      after_times = stylesheets.map(&:last_updated).sort
      self.last_stylesheet_check_time = Time.now
      print_stylesheet_warnings unless before_times == after_times
    end

    def check_interval_elapsed?
      (last_stylesheet_check_time + STYLESHEET_CHECK_INTERVAL_SECONDS) <= Time.now
    end

    def which_editor
      editor = ENV['STYLES_EDITOR'] || ENV['EDITOR']
      return editor unless editor.nil?

      %w[subl mate].each {|e| return e if which(e) }

      '/usr/bin/vim'
    end

    def which(cmd)
      dir = ENV['PATH'].split(':').find {|p| File.executable? File.join(p, cmd)}
      Pathname.new(File.join(dir, cmd)) unless dir.nil?
    end

    # Properly quote and evaluate of environment variables in the cmd parameter. This
    # and a few other things related to firing up an editor are borrowed or pretty much
    # cribbed from Homebrew (github.com/mxcl/homebrew).
    def safe_exec(cmd, *args)
      exec "/bin/sh", "-i", "-c", cmd + ' "$@"', "--", *args
    end

    def create_stylesheets_dir
      return if File.directory? stylesheets_dir
      if File.exist? stylesheets_dir
        # TODO: raise a custom exception that is caught and outputs something nice
        raise "Not a directory: #{stylesheets_dir}"
      else
        Dir.mkdir stylesheets_dir
      end
    end

    def stylesheet_file(name)
      File.join(stylesheets_dir, "#{name}.rb")
    end

    def stylesheets_dir
      @stylesheets_dir ||= ENV['STYLES_DIR'] || File.join(home_dir, '.styles')
    end

    def home_dir
      @home_dir ||= begin
        home = ENV['HOME']
        home = ENV['USERPROFILE'] unless home
        if !home && (ENV['HOMEDRIVE'] && ENV['HOMEPATH'])
          home = File.join(ENV['HOMEDRIVE'], ENV['HOMEPATH'])
        end
        home = File.expand_path('~') unless home
        home = 'C:/' if !home && RUBY_PLATFORM =~ /mswin|mingw/
        home
      end
    end

    def quiet?; @quiet end

    def print_stylesheet_warnings
      unless quiet?
        stylesheets.each do |sheet|
          unless sheet.unrecognized_property_names.empty?
            props = sheet.unrecognized_property_names
            name_list = props.map { |p| "'#{p.to_s}'" }.join(' ')
            $stderr.puts "Unrecognized #{props.size > 1 ? 'properties' : 'property'} #{name_list} in #{sheet.file_path}"
          end
        end
      end
    end
  end
end

require 'optparse'
require 'pathname'

module Styles
  class Application
    def run
      create_stylesheets_dir
      parse_args
      read_stylesheets
      process
    end

    private

    def process
      input_stream, output_stream = $stdin, $stdout

      while line = input_stream.gets
        result = engine.process(line)
        output_stream.puts result if result
      end
    end

    def engine
      @engine ||= Styles::Engine.new(stylesheets)
    end

    def stylesheets
      @stylesheets ||= []
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
        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
        opts.on_tail('--version', 'Show version') do
          puts "Styles version: #{Styles::VERSION}"
          exit
        end
      end.parse!
    end

    def read_stylesheets
      stylesheet_names = ARGV.dup
      stylesheet_names << 'default' if stylesheet_names.empty?
      stylesheet_names.each do |name|
        stylesheets << ::Styles::Stylesheet.from_string(IO.read(stylesheet_file(name)))
      end
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
  end
end

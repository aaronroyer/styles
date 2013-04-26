module Styles
  class Application
    def run
      parse_args
      create_stylesheets
      process
    end

    private

    attr_accessor :stylesheet_names

    def process
      stylesheet = stylesheets.first
      input_stream = $stdin
      output_stream = $stdout

      while line = input_stream.gets
        result = stylesheet.process(line)
        output_stream.puts result if result
      end
    end

    def stylesheets
      @stylesheets ||= []
    end

    def parse_args
      self.stylesheet_names = ARGV.dup
      stylesheet_names << 'default' if stylesheet_names.empty?
    end

    def create_stylesheets
      stylesheet_names.each do |name|
        file = File.join(::Styles.stylesheets_dir, "#{name}.rb")
        stylesheets << ::Styles::Stylesheet.from_string("#{name.capitalize}Stylesheet", IO.read(file)).new
      end
    end
  end
end

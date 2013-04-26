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
      self.stylesheet_names = ARGV.dup
      stylesheet_names << 'default' if stylesheet_names.empty?
    end

    def create_stylesheets
      stylesheet_names.each do |name|
        file = File.join(::Styles.stylesheets_dir, "#{name}.rb")
        stylesheets << ::Styles::Stylesheet.from_string(IO.read(file))
      end
    end
  end
end

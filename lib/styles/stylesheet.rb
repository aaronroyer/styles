module Styles
  class Stylesheet

    attr_accessor :file_path, :rules
    attr_reader :last_updated

    # For creating a one off, temporary Stylesheet without an associated file. Mostly useful
    # for testing.
    def self.from_string(string)
      stylesheet = new
      stylesheet.rules = eval_rules string
      stylesheet
    end

    def initialize(stylesheet_file_path=nil)
      @file_path = stylesheet_file_path
      @rules = []
      @last_updated = nil
      load_rules_from_file if @file_path
    end

    def unrecognized_property_names
      rules.map { |rule| rule.unrecognized_properties.keys }.flatten
    end

    def reload
      load_rules_from_file
    end

    def outdated?
      !last_updated || file_mtime > last_updated
    end

    def reload_if_outdated
      reload if outdated?
    end

    private

    attr_writer :last_updated

    def file_mtime
      File.mtime file_path
    end

    def load_rules_from_file
      begin
        self.rules = self.class.eval_rules(IO.read(file_path), file_path)
      rescue Errno::ENOENT => e
        msg = "Stylesheet '#{File.basename file_path}' does not exist in #{File.dirname file_path}"
        raise ::Styles::StylesheetLoadError, msg
      end
      self.last_updated = Time.now
    end

    # Evaluates rules specified in the DSL format and returns an array of Rule objects.
    #
    # This evaluates the stylesheet text in a throwaway execution context. A reference to an array
    # to contain the parsed rules is place in the global variable <tt>$current_stylesheet_rules</tt>
    # while this is happening. This is for DSL support and allows the use of the <tt>-</tt> method
    # on core types to add rules to Stylesheets. See core_ext.rb for more details.
    def self.eval_rules(string, file_path=nil)
      $current_stylesheet_rules = []
      context = EvalContext.new

      begin
        context.instance_eval(string)
      rescue SyntaxError => se
        msg = "Could not parse stylesheet: #{file_path || '(no file)'}\n#{se.message.sub(/^\(eval\):/, 'line ')}"
        raise ::Styles::StylesheetLoadError, msg
      end

      # After eval the global variable will contain an array of selector and
      # properties pairs. See core_ext.rb for how these are collected.
      rules = $current_stylesheet_rules.map { |selector_and_properties| Rule.new *selector_and_properties }

      $current_stylesheet_rules = nil
      rules
    end

    # Instances serve as throwaway execution contexts for user-produced stylesheet text. This is
    # useful so that methods that only serve to support the DSL do not pollute the resulting
    # Stylesheet object. Also, method definitions or overrides in the stylesheet will not affect
    # the Stylesheet (probably). Since we are executing Ruby code there is no guarantee that
    # that something won't get messed up, but this makes inadvertently doing so much less likely.
    class EvalContext

      # Supports the DSL for stylesheets, making them more attractive and CSS-y by allowing
      # property values to be specified like this
      #
      #   color: red
      #
      # instead of like this
      #
      #   color: :red
      #
      def method_missing(name)
        name
      end

    end
  end
end

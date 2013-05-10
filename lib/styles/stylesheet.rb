module Styles
  class Stylesheet

    attr_accessor :file_path

    # For creating a one off, temporary Stylesheet without an associated file. Mostly useful
    # for testing.
    def self.from_string(string)
      stylesheet = new
      eval_rules(string, stylesheet)
      stylesheet
    end

    def initialize(stylesheet_file_path=nil)
      @file_path = stylesheet_file_path
      @last_eval_time = nil
      load_rules_from_file if @file_path
    end

    def rules
      @rules ||= []
    end

    # Create a new Rule with the given selector and properties and add it to this Stylesheet.
    def add_rule(selector, properties_hash)
      rules << Rule.new(selector, properties_hash)
    end

    def reload
      load_rules_from_file
    end

    def outdated?
      file_mtime > last_eval_time
    end

    def reload_if_outdated
      reload if outdated?
    end

    private

    attr_accessor :last_eval_time

    def file_mtime
      File.mtime file_path
    end

    def load_rules_from_file
      rules.clear
      self.class.eval_rules(IO.read(file_path), self)
      self.last_eval_time = Time.now
    end

    # Evaluates rules specified in the DSL format, creates Rule objects from them, and adds them
    # to the given Stylesheet object.
    #
    # This evaluates the stylesheet text in a throwaway execution context. A reference to the given
    # Stylesheet is placed in the global variable <tt>$stylesheet_currently_being_built</tt>
    # while this is happening. This is for DSL support and allows the use of the <tt>-</tt> method
    # on core types to add rules to Stylesheets. See core_ext.rb for more details.
    def self.eval_rules(string, stylesheet)
      $stylesheet_currently_being_built = stylesheet
      context = EvalContext.new
      context.instance_eval(string)
      $stylesheet_currently_being_built = nil
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

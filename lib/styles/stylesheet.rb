module Styles
  class Stylesheet
    METHOD_MISSING_EXCLUSIONS = [:to_ary]

    # Create a new Stylesheet class with the given name from the given stylesheet text.
    def self.from_string(text)
      stylesheet = new
      stylesheet.instance_eval(text)
      $stylesheet_currently_being_built = nil
      stylesheet
    end

    # Sets the object being built to a global variable indicating which Stylesheet is currently
    # being built. This is for DSL support and allows the use of the "-" method on core types
    # to add rules to Stylesheets. See core_ext.rb for more details.
    def initialize
      $stylesheet_currently_being_built = self
    end

    def rules
      @rules ||= []
    end

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
      if METHOD_MISSING_EXCLUSIONS.include? name
        super
      else
        name
      end
    end

    def add_rule(selector, properties_hash)
      rules << Rule.new(selector, properties_hash)
    end
  end
end

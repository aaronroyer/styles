module Styles
  class Line
    attr_accessor :applicable_properties
    attr_reader :original
    attr_writer :current

    def initialize(line, properties=nil)
      @original = line
      @original.freeze
      @applicable_properties = properties

      @current = @original.dup
    end

    def current
      @current.nil? ? nil : @current.dup
    end

    def to_s
      current.to_s
    end

    def prop(property_name)
      prop_name = property_name.to_sym
      applicable_properties.find { |prop| prop.class.to_sym == prop_name }
    end

    def prop?(property_name)
      !!prop(property_name)
    end

    alias :update :current=
  end
end

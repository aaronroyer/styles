require 'term/ansicolor'

module Styles
  module Properties
    FOREGROUND_COLOR_VALUES = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]
    BACKGROUND_COLOR_VALUES = [:on_black, :on_red, :on_green, :on_yellow, :on_blue, :on_magenta, :on_cyan, :on_white]
    COLOR_VALUES = FOREGROUND_COLOR_VALUES + BACKGROUND_COLOR_VALUES

    class Base
      attr_accessor :value, :selector

      def self.sub_engine(name)
        include ::Styles::SubEngines.const_get(name.to_s.capitalize)::PropertyMixin
      end

      def initialize(value, selector=nil)
        @value, @selector = value, selector
      end

      # Apply this property to a line and returned the result
      def apply(line)
        raise NotImplementedError, "apply method needs to be implemented for class: #{self.class.name}"
      end

      def colors
        ::Styles::Colors
      end
    end
  end
end

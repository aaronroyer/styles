require 'term/ansicolor'

module Styles
  module Properties
    FOREGROUND_COLOR_VALUES = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]
    BACKGROUND_COLOR_VALUES = [:on_black, :on_red, :on_green, :on_yellow, :on_blue, :on_magenta, :on_cyan, :on_white]
    COLOR_VALUES = FOREGROUND_COLOR_VALUES + BACKGROUND_COLOR_VALUES

    class Base
      attr_accessor :value, :selector

      def initialize(value, selector=nil)
        @value, @selector = value, selector
      end

      # Apply this property to a line and returned the result
      def apply(line)
        raise NotImplementedError, "apply method needs to be implemented for class: #{self.class.name}"
      end

      # Add PreprocessorMacros and add a method to each subclass to scan the constants for valid
      # values or arrays of values
      def self.inherited(subclass)
        subclass.extend PreprocessorMacros

        subclass.class_eval do
          def self.valid_values
            values = []
            constants.each do |constant|
              next unless constant.to_s.downcase.include?('value')
              value_or_values = const_get constant
              if value_or_values.is_a? Array
                values += value_or_values
              else
                values << value_or_values
              end
            end
            values
          end
        end
      end

      def colors
        ::Styles::Colors
      end
    end

    module PreprocessorMacros
      # By default do not strip original colors out of the line.
      def strip_original_color?
        false
      end

      # Specify that any color should be stripped from lines before processing.
      def strip_original_color
        define_singleton_method(:strip_original_color?) { true }
      end
    end
  end
end

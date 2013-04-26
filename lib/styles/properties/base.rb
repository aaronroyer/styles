module Styles
  module Properties
    COLOR_VALUES = [
      :black, :red, :green, :yellow, :blue, :magenta, :cyan, :white,
      :on_black, :on_red, :on_green, :on_yellow, :on_blue, :on_magenta, :on_cyan, :on_white,
    ]

    class Base
      attr_accessor :value, :selector

      def initialize(value, selector=nil)
        @value, @selector = value, selector
      end

      # Apply this property to a line and returned the result
      def apply(line)
        raise NotImplementedError
      end

      # Add a method to each subclass to scan the constants for valid values or arrays of values
      def self.inherited(subclass)
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
    end
  end
end

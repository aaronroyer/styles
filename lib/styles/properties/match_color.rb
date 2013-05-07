module Styles
  module Properties
    class MatchColor < Base
      sub_engine :color

      COLOR_PROPERTY_TYPE = :match

      def valid_value?
        [value].flatten.all? { |color| colors.is_basic_color?(color) || color == :none }
      end

      def color_to_use
        if value.is_a? Array
          value.map { |color| color == :none ? :no_fg_color : color }
        elsif value.is_a? Symbol
          value == :none ? :no_fg_color : value
        end
      end
    end
  end
end

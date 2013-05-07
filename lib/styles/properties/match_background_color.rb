module Styles
  module Properties
    class MatchBackgroundColor < Base
      sub_engine :color

      COLOR_PROPERTY_TYPE = :match

      def valid_value?
        [value].flatten.all? { |color| colors.is_basic_color?(color) || color == :none }
      end

      def color_to_use
        if value.is_a? Array
          value.map { |color| convert_to_background_color color }
        elsif value.is_a? Symbol
          convert_to_background_color value
        end
      end

      private

      def convert_to_background_color(color)
        return :no_bg_color if color == :none
        color =~ /^on_/ ? color : "on_#{color}".to_sym
      end
    end
  end
end

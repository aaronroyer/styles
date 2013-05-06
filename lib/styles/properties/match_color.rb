module Styles
  module Properties
    class MatchColor < Base
      sub_engine :color

      COLOR_PROPERTY_TYPE = :match

      def valid_value?
        [value].flatten.all? { |a_color| colors.is_basic_color?(a_color) }
      end

      def color_to_use
        value == :none ? :no_fg_color : value
      end
    end
  end
end

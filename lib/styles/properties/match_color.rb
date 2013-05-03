module Styles
  module Properties
    class MatchColor < Base
      sub_engine :color

      COLOR_PROPERTY_TYPE = :match

      def valid_value?
        [value].flatten.all? { |a_color| colors.is_basic_color?(a_color) }
      end
    end
  end
end

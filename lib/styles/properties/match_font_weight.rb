module Styles
  module Properties
    class MatchFontWeight < Base
      sub_engine :color

      COLOR_PROPERTY_TYPE = :match

      VALUES = [:normal, :bold].freeze

      def valid_value?
        [value].flatten.all? { |sub_value| VALUES.include?(sub_value) }
      end

      def color_to_use
        if value.is_a? Array
          value.map { |sub_value| sub_value == :normal ? :no_bold : sub_value }
        elsif value.is_a? Symbol
          value == :normal ? :no_bold : value
        end
      end
    end
  end
end

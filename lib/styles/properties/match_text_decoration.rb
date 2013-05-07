module Styles
  module Properties
    class MatchTextDecoration < Base
      sub_engine :color

      COLOR_PROPERTY_TYPE = :match

      # CSS value is line-through and not strikethrough, but include strikethrough as well
      VALUES = [:none, :underline, :line_through, :strikethrough, :blink].freeze

      def valid_value?
        [value].flatten.all? { |decoration| VALUES.include?(decoration) }
      end

      def color_to_use
        if value.is_a? Array
          value.map { |decoration| decoration == :none ? :no_text_decoration : decoration }
        elsif value.is_a? Symbol
          value == :none ? :no_text_decoration : value
        end
      end
    end
  end
end

module Styles
  module Properties
    class TextDecoration < Base
      sub_engine :color

      # CSS value is line-through and not strikethrough, but include strikethrough as well
      VALUES = [:none, :underline, :line_through, :strikethrough, :blink].freeze
      SKIP_VALUES = [:none].freeze

      def color_to_use
        # TODO: return multiple values here, negating each style?
        value == :none ? :no_underline : value
      end
    end
  end
end

module Styles
  module Properties
    class TextDecoration < Base
      sub_engine :color

      # CSS value is line-through and not strikethrough, but include strikethrough as well
      VALUES = [:none, :underline, :line_through, :strikethrough, :blink].freeze

      def color_to_use
        if value == :line_through
          :strikethrough
        elsif value == :none
          :no_text_decoration
        else
          value
        end
      end
    end
  end
end

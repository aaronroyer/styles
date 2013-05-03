module Styles
  module Properties
    class TextDecoration < Base
      sub_engine :color

      # CSS value is line-through and not strikethrough, but include strikethrough as well
      VALUES = [:none, :underline, :line_through, :strikethrough, :blink].freeze
      SKIP_VALUES = [:none].freeze
    end
  end
end

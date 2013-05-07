module Styles
  module Properties
    class Color < Base
      sub_engine :color

      def valid_value?
        return true if value == :none
        colors[value]
      end

      def color_to_use
        value == :none ? :no_fg_color : value
      end
    end
  end
end

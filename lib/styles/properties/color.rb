module Styles
  module Properties
    class Color < Base
      sub_engine :color

      SKIP_VALUES = [:none].freeze

      def valid_value?
        return true if value == :none
        colors[value]
      end
    end
  end
end

module Styles
  module Properties
    class Display < Base
      SHOW_VALUES = [:block, :inline, :inline_block, true]
      HIDE_VALUES = [:none, false]

      def apply(line)
        if SHOW_VALUES.include? value
          line
        elsif HIDE_VALUES.include? value
          nil
        else
          # TODO: Custom exception? Should this raise an exception at all?
          raise "Unrecognized value for 'display' property: #{value}"
        end
      end
    end
  end
end

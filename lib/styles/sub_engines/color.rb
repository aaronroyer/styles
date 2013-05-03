module Styles
  module SubEngines
    class Color
      module PropertyMixin
        def apply(line)
          klass = self.class
          if klass.constants.include?(:SKIP_VALUES) && klass::SKIP_VALUES.include?(value)
            line
          elsif has_valid_value?
            whole_line_apply(line)
          else
            line
          end
        end

        # Can be overridden if the color to use should be derived differently
        def color_to_use
          value
        end

        private

        def whole_line_apply(line)
          "#{colors[color_to_use]}#{line.chomp}#{colors[:reset]}"
        end

        def has_valid_value?
          if respond_to?(:valid_value?)
            valid_value?
          else
            self.class::VALUES.include?(value)
          end
        end
      end

      def process(properties, line)
        #
      end
    end
  end
end

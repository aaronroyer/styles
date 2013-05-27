module Styles
  module SubEngines
    class PreProcessor < Base
      def process(line)
        apply_function(line)

        line
      end

      private

      def apply_function(line)
        if (fn = line.prop(:function)) && fn.value.respond_to?(:call)
          line.text = fn.value.call(line.text)
        end
      end
    end
  end
end

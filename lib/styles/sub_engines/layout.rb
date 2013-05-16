module Styles
  module SubEngines
    class Layout < Base

      def process(line)
        # TODO: wrap Line in a LineLayoutCalculations object? make that a mixin?

        layout_sub_engine_properties = extract_sub_engine_properties line.applicable_properties

        if should_hide?(line)
          line.update(nil)
          return line
        end

        text_align(line)

        line
      end

      private

      def should_hide?(line)
        display_property = line.applicable_properties.find { |prop| prop.class == ::Styles::Properties::Display }
        display_property && ::Styles::Properties::Display::HIDE_VALUES.include?(display_property.value)
      end

      def text_align(line)
        # Make this work within the set width?

        ta = line.prop(:text_align)
        return unless ta

        size_no_color = colors.uncolor(line.current).size
        return if size_no_color >= terminal_width
        diff = terminal_width - size_no_color

        case ta.value
        when :left
          # do nothing
        when :right
          line.update("#{' ' * diff}#{line.current}")
        when :center
          before, after = (' ' * (diff/2)), (' ' * (diff/2 + diff%2))
          line.update("#{before}#{line.current}#{after}")
        end
      end

      def terminal_width
        require 'io/console'
        IO.console.winsize[1]
      rescue LoadError
        begin
          `tput co`.to_i
        rescue
          nil
        end
      end
    end
  end
end

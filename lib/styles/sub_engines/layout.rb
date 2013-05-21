require 'ostruct'

module Styles
  module SubEngines
    class Layout < Base

      def process(line)
        # TODO: wrap Line in a LineLayoutCalculations object? make that a mixin?

        layout_sub_engine_properties = extract_sub_engine_properties line.applicable_properties

        if should_hide?(line)
          line.text = nil
          return line
        end

        apply_padding_border_margin(line)
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

        size_no_color = colors.uncolor(line.text).size
        return if size_no_color >= terminal_width
        diff = terminal_width - size_no_color

        case ta.value
        when :left
          # do nothing
        when :right
          line.text = "#{' ' * diff}#{line.text}"
        when :center
          before, after = (' ' * (diff/2)), (' ' * (diff/2 + diff%2))
          line.text = "#{before}#{line.text}#{after}"
        end
      end

      def apply_padding_border_margin(line)
        padding, margin = (line.prop(:padding) || blank_space_property), (line.prop(:margin) || blank_space_property)
        border = line.prop(:border) || ::Styles::Properties::Border.new(:any, :border, :none)

        line.left = "#{' ' * margin.left}#{border.left_char}#{' ' * padding.left}"
        line.right = "#{' ' * padding.right}#{border.right_char}#{' ' * margin.right}"

        width = line.total_width
        text_width = line.text_width
        border_width = padding.left + text_width + padding.right
        blank_line = "#{' ' * width}\n"

        line.top = blank_line * margin.top

        if border.top == :none
          line.top << blank_line * padding.top
        else
          line.top << "#{' ' * margin.left}#{border.top_line_chars(border_width)}#{' ' * margin.right}\n"
          if padding.top > 0
            extender_line = "#{' ' * margin.left}#{border.left_char}#{' ' * border_width}#{border.right_char}#{' ' * margin.right}\n"
            line.top << extender_line * padding.top
          end
        end

        if border.bottom == :none
          line.bottom = blank_line * padding.bottom
        else
          line.bottom = ''
          if padding.bottom > 0
            extender_line = "#{' ' * margin.left}#{border.left_char}#{' ' * border_width}#{border.right_char}#{' ' * margin.right}\n"
            line.bottom << extender_line * padding.bottom
          end
          line.bottom << "#{' ' * margin.left}#{border.bottom_line_chars(border_width)}#{' ' * margin.right}\n"
        end

        line.bottom << blank_line * margin.bottom
      end

      def apply_margin(line)
        margin = line.prop(:margin)
        return unless margin

        if margin.left > 0
          line.left = ' ' * margin.left
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

      def blank_space_property
        OpenStruct.new(top: 0, right: 0, bottom: 0, left: 0)
      end

      def blank_border_property
        OpenStruct.new(top: :none, right: :none, bottom: :none, left: :none)
      end
    end
  end
end

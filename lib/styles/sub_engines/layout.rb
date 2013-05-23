require 'ostruct'

module Styles
  module SubEngines
    class Layout < Base

      def process(line)
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

        return unless padding || margin || border

        bg_color = if bg_color_prop = line.prop(:background_color)
                     bg_color_prop.valid_value? ? bg_color_prop.color_to_use : :none
                   else
                     :none
                   end

        line.left = (' ' * margin.left) + colors.force_color("#{border.left_char}#{' ' * padding.left}", bg_color)
        line.right = colors.force_color("#{' ' * padding.right}#{border.right_char}", bg_color) +(' ' * margin.right)

        width = line.total_width
        text_width = line.text_width
        border_width = padding.left + text_width + padding.right
        margin_line = "#{' ' * width}\n"
        padding_line = "#{' ' * margin.left}#{colors.color(' ' * border_width, bg_color)}#{' ' * margin.right}\n"

        line.top = margin_line * margin.top

        extender_line = (' ' * margin.left) +
          colors.force_color("#{border.left_char}#{' ' * border_width}#{border.right_char}", bg_color) +
          (' ' * margin.right) + "\n"

        if border.top == :none
          line.top << padding_line * padding.top
        else
          line.top << (' ' * margin.left) +
            colors.force_color("#{border.top_line_chars(border_width)}", bg_color) +
            (' ' * margin.right) + "\n"
          line.top << (extender_line * padding.top) if padding.top > 0
        end

        if border.bottom == :none
          line.bottom = padding_line * padding.bottom
        else
          line.bottom = ''
          line.bottom << (extender_line * padding.bottom) if padding.bottom > 0
          line.bottom << (' ' * margin.left) +
            colors.force_color("#{border.bottom_line_chars(border_width)}", bg_color) +
            (' ' * margin.right) + "\n"
        end

        line.bottom << margin_line * margin.bottom
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

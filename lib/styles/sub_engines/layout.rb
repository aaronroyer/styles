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

        apply_width_and_text_align(line)
        apply_padding_border_margin(line)

        line
      end

      private

      def should_hide?(line)
        display_property = line.applicable_properties.find { |prop| prop.class == ::Styles::Properties::Display }
        display_property && ::Styles::Properties::Display::HIDE_VALUES.include?(display_property.value)
      end

      def apply_width_and_text_align(line)
        # Make this work within the set width?

        width_prop, text_align_prop = line.prop(:width), line.prop(:text_align)
        size_no_color = colors.uncolor(line.text).size
        width = width_prop ? width_prop.width : terminal_width

        return if size_no_color >= width
        diff = width - size_no_color

        bg_color = if bg_color_prop = line.prop(:background_color)
                     bg_color_prop.color_to_use
                   else
                     :none
                   end

        if text_align_prop
          case text_align_prop.value
          when :left
            # Pad right only if width explicitly set
            line.text = "#{line.text}#{colors.color(' ' * diff, bg_color)}" if width_prop
          when :right
            pad = ' ' * diff
            pad = colors.color(pad, bg_color) if width_prop
            line.text = "#{pad}#{line.text}"
          when :center
            before, after = (' ' * (diff/2)), (' ' * (diff/2 + diff%2))
            before, after = [before, after].map { |pad| colors.color(pad, bg_color)} if width_prop
            line.text = "#{before}#{line.text}#{after}"
          end
        else
          # Assume left align, pad right only if width explicitly set
          line.text = "#{line.text}#{colors.color(' ' * diff, bg_color)}" if width_prop
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

        # First establish the main line padding and border
        line.left = colors.force_color("#{border.left_char}#{' ' * padding.left}", bg_color)
        line.right = colors.force_color("#{' ' * padding.right}#{border.right_char}", bg_color)

        # Calculate margins and add to the main line
        margin_left, margin_right =
          if margin.left == :auto || margin.right == :auto
            diff = terminal_width - line.total_width
            if diff > 0
              [(' ' * (diff/2)), (' ' * (diff/2 + diff%2))]
            else
              ['', '']
            end
          else
            [' ' * margin.left, ' ' * margin.right]
          end

        line.left = margin_left + line.left
        line.right = line.right + margin_right

        content_width = line.content_width
        border_width = padding.left + content_width + padding.right

        margin_line = "#{' ' * line.total_width}\n"
        padding_line = "#{margin_left}#{colors.color(' ' * border_width, bg_color)}#{margin_right}\n"

        line.top = margin_line * margin.top if margin.top.is_a?(Integer)

        extender_line = margin_left +
          colors.force_color("#{border.left_char}#{' ' * border_width}#{border.right_char}", bg_color) +
            margin_right + "\n"

        if border.top == :none
          line.top << padding_line * padding.top
        else
          line.top << margin_left +
            colors.force_color("#{border.top_line_chars(border_width)}", bg_color) +
              margin_right + "\n"
          line.top << (extender_line * padding.top) if padding.top > 0
        end

        if border.bottom == :none
          line.bottom = padding_line * padding.bottom
        else
          line.bottom = ''
          line.bottom << (extender_line * padding.bottom) if padding.bottom > 0
          line.bottom << margin_left +
            colors.force_color("#{border.bottom_line_chars(border_width)}", bg_color) +
              margin_right + "\n"
        end

        line.bottom << margin_line * margin.bottom if margin.bottom.is_a?(Integer)
      end

      def apply_margin(line)
        margin = line.prop(:margin)
        return unless margin

        if margin.left > 0
          line.left = ' ' * margin.left
        end
      end

      # Tries to determine terminal width, returns 80 by default
      def terminal_width
        require 'io/console'
        IO.console.winsize[1]
      rescue LoadError
        begin
          `tput co`.to_i
        rescue
          80
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

module Styles
  module Properties
    class Border < Base
      # :dashed the same as :dotted
      STYLES = [:solid, :dashed, :dotted, :double]

      SOLID_CHARS = { top: "\u2500", right: "\u2502", bottom: "\u2500", left: "\u2502",
        top_left: "\u250C", top_right: "\u2510", bottom_left: "\u2514", bottom_right: "\u2518" }.freeze
      SOLID_BOLD_CHARS = { top: "\u2501", right: "\u2503", bottom: "\u2501", left: "\u2503",
        top_left: "\u250F", top_right: "\u2513", bottom_left: "\u2517", bottom_right: "\u251B" }.freeze
      DOUBLE_CHARS = { top: "\u2550", right: "\u2551", bottom: "\u2550", left: "\u2551",
        top_left: "\u2554", top_right: "\u2557", bottom_left: "\u255A", bottom_right: "\u255D" }.freeze

      # dotted doesn't have its own corners, reuse solid
      DOTTED_CHARS = { top: "\u2504", right: "\u2506", bottom: "\u2504", left: "\u2506",
        top_left: "\u250F", top_right: "\u2513", bottom_left: "\u2517", bottom_right: "\u251B" }.freeze
      DASHED_CHARS = DOTTED_CHARS

      STYLE_CHARS = {
        solid: SOLID_CHARS, dotted: DOTTED_CHARS, dashed: DASHED_CHARS, double: DOUBLE_CHARS
      }.freeze

      sub_engine :layout
      other_names :border_left, :border_right, :border_top, :border_bottom

      attr_reader :top, :right, :bottom, :left

      def initialize(*args)
        if args.size == 1 && args.first.is_a?(Array)
          @sub_properties = args.first
        else
          super
          @sub_properties = nil
        end
        compute_all_border_values
      end

      def all_border_values
        [top, right, bottom, left]
      end

      # Generate methods for returning the proper characters to make up this border
      [
        :top_char, :right_char, :bottom_char, :left_char,
        :top_left_char, :top_right_char, :bottom_left_char, :bottom_right_char
      ].each do |method_name|
        str = method_name.to_s
        position = str.sub(/_char$/, '')

        define_method(method_name) do |*args|
          raise ArgumentError, "Wrong number of arguments to #{method_name}: #{args.size}" if args.size > 1

          return '' if position.split('_').any? { |side| send(side) == :none }

          side_style = send(str.split('_').first)
          return '' if side_style == :none
          times = args.size == 1 ? args.first.to_i : 1
          # TODO: check color validity
          style, color = side_style

          begin_color, end_color = if color != :default
            [colors[color], colors[:reset]]
          else
            ['', '']
          end

          "#{begin_color}#{STYLE_CHARS[style][position.to_sym] * times}#{end_color}"
        end
      end

      # Draws the top line portion of a border with the specified inner width
      def top_line_chars(width)
        return '' if top == :none
        tl = top_left_char.empty? ? (left == :none ? '' : ' ') : top_left_char
        tr = top_right_char.empty? ? (right == :none ? '' : ' ') : top_right_char
        "#{tl}#{top_char(width)}#{tr}"
      end

      # Draws the bottom line portion of a border with the specified inner width
      def bottom_line_chars(width)
        return '' if bottom == :none
        bl = bottom_left_char.empty? ? (left == :none ? '' : ' ') : bottom_left_char
        br = bottom_right_char.empty? ? (right == :none ? '' : ' ') : bottom_right_char
        "#{bl}#{bottom_char(width)}#{br}"
      end

      private

      def compute_all_border_values
        if @sub_properties
          set_all_border_values(:none)

          @sub_properties.each do |sub_prop|
            if sub_prop.name == :border
              set_all_border_values(parse_value(sub_prop.value))
            else
              set_border_value($1, parse_value(value))
              set_border_value(sub_prop.name.to_s.sub(/^border_/, ''), parse_value(sub_prop.value))
            end
          end
        else
          if name == :border
            set_all_border_values(parse_value(value))
          elsif name.to_s =~ /border_(\w+)/
            set_all_border_values(:none)
            set_border_value($1, parse_value(value))
          end
        end
      end

      # Converts a "raw" value into an array of values specifying a border. Returns an array
      # of the parsed sub-values, the style first and color second,
      #
      # Values can be in the following forms.
      #
      # Only a style, with default color assumed
      #   'solid'
      # or
      #   :solid
      #
      # A style and a color
      #   'dotted red'
      def parse_value(val)
        return val if val == :none
        default = [:solid, :default]
        if val.is_a?(Symbol) && STYLES.include?(val)
          [val, :default]
        elsif val.is_a?(String)
          parts = val.split
          style = (parts[0] && STYLES.include?(parts[0].to_sym)) ? parts[0].to_sym : :solid
          color = parts[1] ? parts[1].to_sym : :default
          [style, color]
        else
          default
        end
      end

      def set_all_border_values(val)
        @top = @right = @bottom = @left = val
      end

      def set_border_value(which, val)
        instance_variable_set("@#{which}".to_sym, val)
      end
    end
  end
end

require 'term/ansicolor'

module Styles
  # Basically a wrapper around Term::ANSIColor but also adds combination foreground and background
  # colors (e.g. :red_on_white). Returns nil with an invalid color specification.
  class Colors
    # Map CSS-style value to ANSI code name, where they are different
    CSS_TO_ANSI_VALUES = {
      :line_through => :strikethrough
    }.freeze

    VALID_VALUES = (::Term::ANSIColor.attributes + [:none] + CSS_TO_ANSI_VALUES.keys).freeze

    FOREGROUND_COLOR_VALUES = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white].freeze
    BACKGROUND_COLOR_VALUES = [:on_black, :on_red, :on_green, :on_yellow, :on_blue, :on_magenta, :on_cyan, :on_white].freeze
    COLOR_VALUES = (FOREGROUND_COLOR_VALUES + BACKGROUND_COLOR_VALUES).freeze

    # Retrieve color codes with the corresponding symbol. Can be basic colors like :red or
    # "compound" colors specifying foreground and background colors like :red_on_blue.
    #
    # Any number of colors can be specified, either as multiple arguments or in an array.
    def self.[](*colors)
      colors.flatten!
      valid_colors = []
      colors.each do |color|
        if is_valid_basic_value? color
          valid_colors << (CSS_TO_ANSI_VALUES[color] || color)
        elsif color_parts = is_compound_color?(color)
          valid_colors += color_parts
        end
      end

      unless valid_colors.empty?
        valid_colors.inject('') { |str, color| str += ansi_color.send(color) }
      end
    end

    def self.valid?(color)
      is_valid_basic_value?(color) || is_compound_color?(color)
    end

    def self.is_basic_color?(color)
      COLOR_VALUES.include?(color)
    end

    # Returns an array of colors if the given symbol represents a compound color.
    # Returns nil otherwise.
    def self.is_compound_color?(color)
      if color.to_s =~ /(\w+)_on_(\w+)/
        colors = [$1.to_sym, "on_#{$2}".to_sym]
        if colors.all? { |c| COLOR_VALUES.include? c }
          colors
        end
      end
    end

    private

    # Is this a valid non-compound value? Includes colors but also stuff like :bold and
    # other non-color things.
    def self.is_valid_basic_value?(color)
      VALID_VALUES.include?(color)
    end

    def self.ansi_color
      ::Term::ANSIColor
    end
  end
end

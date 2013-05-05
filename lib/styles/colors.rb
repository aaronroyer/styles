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

    class << self
      alias_method :c, :[]
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

    # Produces a string of color codes to transition from one set of colors to another.
    #
    # If hard is true then all foregound and background colors are reset before adding the after
    # colors. In other words, no colors are allowed to continue, even if not replaced.
    #
    # If hard is false then colors that are not explicitly replaced by new colors are not reset.
    # This means that if there are foreground and background before colors and only a foreground
    # after color then even though the foreground color is replaced by the new one the background
    # color is allowed to continue and is not explicitly reset.
    #
    # Regardless of whether all colors are reset, output of unnecessary codes is avoided. This
    # means, for example, that if any before colors are replaced by new colors of the same
    # category (foreground, background, underline, etc.) then there will never be an explicit
    # reset because that would be redundant and merely add more characters.
    def self.color_transition(before_colors, after_colors, hard=true)
      before_colors = [before_colors] unless before_colors.is_a?(Array)
      after_colors = [after_colors] unless after_colors.is_a?(Array)

      before_categories, after_categories = categorize_colors(before_colors), categorize_colors(after_colors)

      # Nothing to do if before and after colors are the same
      return '' if before_categories == after_categories

      transition = ''

      # Explicit reset is necessary if all colors are not replaced and we want a hard reset
      transition << c(:reset) if hard && before_categories.keys.sort != after_categories.keys.sort

      after_categories.each_pair { |cat, color| transition << c(color) }

      transition
    end

    private

    # Put colors into categories which include background (:bg) and foreground (:fg). All other
    # types of colors are in their own category. Only the last color of each type will end up being
    # in a given category and results are returned as a hash (category => color). This is in
    # support of the color_transition method so the results are a bit specifically tailored.
    def self.categorize_colors(colors)
      categories = {}
      colors.each do |color|
        category = if FOREGROUND_COLOR_VALUES.include? color
                     :fg
                   elsif BACKGROUND_COLOR_VALUES.include? color
                     :bg
                   else
                     color
                   end
        categories[category] = color
      end
      categories
    end

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

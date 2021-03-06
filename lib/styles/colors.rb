require 'term/ansicolor'

module Styles
  # Basically a wrapper around Term::ANSIColor but also adds combination foreground and background
  # colors (e.g. :red_on_white). Returns nil with an invalid color specification.
  class Colors
    # Map CSS-style value to ANSI code name, where they are different
    CSS_TO_ANSI_VALUES = {
      :line_through => :strikethrough
    }.freeze

    FOREGROUND_COLOR_VALUES = [
      :black, :red, :green, :yellow, :blue, :magenta, :cyan, :white
    ].freeze

    BACKGROUND_COLOR_VALUES = [
      :on_black, :on_red, :on_green, :on_yellow, :on_blue, :on_magenta, :on_cyan, :on_white
    ].freeze

    TEXT_DECORATION_VALUES = [:underline, :strikethrough, :blink].freeze

    COLOR_VALUES = (FOREGROUND_COLOR_VALUES + BACKGROUND_COLOR_VALUES).freeze
    OTHER_STYLE_VALUES = [:bold, :italic, :underline, :underscore, :blink, :strikethrough]

    # Only :reset is available to represent the complete absence of color and styling. There are no
    # fine-grained negative codes to just remove foreground color or just remove bold. Our API
    # should provide these to allow these kind of fine-grained transitions to other color states.
    NEGATIVE_PSEUDO_VALUES = [
      :no_fg_color, :no_bg_color, :no_bold, :no_italic, :no_text_decoration,
      :no_underline, :no_blink, :no_strikethrough
    ].freeze

    VALID_VALUES = (::Term::ANSIColor.attributes + [:none] + CSS_TO_ANSI_VALUES.keys).freeze
    VALID_VALUES_AND_PSEUDO_VALUES = (VALID_VALUES + NEGATIVE_PSEUDO_VALUES).freeze

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
        valid_colors.uniq!
        valid_colors.sort!
        valid_colors.unshift(:reset) if valid_colors.delete(:reset)

        valid_colors.inject('') { |str, color| str += ansi_color.send(color) }
      end
    end

    class << self
      alias_method :c, :[]
    end

    # Apply any valid colors to a string and auto-reset (if any colors applied). Does not apply
    # colors to an empty string.
    def self.color(string, *colors)
      return string if string.nil? or string.empty?
      colors.flatten!
      colors.reject! { |col| col == :none || !VALID_VALUES.include?(col) }
      if colors.any?
        "#{colors.map { |col| c(col) }.join}#{string}#{c(:reset)}"
      else
        string
      end
    end

    # Apply any valid colors to a string and auto-reset (if any colors applied). If there are any
    # resets in the middle of the string, reapply the colors after them.
    def self.force_color(string, *colors)
      return string if string.nil? or string.empty?
      colors.flatten!
      colors.reject! { |col| col == :none || !VALID_VALUES.include?(col) }
      if colors.any?
        codes = colors.map { |col| c(col) }.join
        "#{codes}#{string.gsub(c(:reset), c(:reset) + codes)}#{c(:reset)}"
      else
        string
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

    # Gives a pair of color codes for transitions into and out of a colored substring in the
    # middle of a possibly differently colored line.
    def self.line_substring_color_transitions(line_colors, substring_colors)
      line_colors, substring_colors = Array(line_colors), Array(substring_colors)

      implied_substring_colors = []
      line_colors.each do |line_col|
        cat = category(line_col)
        replaced = substring_colors.any? { |substr_col| category(substr_col) == cat}
        implied_substring_colors << line_col unless replaced
      end

      [
        color_transition(line_colors, substring_colors, false),
        color_transition(substring_colors + implied_substring_colors, line_colors)
      ]
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
      before_colors, after_colors = Array(before_colors), Array(after_colors)

      before_categories, after_categories = categorize(before_colors), categorize(after_colors)

      # Nothing to do if before and after colors are the same
      return '' if before_categories == after_categories

      transition = ''
      should_reset = false
      colors_to_apply = []

      # Explicit reset is necessary if we want a hard transition and all colors in all
      # categories are not replaced.
      if hard
        before_categories.each_pair do |cat, before_color|
          next if negative?(before_color)
          after_color = after_categories[cat]
          if !after_color || negative?(after_color)
            should_reset = true
            break
          end
        end
      end

      # If soft transition then the only time we need an explicit reset is when we have a color
      # in a category that is explicitly turned off with a negative value. This also applies
      # to hard transitions.
      unless should_reset
        after_categories.each_pair do |cat, after_color|
          before_color = before_categories[cat]
          if before_color && negative?(after_color) && !negative?(before_color)
            should_reset = true
            break
          end
        end
      end

      after_categories.each_pair do |cat, after_color|
        before_color = before_categories[cat]
        if !negative?(after_color)
          transition << c(after_color) unless before_color == after_color && !should_reset
        end
      end

      # If we are resetting but using a soft transition then all colors execept negated ones
      # need to be set again after the reset.
      if should_reset && !hard
        before_categories.values.each do |color|
          unless negative?(color) || after_categories.values.include?(negate(color))
            transition << c(color) unless after_categories.keys.include?(category(color))
          end
        end
      end

      transition.prepend(c(:reset)) if should_reset
      transition
    end

    def self.negative?(color)
      NEGATIVE_PSEUDO_VALUES.include?(color)
    end

    def self.uncolor(string)
      ansi_color.uncolor(string)
    end

    private

    # Exists to support color_transition - it's a bit specialized. Takes an array of colors and
    # puts them in a hash, category => value. The extra things that this does is
    #   1. translates the no_text_decoration negative pseudo-value into all of the negative values
    #      in the text_decoration category
    #   2. if there is any text_decoration category value then it adds negations for the other
    #      text_decoration values - this is because even though they don't replace each other in
    #      terminals (for example: adding blink doesn't turn off existing underline) but we want
    #      them to in order to match CSS-style behavior so we need to add this in
    #
    # TODO: refactor this text_decoration stuff and probably move it elsewhere so it makes more
    #       sense - it could be cleaner and this probably isn't the place for it
    def self.categorize(colors)
      categories = {}

      if categories.delete(:no_text_decoration)
        TEXT_DECORATION_VALUES.each do |td|
          categories[td] = negate(td)
        end
      end

      colors.each { |color| categories[category(color)] = color }

      TEXT_DECORATION_VALUES.each do |td|
        if categories.values.include?(td)
          (TEXT_DECORATION_VALUES - [td]).each do |other_td|
            categories[other_td] = negate(other_td) unless categories.values.include?(other_td)
          end
        end
      end

      categories
    end

    # Get the category of a color.
    #
    # Foreground colors are in the :fg_color category, background colors in :bg_color. Other style
    # "colors" are in their own category (:bold, :underline, etc.). Negative pseudo-values are in
    # the category they negate, so :no_fg_color is in :fg_color and :no_bold is in :bold.
    def self.category(color)
      return nil unless VALID_VALUES_AND_PSEUDO_VALUES.include?(color)

      if FOREGROUND_COLOR_VALUES.include?(color) || color == :no_fg_color
        :fg_color
      elsif BACKGROUND_COLOR_VALUES.include?(color) || color == :no_bg_color
        :bg_color
      else
        color.to_s.sub(/^no_/, '').to_sym
      end
    end

    # Get the negative pseudo-value for a color or style. Compound colors and already
    # negative values cannot be negated.
    def self.negate(color)
      return nil unless is_valid_basic_value?(color)

      if FOREGROUND_COLOR_VALUES.include?(color)
        :no_fg_color
      elsif BACKGROUND_COLOR_VALUES.include?(color)
        :no_bg_color
      else
        color.to_s.prepend('no_').to_sym
      end
    end

    # Is this a valid non-compound value? Includes colors but also stuff like :bold and
    # other non-color things.
    def self.is_valid_basic_value?(color)
      VALID_VALUES.include?(color)
    end

    def self.valid_value_or_pseudo_value?(value)
      VALID_VALUES_AND_PSEUDO_VALUES.include?(value)
    end

    def self.ansi_color
      ::Term::ANSIColor
    end
  end
end

module Styles
  module Properties
    class MatchColor < Base
      VALUES = ::Term::ANSIColor.attributes

      def apply(line)
        return line unless VALUES.include?(value)
        # TODO: Handle situation where color codes can be matched and wreck everything - the problem
        #       can come up when you are trying to match a number in already colorized text. Should
        #       color be stripped from the input first by default?
        line.gsub(selector) {|match| "#{color.send(value)}#{match}#{color.reset}" }
      end
    end
  end
end

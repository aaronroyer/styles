module Styles
  module Properties
    class TextAlign < Base
      sub_engine :layout

      # Not included: justify and inherit
      VALUES = [:left, :right, :center]
    end
  end
end

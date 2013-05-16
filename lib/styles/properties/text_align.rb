module Styles
  module Properties
    class TextAlign < Base
      sub_engine :layout

      # Left out: justify and inherit
      VALUES = [:left, :right, :center]
    end
  end
end

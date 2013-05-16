module Styles
  module Properties
    class Display < Base
      sub_engine :layout

      SHOW_VALUES = [:block, :inline, :inline_block, true].freeze
      HIDE_VALUES = [:none, false].freeze
    end
  end
end

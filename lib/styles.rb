module Styles

  # Raised when a stylesheet cannot be loaded, either because it does not
  # exist or because it is malformed.
  class StylesheetLoadError < LoadError
  end
end

require 'styles/version'
require 'styles/core_ext'
require 'styles/colors'
require 'styles/line'
require 'styles/engine'
require 'styles/sub_engines'
require 'styles/properties'
require 'styles/rule'
require 'styles/stylesheet'
require 'styles/application'

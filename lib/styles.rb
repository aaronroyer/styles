require 'styles/version'
require 'styles/core_ext'
require 'styles/properties'
require 'styles/rule'
require 'styles/stylesheet'

module Styles
  DEFAULT_DIR = File.join(ENV['HOME'], '.styles')

  def self.filters_dir
    ENV['STYLES_DIR'] || DEFAULT_DIR
  end
end

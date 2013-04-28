require 'styles/version'
require 'styles/core_ext'
require 'styles/properties'
require 'styles/rule'
require 'styles/stylesheet'
require 'styles/engine'
require 'styles/application'

module Styles
  def self.home_dir
    home = ENV['HOME']
    home = ENV['USERPROFILE'] unless home
    if !home && (ENV['HOMEDRIVE'] && ENV['HOMEPATH'])
      home = File.join(ENV['HOMEDRIVE'], ENV['HOMEPATH'])
    end
    home = File.expand_path('~') unless home
    home = 'C:/' if !home && RUBY_PLATFORM =~ /mswin|mingw/
    home
  end

  DEFAULT_DIR = File.join(home_dir, '.styles')

  def self.stylesheets_dir
    ENV['STYLES_DIR'] || DEFAULT_DIR
  end
end

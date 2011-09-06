require 'nokogiri'
require 'redcarpet'
require 'tilt'
require 'ostruct'
require 'fileutils'

module Reacco
  extend self

  def root(*a)
    File.join File.expand_path('../../', __FILE__), *a
  end

  autoload :Readme,     'reacco/readme'
  autoload :Generator,  'reacco/generator'

  module Filters
    autoload :Brief,    'reacco/filters/brief'
    autoload :Sections, 'reacco/filters/sections'
    autoload :Hgroup,   'reacco/filters/hgroup'
    autoload :Literate, 'reacco/filters/literate'
    autoload :PreLang,  'reacco/filters/prelang'
  end
end


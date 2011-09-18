require 'nokogiri'
require 'redcarpet'
require 'tilt'
require 'ostruct'
require 'fileutils'

# ## Reacco [module]
# This is the main module.
#
module Reacco
  extend self

  # ### root [class method]
  # Returns the root path of the Reacco gem.
  # You may pass additional parameters.
  #
  #     Reacco.root
  #     #=> '/usr/local/ruby/gems/reacco-0.0.1'
  #
  def root(*a)
    File.join File.expand_path('../../', __FILE__), *a
  end

  # ### markdown [class method]
  # Returns the Redcarpet Markdown processor.  This is an instance of
  # `Redcarpet` with all the right options plugged in.
  #
  #     Reacco.markdown
  #     #=> #<Redcarpet::Markdown ...>
  #
  def markdown
    Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      :fenced_code_blocks => true)
  end

  autoload :Readme,       'reacco/readme'
  autoload :Generator,    'reacco/generator'
  autoload :Extractor,    'reacco/extractor'

  module Filters
    autoload :Brief,      'reacco/filters/brief'
    autoload :Sections,   'reacco/filters/sections'
    autoload :Hgroup,     'reacco/filters/hgroup'
    autoload :Literate,   'reacco/filters/literate'
    autoload :PreLang,    'reacco/filters/prelang'
    autoload :HeadingID,  'reacco/filters/headingid'
    autoload :TOC,        'reacco/filters/toc'
  end
end


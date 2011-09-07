$:.unshift File.expand_path('../../lib', __FILE__)
require 'contest'
require 'reacco'

class UnitTest < Test::Unit::TestCase
  def root(*a)
    Reacco.root *a
  end
end

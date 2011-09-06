require './lib/reacco/version'

Gem::Specification.new do |s|
  s.name = "reacco"
  s.version = Reacco.version
  s.summary = %{Readme prettifier.}
  s.description = %Q{Reacco makes your readme's pretty.}
  s.authors = ["Rico Sta. Cruz"]
  s.email = ["rico@sinefunc.com"]
  s.homepage = "http://github.com/rstacruz/reacco"
  s.files = `git ls-files`.strip.split("\n")
  s.executables = Dir["bin/*"].map { |f| File.basename(f) }

  s.add_dependency 'redcarpet', '~> 2.0.0b3'
  s.add_dependency 'nokogiri',  '~> 1.5'
  s.add_dependency 'tilt'
end

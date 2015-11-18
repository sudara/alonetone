$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "greenfield/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "greenfield"
  s.version     = Greenfield::VERSION
  s.authors     = ["Peter","Sudara"]
  s.email       = ["support@alonetone.com"]
  s.homepage    = "http://listenapp.com"
  s.summary     = "Summary of Greenfield."
  s.description = "Listenapp.com"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2"
  s.add_dependency "acts_as_list"
  s.add_dependency "has_permalink"

  s.add_development_dependency "sqlite3"
end

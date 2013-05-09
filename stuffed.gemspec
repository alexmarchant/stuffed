Gem::Specification.new do |s|
  s.name        = 'stuffed'
  s.version     = '0.1.0'
  s.date        = '2013-05-07'
  s.summary     = "Stuffed blocks websites."
  s.description = "A simple h"
  s.authors     = ["Alex Marchant"]
  s.email       = "alexjmarchant@gmail.com"
  s.files       = ["bin", "bin/stuffed", "Gemfile", "lib", "lib/stuffed", "lib/stuffed/cli.rb", "lib/stuffed/stuff.rb", "lib/stuffed.rb", "Rakefile", "spec", "spec/cli_spec.rb", "spec/spec_helper.rb", "spec/stuff_spec.rb", "stuffed.gemspec"]
  s.executables = ["stuffed"]
  s.require_paths = ["lib"]
  s.homepage    =
    'http://alexmarchant.com/stuffed'

  s.add_development_dependency 'rake', "~> 0.9"
  s.add_development_dependency 'rspec', "~> 2.11"
  s.add_development_dependency 'pry', "~> 0.9"
end

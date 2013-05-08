Gem::Specification.new do |s|
  s.name        = 'stuffed'
  s.version     = '0.0.0'
  s.date        = '2013-05-07'
  s.summary     = "Stuffed blocks websites."
  s.description = "A simple h"
  s.authors     = ["Alex Marchant"]
  s.email       = "alexjmarchant@gmail.com"
  s.files       = ["lib/stuffed.rb"]
  s.executables = ["stuffed"]
  s.homepage    =
    'http://alexmarchant.com/stuffed'

  s.add_development_dependency 'rake', "~> 0.9"
  s.add_development_dependency 'rspec', "~> 2.11"
end

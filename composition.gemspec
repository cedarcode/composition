$:.push File.expand_path('../lib', __FILE__)
require 'composition/version'

Gem::Specification.new do |s|
  s.name        = 'composition'
  s.version     = Composition::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.date        = '2017-03-01'
  s.summary     = 'Composition for ActiveRecord models'
  s.description = 'Composition for ActiveRecord models'
  s.authors     = ['Marcelo Casiraghi']
  s.email       = 'marcelo@cedarcode.com'
  s.homepage    = 'https://github.com/marceloeloelo/composition'
  s.license     = 'MIT'
  s.metadata    = {
    'source_code_uri' => 'https://github.com/marceloeloelo/composition'
  }

  s.files         = `git ls-files -- lib/*`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")

  s.add_dependency 'activerecord', '>=3.2'
  s.add_dependency 'activesupport', '>=3.2'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'rails'
  s.add_development_dependency 'sqlite3'
end

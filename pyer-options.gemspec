# coding: utf-8

Gem::Specification.new do |s|
  s.name          = 'pyer-options'
  s.version       = '2.0.3'
  s.author        = 'Pierre BAZONNARD'
  s.email         = ['pierre.bazonnard@gmail.com']
  s.homepage      = 'https://github.com/pyer/options'
  s.summary       = 'Simple options parser'
  s.description   = 'Simple options parser inspired by slop'
  s.license       = 'MIT'

  s.files         = ['lib/pyer/options.rb']
  s.executables   = []
  s.test_files    = []
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.1.0'
#  s.add_dependency 

  s.add_development_dependency 'rake',     '~> 0'
  s.add_development_dependency 'minitest', '= 5.4.2'
end

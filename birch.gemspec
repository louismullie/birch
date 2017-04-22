$:.push File.expand_path('../lib', __FILE__)
require 'birch/version'

Gem::Specification.new do |s|
  
  s.name        = 'birch'
  s.version     = Birch::VERSION
  s.authors     = ['Louis Mullie', 'Colin Surprenant']
  s.email       = ['louis.mullie@gmail.com', 'colin.surprenant@gmail.com']
  s.homepage    = 'https://github.com/louismullie/birch'
  s.summary     = %q{ A basic Ruby tree implementation with an optional C extension for speed. }
  s.description = %q{ }

  s.files = Dir.glob('lib/**/*.rb') +
  Dir.glob('ext/**/*.{c,h,rb}')

  if RUBY_PLATFORM =~ /java/
    s.platform = 'java'
  else
    s.extensions << 'ext/birch/extconf.rb'
  end

  s.add_development_dependency 'rspec', '2.12.0'
  s.add_development_dependency 'rake', '3.5.0'
end
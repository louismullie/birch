require 'rspec/core/rake_task'
require 'rake/clean'
require 'rspec/core/rake_task'

task :default => :spec

desc "run specs"
task :spec do
  RSpec::Core::RakeTask.new
end

desc "celan, compile C ext and copy objects into lib"
task :make => [:clean] do
  Dir.chdir("ext/birch") do
    ruby "extconf.rb"
    sh "make"
  end
  cp "ext/birch/native.bundle", "lib/birch"
end

CLEAN.include('ext/**/*{.o,.log,.so,.bundle}')
CLEAN.include('lib/**/*{.o,.log,.so,.bundle}')
CLEAN.include('ext/**/Makefile')

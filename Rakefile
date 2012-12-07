require 'rspec/core/rake_task'

# require 'rake'
require 'rake/clean'
# require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task :default => :spec

desc "clean, make and run specsrkae"
task :spec do
  RSpec::Core::RakeTask.new
end

desc "compile C ext and FFI ext and copy objects into lib"
task :make => [:clean] do
  Dir.chdir("ext/birch") do
    ruby "extconf.rb"
    sh "make"
  end
  cp "ext/birch/birch.bundle", "lib/birch"

  # Dir.chdir("ext/bloombroom/hash/ffi") do
  #   ruby "extconf.rb"
  #   sh "make"
  # end
  # cp "ext/bloombroom/hash/ffi/ffi_fnv.bundle", "lib/bloombroom/hash"
end

CLEAN.include('ext/**/*{.o,.log,.so,.bundle}')
CLEAN.include('lib/**/*{.o,.log,.so,.bundle}')
CLEAN.include('ext/**/Makefile')

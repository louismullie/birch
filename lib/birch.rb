if RUBY_PLATFORM =~ /java/
  require 'birch/pure'
else
  require 'birch/native'
end
require 'birch/version'
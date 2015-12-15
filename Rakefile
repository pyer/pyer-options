# Options Rakefile

require 'rubygems'
require 'rubygems/package'
require 'rubygems/installer'
require 'rake'
require 'rake/clean'
$LOAD_PATH << 'lib/pyer'

spec = Gem::Specification::load("pyer-options.gemspec")
target = "#{spec.name}-#{spec.version}.gem"

desc 'Test gem'
task :test do
  ruby "test/test_options.rb"
end

desc 'Default is build'
task :default => [:build]

desc 'Build gem'
task :build => [:clean] do
  Gem::Package.build spec, true
end
 
desc 'Install gem'
task :install do
  gi=Gem::Installer.new target
  gi.install
end
 
CLEAN.include "#{target}"

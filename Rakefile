require 'bundler/setup'
require 'rspec/core/rake_task'
require 'puck'

desc 'Build a self-contained JAR'
task :build do
  Puck::Jar.new.create
end

RSpec::Core::RakeTask.new(:spec) do |r|
  r.rspec_opts = '--tty'
end

task :default => :spec
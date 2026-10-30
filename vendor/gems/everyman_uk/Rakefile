#!/usr/bin/env rake
require 'bundler/gem_tasks'

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib/everyman_uk'
  t.test_files = FileList['test/lib/**/*_test.rb']
  t.verbose = true
end

Rake::TestTask.new do |t|
  t.libs << 'lib/everyman_uk'
  t.name = :live
  t.test_files = FileList['test/live/*_test.rb']
  t.verbose = true
end

# http://erniemiller.org/2014/02/05/7-lines-every-gems-rakefile-should-have/
desc 'run gem console'
task :console do
  require 'irb'
  require 'irb/completion'
  require 'everyman_uk'
  ARGV.clear
  IRB.start
end

task default: :test

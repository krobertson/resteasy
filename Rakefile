require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'resteasy')
require 'resteasy'

desc 'Test the RestEasy library.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'resteasy'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

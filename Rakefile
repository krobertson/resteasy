require 'rubygems'
require 'hoe'
require './lib/resteasy'

# RubyGem tasks
Hoe.new('resteasy', RestEasy::VERSION) do |p|
  p.author = 'Ken Robertson'
  p.email = 'ken@invalidlogic.com'
  p.summary = 'Simple generic client library for REST webservices'
  p.description = p.paragraphs_of('Readme.txt', 2..2).join("\n\n")
  p.url = p.paragraphs_of('Readme.txt', 0).first.split(/\n/)[2..-1].map { |u| u.strip }
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps << ['active_support']
end

# Console 
desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/resteasy.rb"
end

# Code coverage
task :coverage do
  system("rm -fr coverage")
  system("rcov test/test_*.rb")
  system("open coverage/index.html")
end
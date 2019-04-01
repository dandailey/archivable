require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('archivable', '0.1.0') do |p|
  p.description    = "Add ActiveRecord methods for managing an arichive status."
  p.url            = "" #"http://github.com/dandailey/archivable"
  p.author         = "Dan Dailey"
  p.email          = "dan@officetoweb.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

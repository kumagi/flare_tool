#!/usr/bin/ruby
require "yaml"
def printf s
  print s
  STDOUT.flush
end
def each_node command
  threads = []
  nodes = YAML.load_file 'nodelist.yaml'
  printf "command: #{command} ..."
  nodes.each{ |node|
    threads << Thread.new{
      system("ssh #{node} #{command} < /dev/null &> /dev/null")
    }
  }
  threads.each{ |t| t.join}
  puts "done."
end

puts "restarting couchbase..."
each_node "sudo service couchbase-server stop"
each_node "sudo service couchbase-server start"
puts 'done'

#!/usr/bin/ruby
require 'yaml'
nodes = YAML.load_file("nodelist.yaml")
nodes.each{|node|
  node.chomp!
  puts "node: #{node}"
  puts `ssh #{node} 'rm ~/.bashrc' -rf`
  puts `scp .bashrc #{node}:~/`
}

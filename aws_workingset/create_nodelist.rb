#!/usr/bin/ruby
require 'yaml'
nodelist = YAML.load_file "nodelist.yaml"
ip = `hostname -i`.scan(/(10\.[0-9]+\.[0-9]+\.[0-9]+)/)[0][0]
nodelist << ip
File.open("all_node_list.yaml","w"){ |f| YAML.dump(nodelist, f)}

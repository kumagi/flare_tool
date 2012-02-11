#!/usr/bin/ruby
require 'yaml'
nodes = YAML.load_file("nodelist.yaml")
t = []
nodes.each{ |n|
  t << Thread.new{
    `ssh #{n} "while true; do echo 'hello'; sleep 1; done" > /dev/null`
  }
}
t.each{ |th| th.join}

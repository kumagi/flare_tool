#!/usr/bin/ruby
require 'yaml'
ths = []
nodes = YAML.load_file "nodelist.yaml"
nodes.each{ |node|
  next if node == ""
  ths << Thread.new{
    `ssh #{node} "killall -q ruby"`
    `ssh #{node} "killall -q python"`
    `ssh #{node} "sudo killall -q flarei"`
    `ssh #{node} "sudo killall -q flared"`
    `ssh #{node} "sudo killall -q -KILL flared"`
  }
}
ths.each{ |t| t.join}

`killall -q python`
`sudo killall -q flarei`
`sudo killall -q flared`
`rm flaredata/* -rf`

`killall -q ruby`

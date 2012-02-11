#!/usr/bin/ruby
require 'yaml'
ip = `hostname -i`.scan(/(10\.[0-9]+\.[0-9]+\.[0-9]+)/)[0][0]
File.open("myip.yaml","w"){ |f| YAML.dump(ip, f)}

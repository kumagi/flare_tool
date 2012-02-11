#!/usr/bin/ruby
require 'yaml'
filename="hoge.tar.gz"
`tar cvzf #{filename} *.yaml`
threads = []
nodelist = YAML.load_file "nodelist.yaml"
nodelist.each{ |node|
  puts "sending #{node} begin"
  threads << Thread.new{
    `ssh #{node} "rm *.yaml -rf"`
    `scp #{filename} #{node}:~/`
    `ssh #{node} "tar xvf #{filename}; rm #{filename}"`
    `ssh #{node} "./save_myip.rb"`
    # $stderr.write "ssh #{node} '#{command}'\n"
    puts "sending #{node} done"
  }
}
threads.each{ |t| t.join}
`rm #{filename} -rf`
puts 'finish'

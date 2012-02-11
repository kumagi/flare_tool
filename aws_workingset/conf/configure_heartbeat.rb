#!/usr/bin/ruby
require 'yaml'

def parallel_do command
  puts "command: #{command}"
  nodes = YAML.load_file("nodelist.yaml")
  threads = []
  nodes.each{|node|
    threads << Thread.new { `ssh #{node} "#{command}"` }
  }
  threads.each{|t| t.join}
end


myip = `hostname -i`.split(' ').reject{ |d| !d.match /10./}[0]

raise "MYIP must be set." if myip.to_i == 0

filename = "heartbeat.conf"
`./pass.rb`
# puts substitute_command.chomp
["ruby conf/configure -a #{myip} -f #{filename}",
 "sudo cp #{filename} /etc/init/",
 "sudo killall -KILL heartbeat.rb < /dev/null &> /dev/null ",
 "sudo killall heartbeat.rb < /dev/null &> /dev/null ",
 "sudo service heartbeat start < /dev/null &> /dev/null "].each{|c| parallel_do c}

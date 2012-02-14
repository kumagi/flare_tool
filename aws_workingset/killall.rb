#!/usr/bin/ruby
require 'yaml'
ths = []

def printf s
  print s
  STDOUT.flush
end
printf "killing sshd..."
`./kill_ssh.rb`
puts 'finish'

printf 'killing python...'
`killall -q python`
`killall -q -KILL python`
puts 'finish'

nodes = YAML.load_file "nodelist.yaml"
nodes.each{ |node|
  next if node == ""
  ths << Thread.new{
    `ssh #{node} "killall -q ruby;killall -q -KILL ruby;killall -q python;killall -q -KILL python;killall -q ssh-agent;killall -q -KILL ssh-agent; ./kill_ssh.rb"`
    puts "killall in #{node} finish"
  }
}

ths.each{ |t| t.join}

printf 'killing ssh-agent'
`killall -q ssh-agent`
puts 'finish'

printf 'killing ssh-agent...'
`killall -q -KILL ssh-agent`
printf 'killing ruby'
`killall -q -KILL ruby`
puts ' finish'

exit

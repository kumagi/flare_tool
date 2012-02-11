#!/usr/bin/ruby
require 'yaml'

def printf s
  print s
  STDOUT.flush
end

if ARGV[0] == nil
  puts "you should set prefix"
  exit
end
if ARGV[1] == nil
  puts "you should set accounts"
  exit
end

`./pass_yaml.rb`

printf 'killing all memcached...'
all_nodes = YAML.load_file "all_node_list.yaml"

all_nodes.each{ |node|
  `ssh #{node} sudo service memcached stop`
}
puts 'done'

printf 'launching memcached...'
servers = YAML.load_file "serverlist.yaml"
servers.each{ |server|
  `ssh #{server} sudo service memcached start`
}
puts "done for #{servers}"


myip = `hostname -i`.scan(/(10\.[0-9]+\.[0-9]+\.[0-9]+)/)[0][0]
prefix = ARGV[0]
accounts = ARGV[1].to_i

clientlist = YAML.load_file "all_node_list.yaml"

num = clientlist.size
para = 5
stride = (accounts / num / para)+1
threads = []
first = Time.now
rest = (0...num*para).to_a
clientlist.each_with_index{ |c, n|
  client_index = n * para
  para.times{|para_num|
    index = client_index + para_num
    threads << Thread.new{
      loop do
        reuslt = nil
        if myip == c
          puts "#{index}:python kvtx/account_set.py #{prefix} #{index*stride} #{stride} 1000"
          result = `python kvtx/account_set.py #{prefix} #{index*stride} #{stride} 1000`
        else
          puts "#{index}:ssh #{c} \"python kvtx/account_set.py #{prefix} #{index*stride} #{stride} 1000\""
          result = `ssh #{c} "python kvtx/account_set.py #{prefix} #{index*stride} #{stride} 1000" 2> /dev/null`
        end
        if !result.match /set .*~.* accounts to (.* qps)/
          puts "failed for #{index}:#{result}retry"
        end
        puts "#{index}:#{result.scan(/([0-9.]+ qps)/)[0]}"
        rest.reject!{ |n| n == index}
        break
      end
    }
  }
}


Thread.new{
  loop do
    sleep 5
    if rest.size < 50 and !rest.empty?
      p rest
    else
      puts "#{rest.size} client working..."
    end
  end
}
threads.each{ |t| t.join}
puts "#{accounts} accounts set. (#{accounts / (Time.now - first)} qps)"

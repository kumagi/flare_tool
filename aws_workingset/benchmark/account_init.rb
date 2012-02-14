#!/usr/bin/ruby
require 'yaml'
require './'+File.dirname(__FILE__) + '/process_wish'


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

process_wish("./pass_yaml.rb", "finish\n", nil)

printf 'killing all memcached...'
all_nodes = YAML.load_file "all_node_list.yaml"
threads = []
all_nodes.each{ |node|
  threads << Thread.new{
    process_wish "ssh #{node} sudo service memcached stop"
  }
}
threads.each{ |t| t.join}
puts 'done'

printf 'launching memcached...'
servers = YAML.load_file "serverlist.yaml"
servers.each{ |server|
  `ssh #{server} sudo service memcached start`
}

all_nodes = all_nodes - servers
puts "done for #{servers}"


myip = `hostname -i`.scan(/(10\.[0-9]+\.[0-9]+\.[0-9]+)/)[0][0]
prefix = ARGV[0]
accounts = ARGV[1].to_i

clientlist = YAML.load_file "all_node_list.yaml"
clientlist = clientlist - servers

num = clientlist.size
para = 100
stride = (accounts / num / para) + 1
threads = []
first = Time.now
rest = (0...num*para).to_a

good_client_list = []
def good_client_list.choice
  at( rand( size ) )
end

clientlist.each_with_index{ |c, n|
  client_index = n * para
  para.times{|para_num|
    index = client_index + para_num
    threads << Thread.new{
      use_client = c
      loop do
        reuslt = nil
        if myip == use_client
          puts "#{index}:python kvtx/account_set.py #{prefix} #{index*stride} #{stride} 1000"
          result, err = process_wish "python kvtx/account_set.py #{prefix} #{index*stride} #{stride} 1000", /.* qps/
        else
          puts "#{index}:ssh #{use_client} \"python kvtx/account_set.py #{prefix} #{index*stride} #{stride} 1000\""
          result,err = process_wish "ssh #{use_client} \"python kvtx/account_set.py #{prefix} #{index*stride} #{stride} 1000\" 2> /dev/null", /.* qps/
        end
        if result.match /set .*~.* accounts to (.* qps)/
          verify = "ssh #{use_client} \"python kvtx/verify.py #{prefix} #{index*stride} #{stride} 1\""
          if verify.match /1000.0 *is *it *ok\?/
            puts "#{index}:#{result.scan(/([0-9.]+ qps)/)[0]}"
            rest.reject!{ |n| n == index}
            good_client_list << use_client
            good_client_list.uniq!
            break
          else
            puts "verify NG#{verify}. retry"
          end
        end
        next_client = nil
        next_client = good_client_list.choice
        next_client = use_client if next_client.nil?
        puts "failed for #{index}:#{result} by #{use_client}retry retry in #{next_client}"
        use_client = next_client
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
      puts "#{rest.size} client working... #{stride * rest.size} works reft, at least."
    end
  end
}
threads.each{ |t| t.join}
puts "#{accounts} accounts set. (#{accounts / (Time.now - first)} qps)"

#!/usr/bin/ruby
require 'yaml'
require "optparse"
require 'ap'

def printf s
  print s
  STDOUT.flush
end

class Couchbase
  def initialize host, username, password
    @masterhost = host
    print `ssh #{@masterhost} "hostname -i"`
    print `ssh #{@masterhost} "hostname -i"`.scan(/(10\.[0-9]+\.[0-9]+\.[0-9]+)/)[0]
    @master_privateIP = `ssh #{@masterhost} "hostname -i"`.scan(/(10\.[0-9]+\.[0-9]+\.[0-9]+)/)[0][0]
    @username = username
    @password = password
    serverlist = `couchbase-cli server-list -c #{@masterhost} -u #{@username} -p #{@password}`
  end
  def get_list
    `couchbase-cli server-list -c #{@masterhost} -u #{@username} -p #{@password}`.scan(/ns_.@([^ ]*)/).map{|n|n[0]}
  end
  def launch_nodes n, from_list
    loop do
      from_list = from_list.reject{ |n| n == @master_privateIP}
      if from_list.size + 1 < n
        raise "requested #{n} nodes for #{from_list.size}"
      end
      from_list.each{ |node| server_remove node }
      rebalance
      (n - 1).times{|i| server_add from_list[i] }
      rebalance
      break if n == get_list.size
    end
  end
  def create_bucket name
    result = `couchbase-cli bucket-create -c #{@masterhost} -u #{@username} -p #{@password} --bucket=#{name} --bucket-type=couchbase --bucket-replica=1 --bucket-ramsize=6449`
    if result.match /SUCCESS/
      return true
    else
      return result
    end
  end
  def delete_bucket name
    result = `couchbase-cli bucket-delete -c #{@masterhost} -u #{@username} -p #{@password} --bucket=#{name}`
    if result.match /SUCCESS/
      return true
    else
      return result
    end
  end
  def server_add hosts
    puts "launching #{hosts}"
    hosts = [hosts] if hosts.class != Array
    result_map = {}
    hosts.each{ |host|
      result = `couchbase-cli server-add -c #{@masterhost} -u #{@username} -p #{@password} --server-add=#{host} --server-add-username=#{@username} --server-add-password=#{@password}`
      if result.match /ERROR/
        if result.match /Node is already part of cluster/
          result_map[host] = "already join"
        else
          result_map[host] = result
        end
      elsif result.match /SUCCESS/
        result_map[host] = true
      else
        ap result
        result_map[host] = false
      end
    }
    result_map
  end
  def rebalance
    result = `couchbase-cli rebalance -c #{@masterhost} -u #{@username} -p #{@password}`
  end
  def server_remove hosts
    hosts = [hosts] if hosts.class != Array
    result_map = {}
    hosts.each{ |host|
      result = `couchbase-cli failover -c #{@masterhost} --server-failover=#{host} -u #{@username} -p #{@password}`
      if result.match /ERROR/
        result_map[host] = result
      elsif
        result_map[host] = true
      end
    }
    result_map
  end
  def bucket_flush bucketname
    result = `couchbase-cli bucket-flush -c #{@masterhost} -u #{@username} -p #{@password} --bucket=#{bucketname}`
    if result.match /SUCCESS/
      return true
    else
      return result
    end
  end
end
master = "176.34.63.61"
bucketname = 'default'
`scp base:~/nodelist.yaml . < /dev/null &>/dev/null`
nodes = YAML.load_file 'nodelist.yaml'
puts "#{nodes.size} nodes found by heartbeat"

couch_master = Couchbase.new master, 'kumagi', 'katakata'
nodes.each{ |node|
  couch_master.server_add node
}
puts "first state"
#ap couch_master.get_list

masterip = `ssh #{master} "hostname -i"`.scan(/(10\.[0-9]+\.[0-9]+\.[0-9]+)/)[0][0]

couch_master.get_list.size.times{ |n|
  puts "couch launch #{n+1} nodes"
  couch_master.delete_bucket bucketname
  couch_master.launch_nodes n + 1, nodes
  couch_server_list = couch_master.get_list
  couch_master.create_bucket bucketname

  File.open('server_list.yaml',"w"){ |f|
    YAML.dump(couch_server_list, f)
  }
  File.open('all_node_list.yaml',"w"){ |f|
    all_node_list = (couch_master.get_list + nodes + [masterip]).uniq
    YAML.dump(all_node_list, f)
  }

  `scp server_list.yaml base:~/`
  `scp all_node_list.yaml base:~/`
  `ssh base "./pass.rb"`
  puts "benchmark for #{n+1} server"
  puts `./bench.rb`
}

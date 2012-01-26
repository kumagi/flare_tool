#!/usr/bin/ruby

servers = ARGV[0].to_i
clients = ARGV[1].to_i

def get_node_quantity
  `ssh manager "cat nodelist.txt| wc -l"`.to_i
end

if servers == 0 || clients == 0
  puts "server and client number must be set"
  exit
end
`ssh manager "./split_server_client.rb #{servers} #{1}"`
puts "split"

loop do
  begin
    system("ssh manager \"./manage_flare/launch_flares.rb\" &")
    sleep 1
    result = `ruby setrole.rb #{servers}`
    boot_nodes = result.scan(/\n([^ ]*) node/)[0][0].to_i
    exist_nodes = get_node_quantity.to_i
    break if boot_nodes == exist_nodes
    puts "only #{boot_nodes}/#{exist_nodes} nodes. retry"
    sleep 1
  rescue RuntimeError
    puts "no node booted.. retry"
    sleep 1
  rescue NoMethodError
    sleep 1
  end
end

puts "all nodes booted, ready"

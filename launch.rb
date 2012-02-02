#!/usr/bin/ruby

servers = ARGV[0].to_i
clients = ARGV[1].to_i

def get_node_quantity
  `ssh manager "cat nodelist.txt| wc -l"`.to_i
end
node_quantity = get_node_quantity
puts "node quantity #{node_quantity}"

if node_quantity < servers + clients
  puts "only #{node_quantity} exists for #{servers + clients} request"
  exit
end

if servers == 0
  puts "server and client number must be set"
  exit
end
if clients == 0
  clients = node_quantity - servers
  puts "rest #{clients} node is client"
end
result = `ssh manager "./split_server_client.rb #{servers} #{clients}"`

no_in_out = "< /dev/null &> /dev/null "

loop do
  managerpid = nil
  result = nil
  begin
    system("ssh manager \"./quiet_launch_flares.sh\"")
    puts "flare boot done. try configuring..."
    sleep 1
    result = `ruby set_master.rb #{servers}`

    unless result.match(/([0-9]*) node flared,/)
      puts "node exists [#{result.sub /\n/, "\\n"}] retry."
      next
    end
    boot_nodes = result.scan(/([0-9]*) node flared/)[0][0].to_i

    exist_nodes = get_node_quantity.to_i
    break if boot_nodes == exist_nodes
    puts "only #{boot_nodes}/#{exist_nodes} nodes. retry"
    puts "result [#{result.sub /\n/, "\\n"}]"
    `ssh manager "./killall.rb"`
  end
end
puts "all nodes booted, ready #{clients}client #{servers}server"



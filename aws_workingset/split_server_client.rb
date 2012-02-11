#!/usr/bin/ruby
require 'yaml'

server = ARGV[0].to_i
client = ARGV[1].to_i

if server == 0
  puts "invalid server number"
  exit
end
puts "ordered #{server}servers #{client} clients"

nodes = YAML.load_file("all_node_list.yaml")
`rm serverlist.yaml -rf`
File.open("serverlist.yaml","w"){|serverlist|
  YAML.dump(nodes.sort[0, server], serverlist)
}
if client != 0
  if nodes.size < server + client
    puts 'invalid number: #{server}server and #{client}client for #{nodes.size}nodes'
    exit
  end
  `rm clientlist.yaml -rf`
  File.open("clientlist.yaml","w"){|clientlist|
    YAML.dump(nodes.sort[-client, nodes.size], clientlist)
  }
else
  `rm clientlist.yaml -rf`
  File.open("clientlist.yaml","w"){|clientlist|
    YAML.dump(nodes.sort, clientlist)
  }
end
puts 'done'

#!/usr/bin/ruby
require 'yaml'

server = ARGV[0].to_i
client = ARGV[1].to_i

if server == 0 || client == 0
  puts "invalid server client number"
  exit
end

File.open("nodelist.txt", "r"){|file|
  fileline = file.count
  if fileline < server+client
    puts "there is only #{fileline} for #{client} + #{server}"
    exit
  end
  file.seek 0
  `rm serverlist.txt -rf`
  File.open("serverlist.txt","w"){|serverlist|
    server.times{
      serverlist.write file.gets
    }
  }

  `rm clientlist.txt -rf`
  (fileline - (server + client)).times{ file.gets }
  File.open("clientlist.txt","w"){|clientlist|
    client.times{
      clientlist.puts file.gets
    }
  }
}

nodes = YAML.load_file("nodelist.yaml")
`rm serverlist.yaml -rf`
File.open("serverlist.yaml","w"){|serverlist|
  YAML.dump(nodes[0, server], serverlist)
}

`rm clientlist.yaml -rf`
File.open("clientlist.yaml","w"){|clientlist|
  YAML.dump(nodes.slice(-client, nodes.size), clientlist)
}

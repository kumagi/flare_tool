#!/usr/bin/ruby

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


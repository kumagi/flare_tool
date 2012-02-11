#!/usr/bin/ruby
require 'socket'
require 'yaml'
require 'optparse'

conf = {}
opts = OptionParser.new
opts.on("-f ConfigFile"){|v| conf[:file] = v }
opts.on("-a Host"){|v| conf[:host] = v }
opts.on("-p Port"){|v| conf[:port] = v.to_i }
opts.parse!(ARGV)

conf_file = {}
if conf[:file]
  conf_file = YAML.load_file conf[:file]
end
host = conf[:host] || conf_file["host"] || '0.0.0.0'
port = conf[:port] || conf_file["port"] || 12334
except_list = ["176.34.63.61"]

loopback_list = `hostname -i`.chomp.split ' '
loopback_list << "127.0.0.1"
loopback_list.uniq!

from = []
Thread.start{
  begin
    loop do
      sleep 10
      nodelist = (from.uniq - loopback_list  - except_list).sort
      File.open("nodelist.txt","w"){ |f|
        f.write(nodelist.join("\n") + "\n")
      }
      File.open("nodelist.yaml","w"){ |f|
        YAML.dump(nodelist, f)
      }
      from = []
      puts "file wrote"
    end
  rescue => e
    p e
    retry
  end
}
begin
  server = UDPSocket.open()
  server.bind(host, port)
  loop do
    peer = server.recvfrom(100)
    from = from.push(peer[1][3]).uniq
    puts "Connected from #{peer[1][3]}:#{peer[1][1]}"
  end
rescue Interrupt
  puts "# interrupt signal received #"
  exit
rescue => e
  p e
end

#!/usr/bin/ruby
require 'socket'
require 'yaml'
require "optparse"

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
host = conf[:host] || conf_file["host"] || '127.0.0.1'
port = conf[:port] || conf_file["port"] || 12334

while true
  begin
    s = UDPSocket.open()
    sockaddr = Socket.pack_sockaddr_in(port, host)
    loop do
      s.send("h", 0, sockaddr)
      puts "beat send for #{host}:#{port}"
      sleep 9
    end
  rescue Interrupt
    puts "# interrupt signal received #"
    exit
  rescue =>e
    sleep 5
    retry
  end
end


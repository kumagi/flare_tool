#!/usr/bin/ruby
require 'socket'

port = 12334
server = TCPServer.open(port)

from = []

Thread.start{
  loop do
    begin
      sleep 10
      from.uniq!
      from.reject!{|ip| ip == "176.34.30.147"}
      from.reject!{|ip| ip == "127.0.0.1"}
      string = from.join("\n")
      File.open("nodelist.txt","w"){ |f|
        f.write(string + "\n")
      }
      from = []
      puts "file wrote"
    rescue
    end
  end
}

loop do
  Thread.start(server.accept) do |io|
    begin
      peer = io.peeraddr
      from << peer[3]
      from.uniq!
      io.recv 1
      puts "Connected from #{peer[3]} (#{peer[1]})"
      io.close
    rescue Interrupt
      puts "interrupted."
    rescue
    end
  end
end

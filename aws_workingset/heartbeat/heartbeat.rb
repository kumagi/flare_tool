#!/usr/bin/ruby
require 'socket'

host = '10.157.118.170'
port = 12334

while true
  begin
    s = TCPSocket.new(host, port)
    s.write "t"
    sleep 5
  rescue
  end
end


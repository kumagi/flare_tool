require 'socket'
require 'ap'

host = '176.34.30.147'
port = 12120

master_nodes = ARGV[0].to_i

class FlareManager
  def initialize host, port
    begin
      @s = TCPSocket.new(host,port)
    rescue Errno::ECONNREFUSED => e
      puts "connectiong #{host}:#{port} failed retry in 1 second"
      sleep 1
      retry
    end
  end
  def get_nodelist
    @s.write "stats nodes\r\n"
    nodes = []
    @s.each{ |n|
      n = n.chomp
      if n.match /master$/
        node = n.scan /^STAT ([^:]*)/
        nodes << node[0][0] unless node[0].nil? unless node.nil?
      end
      break if n =~ /END/
    }
    nodes.uniq
  end
end

s = FlareManager.new(host,port)
puts "#{s.get_nodelist.size} nodes"

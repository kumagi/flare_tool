require 'socket'

host = '176.34.30.147'
port = 12120

master_nodes = ARGV[0].to_i

class FlareManager
  def initialize host, port
    retry_counter = 0
    begin
      @s = TCPSocket.new(host,port)
    rescue Errno::ECONNREFUSED => e
      puts "connectiong #{host}:#{port} failed retry in 1 second"
      sleep 1
      retry_counter = retry_counter + 1
      if 10 < retry_counter
        puts "Couldnt connect master of flare, Check it"
        exit
      end
      retry
    end
    @server_list = get_servers
  end

  private
  def get_servers
    @s.write "stats nodes\r\n"
    servers = []
    @s.each{ |n|
      server = n.scan /^STAT ([^:]*):/
      servers << server[0][0] unless server[0].nil? unless server.nil?
      break if n =~ /END/
    }
    servers.uniq
  end

  def recv_until regexps
    result = ""
    while 1
      result += @s.recv 4096
      # $stderr.write "#{result}"
      regexps.each{ |r|
        return {:matched => r.to_s, :data => result} if result =~ r
      }
    end
  end

  public
  attr_reader :server_list

  def all_down
    @server_list.size.times{ |n|
      set_state "down", n
      set_role "proxy", n
    }
  end
  def set_role role, n
    if @server_list.size <= n
      puts "n(=#{n}) is out of range of server_list #{@server_list.size}"
      exit
    end

    loop do
      query = "node role #{@server_list[n]} 12121 #{role} 1 #{n}\r\n"
      @s.write query
      result = recv_until [/OK/, /SERVER_ERROR/, /ERROR/]
      break if result[:matched].to_s =~ /OK/
      puts "unexpeced result for \n#{query}#{result[:data]}"
      sleep 1
    end
  end
  def set_state state, n
    raise "n(=#{n}) is out of range of server_list #{@server_list.size}" if
      @server_list.size <= n
    loop do
      query = "node state #{@server_list[n]} 12121 #{state}\r\n"
      @s.write query
      result = recv_until [/OK/, /ERROR/]
      break if result[:matched] =~ /OK/
      puts "unexpeced result for \n#{query}\n#{result[:data]}"
      sleep 1
    end
  end
end

s = FlareManager.new(host,port)
# s.all_down

master_nodes.times{ |n|
  s.set_role "master", n
  s.set_state "active", n
}

puts "#{s.server_list.size} node flared, setting done."

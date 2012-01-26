#!/usr/bin/ruby

def parallel_do command
  puts "command: #{command}"
  File.open("nodelist.txt","r"){|file|
    threads = []
    while node = file.gets
      threads << Thread.new { `ssh #{node.chomp} "#{command}"` }
    end
    threads.each{|t| t.join}
  }
end
myip = `./myip.sh`.chomp
puts "myip is #{myip}"

raise "MYIP must be set." unless myip =~ /^(\d|[01]?\d\d|2[0-4]\d|25[0-5])\.(\d|[01]?\d\d|2[0-4]\d|25[0-5])\.(\d|[01]?\d\d|2[0-4]\d|25[0-5])\.(\d|[01]?\d\d|2[0-4]\d|25[0-5])$/

# setting index server
parallel_do "sudo perl -i -pe's/index-server-name = .*/index-server-name = #{myip}/' /etc/flare/flared.conf"
parallel_do "./conf/configure"


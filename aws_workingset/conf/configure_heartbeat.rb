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

substitute_command = <<EOS
sudo perl -i -pe\\"s|^host.*|host = \'#{myip}\'|\\" /usr/local/bin/heartbeat.rb
EOS

# puts substitute_command.chomp
[substitute_command,
 "sudo service heartbeat stop",
 "sudo service heartbeat start"].each{|c| parallel_do c}



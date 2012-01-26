#!/usr/bin/ruby
def parallel_do command
  File.open("nodelist.txt","r"){|file|
    threads = []
    while node = file.gets
      node.chomp!
      threads << Thread.new {
        puts "node :#{node} => #{command}"
        system("ssh #{node} \"#{command}\"")
      }
    end
    threads.each{|t|
      t.join
    }
  }
end

# stop all
`sudo service flarei stop`
reset = ["sudo service flarei stop",
         "sudo service flared stop",
         "./manage_flare/init_flaredata.sh"]
reset.each{|c| parallel_do c}
`./manage_flare/init_flaredata.sh`
`sudo ./manage_flare/init_flaredata.sh`

# start all
system("sudo service flarei start")
puts "service start"
sleep(1)

init = ["sudo service flared start"]
init.each{|c| parallel_do c}

puts 'done'

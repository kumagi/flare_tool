#!/usr/bin/ruby
def parallel_do command
  threads = []
  IO.foreach("nodelist.txt"){|node|
    node.chomp!
    next if node == ""
    threads << Thread.new {

      puts "node :[#{node}] => #{command}"
      `ssh #{node} "#{command}"`
    }
  }
  threads.each{|t| t.join }
end

# stop all
`sudo service flarei stop`
reset = ["sudo service flarei stop",
         "sudo service flared stop",
         "./manage_flare/init_flaredata.sh"]
reset.each{|c| parallel_do c}
`./manage_flare/init_flaredata.sh`
`rm ~/flaredata/flare.xml`

`sudo ./manage_flare/init_flaredata.sh`

# start all
system("sudo service flarei start")
puts "manager start"
sleep 1

init = ["sudo service flared start"]
init.each{|c| parallel_do c}

puts 'done'

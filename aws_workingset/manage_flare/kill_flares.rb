#!/usr/bin/ruby
def parallel_do command
  File.open("nodelist.txt","r"){|file|
    threads = []
    while node = file.gets
      node.chomp!
      threads << Thread.new {
        `ssh #{node} "#{command}"`
      }
    end
    threads.each{|t|
      t.join
    }
  }
end

# stop all
`sudo service flarei stop`
reset = ["sudo service flarei stop", "sudo service flared stop", "./init_flaredata.sh"]
reset.each{|c| parallel_do c}
`sudo ./init_flaredata.sh`
puts 'done'

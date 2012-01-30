#!/usr/bin/ruby
filename="hoge.tar.gz"
`tar cvzf #{filename} *`
threads = []
IO.foreach("nodelist.txt"){|node|
  node = node.chomp
  puts "sending #{node} begin"
  threads << Thread.new{
    `ssh #{node} "rm * -rf"`
    `scp #{filename} #{node}:~/`
    `ssh #{node} "tar xvf #{filename}; rm #{filename}"`
    # $stderr.write "ssh #{node} '#{command}'\n"
    puts "sending #{node} done"
  }
}
threads.each{ |t| t.join}
`rm #{filename}`
puts 'finish'

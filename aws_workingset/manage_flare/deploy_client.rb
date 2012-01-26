#!/usr/bin/ruby

def parallel_send filename, dir
  puts "file: #{filename}"
  File.open("clientlist.txt","r"){|file|
    threads = []
    while node = file.gets
      threads << Thread.new { `scp #{filename} #{node.chomp}:~/#{dir}/`}
    end
    threads.each{|t| t.join}
  }
end
if ARGV.size != 2
  puts "You should set `filename` and `target dir` to deploy client"
  exit!
end
puts ARGV[0]
puts ARGV[1]
#parallel_send ARGV[0], ARGV[1].sub(/^\//,"").sub(/\/$/,"")

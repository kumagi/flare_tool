#!/usr/bin/ruby


if ARGV[0] == "-h"
  puts "run_client.rb [all works] [chunk] [prefix] [number of accounts] [paralells in work] [parallels in node]"
  exit
end
all_works = (ARGV[0] || 100000).to_i
chunk = (ARGV[1] || 1000).to_i
prefix = ARGV[2] || "hoge"
accounts = (ARGV[3] || 1000).to_i
parallel = (ARGV[4] || 10).to_i
node_parallel = (ARGV[5] || 10).to_i


puts "#{all_works} works in #{parallel * node_parallel} parallels by #{chunk} each nodes"
puts "accounts are #{prefix}[0~#{accounts}]"

if all_works < parallel * chunk * node_parallel
  print "too many chunk * node_parallel * parallel"
  exit
end

done_works = 0
start = Time.now
finish = 0
File.open("clientlist.txt","r"){|file|
  if file.lines
  end
  threads = []
  while node = file.gets
    threads << Thread.new {
      node_parallel.times{ |n|
        Thread.new{
          loop do
            #`ssh #{node} "python move_money.py #{prefix} #{chunk} #{accounts} #{parallel}"`
            done_works = done_works + chunk
            break if all_works <= done_works
          end
        }
      }
    }
  end
  loop do
    break if all_works <= done_works
    sleep(0.01)
  end
  finish = Time.now
  threads.each{|t| t.kill}
}
puts "#{all_works / (finish - start)} qps"

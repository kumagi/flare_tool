#!/usr/bin/ruby
require 'yaml'
if ARGV[0] == nil
  puts "you should set prefix"
  exit
end
if ARGV[1] == nil
  puts "you should set accounts"
  exit
end

myip = `hostname -i`.scan(/(10\.[0-9]+\.[0-9]+\.[0-9]+)/)[0][0]
prefix = ARGV[0]
accounts = ARGV[1].to_i

result = nil
clients = YAML.load_file("clientlist.yaml")
result = nil

num = clients.size
para = 8
stride = accounts / num / para
rest = (0...num*para).to_a
clients.each_with_index{ |c, n|
  client_stride = n * para
  para.times{|in_client_index|
    index = client_stride + in_client_index
    Thread.new{
      if c == myip
        puts "#{index}:python kvtx/verify.py #{prefix} #{index*stride} #{stride} 0"
        `python kvtx/verify.py #{prefix} #{index*stride} #{stride} 0`
      else
        puts "#{index}:ssh #{c} \"python kvtx/verify.py #{prefix} #{index*stride} #{stride} 0\""
        `ssh #{c} "python kvtx/verify.py #{prefix} #{index*stride} #{stride} 0" 2> /dev/null`
      end
      rest.reject!{ |n| n == index}
    }
  }
}

loop do
  sleep 5
  p rest if rest.size < 50 and !rest.empty?
  puts "#{rest.size} rest." if rest.size >= 50 and !rest.empty?
  break if rest.empty?
end
puts 'all helper end, start verify'

`python kvtx/verify.py #{prefix} 0 #{accounts} 1`
result = `python kvtx/verify.py #{prefix} 0 #{accounts} 1`

puts result
STDOUT.flush
sleep 1
`./killall.rb`

#!/usr/bin/ruby
require 'yaml'

prefix = ARGV[0]
accounts = ARGV[1]
works = ARGV[2].to_i
chunk = ARGV[3].to_i
parallels = ARGV[4].to_i
py_parallels = (ARGV[5] || 3).to_i

def printf s
  print s
  STDOUT.flush
end

if parallels == 0
  puts "set more than 1 parallels"
  exit
end

myip = `hostname -i`.scan(/(10\.[0-9]+\.[0-9]+\.[0-9]+)/)[0][0]
threads = []
done_work = 0
start = Time.now

clients = YAML.load_file "clientlist.yaml"
threads = []
clients.each{ |target|
  parallels.times{|n|
    #result = `ssh #{target} "killall -q python"`
    threads << Thread.new{
      begin
        loop do
          result = nil
          if target == myip
            #puts "python kvtx/move_money.py #{prefix} #{accounts} #{chunk} #{py_parallels}"
            result = `python kvtx/move_money.py #{prefix} #{accounts} #{chunk} #{py_parallels} < /dev/null`
          else
            #puts "ssh #{target} \"python kvtx/move_money.py #{prefix} #{accounts} #{chunk} #{py_parallels}\""
            result = `ssh #{target} "python kvtx/move_money.py #{prefix} #{accounts} #{chunk} #{py_parallels}" < /dev/null`# 2> /dev/null`
          end
          #puts "#{n}: ssh #{target} \"python kvtx/blindset.py #{chunk} 10\""
          #result = `ssh #{target} "python kvtx/blindset.py #{chunk} 4"`
          # result = `ssh #{target} "echo hello"`
          # $stderr.puts "#{n}: ssh end [#{result}]"
          if result.match /@work done@/
            done_work = done_work + chunk
            printf "."
          elsif
            if result == ""
              printf "E"
            elsif
              puts "error:[#{result}]"
            end
          end
          break if works <= done_work
        end
      rescue => e
        p e
      ensure
        `ssh #{target} pkill python &> /dev/null;ssh #{target} pkill -KILL python &> /dev/null`
      end
      $stderr.puts "#{n}: all #{done_work}s done"
    }
  }
}

loop do
  break if works <= done_work
  sleep 0.01
end
finish = Time.now
threads.each{ |t| t.kill }
threads = []
clients.each{ |target|
  threads << Thread.new(target){|t|
    `ssh #{t} pkill python &> /dev/null;ssh #{t} pkill -KILL python &> /dev/null`
  }
}
threads.each{ |t| t.join}
puts "#{done_work.to_f / (finish - start)} qps"
STDOUT.flush
threads.each{ |t| t.join}

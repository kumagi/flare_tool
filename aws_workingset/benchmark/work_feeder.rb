#!/usr/bin/ruby
require 'yaml'

prefix = ARGV[0]
accounts = ARGV[1]
works = ARGV[2].to_i
chunk = ARGV[3].to_i
parallels = ARGV[4].to_i

if parallels == 0
  puts "set more than 1 parallels"
  exit
end

myip = `hostname -i`

threads = []
done_work = 0
start = Time.now

clients = YAML.load_file "clientlist.yaml"
clients.each{ |target|
  parallels.times{|n|
    result = `ssh #{target} "killall -q python"`
    Thread.new{
      begin
        loop do
          #puts "ssh #{target} \"python flare/move_money.py #{prefix} #{chunk} #{accounts} 4\""
          result = `ssh #{target} "python flare/move_money.py #{prefix} #{chunk} #{accounts} 4"`
          # $stderr.puts "#{n}: ssh #{target} \"python flare/blindset.py #{chunk} 10\""
          # result = `ssh #{target} "python flare/blindset.py #{chunk} 1"`
          # result = `ssh #{target} "echo hello"`
          # $stderr.puts "#{n}: ssh end [#{result}]"
          if result.match /@work done@/
            done_work = done_work + chunk
            # $stderr.print "#{done_work} "
            $stderr.print "."
          elsif
            $stderr.puts "error:[#{result}]"
          end
          break if works <= done_work
        end
      rescue => e
        p e
      end
      # $stderr.puts "#{n}: all #{done_work}s done"
    }
  }
}

loop do
  break if works <= done_work
  sleep 0.01
end
finish = Time.now
puts "#{done_work.to_f / (finish - start)} qps"
STDOUT.flush
threads.each{ |t| t.join}

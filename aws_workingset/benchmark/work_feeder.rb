#!/usr/bin/ruby
require 'yaml'
require File.dirname(__FILE__) + 'process_wish'

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
	Thread.new{
		parallels.times{|n|
			#result = `ssh #{target} "killall -q python"`
			threads << Thread.new{
				begin
					loop do
						result = nil
            err = nil
						if target == myip
							#puts "python kvtx/move_money.py #{prefix} #{accounts} #{chunk} #{py_parallels}"
							result, err = process_wish "python kvtx/move_money.py #{prefix} #{accounts} #{chunk} #{py_parallels} < /dev/null 2> /dev/nul", /@work_done@/
						else
							#puts "ssh #{target} \"python kvtx/move_money.py #{prefix} #{accounts} #{chunk} #{py_parallels}\""
							result, err = process_wish "ssh #{target} \"python kvtx/move_money.py #{prefix} #{accounts} #{chunk} #{py_parallels} < /dev/null 2>/dev/null\" 2>/dev/null",/@work done@/
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
								printf "E{#{target}}"
							elsif
								puts "error:[#{result}]"
							end
						end
						break if works <= done_work
					end
				rescue => e
					p e
        rescue Interrupt
          `ssh #{target} pkill -KILL python </dev/null &> /dev/null`
				ensure
					`ssh #{target} pkill -KILL python </dev/null &> /dev/null`
				end
			}
		}
	}
}
puts "start #{clients.size}client * #{parallels}process * #{py_parallels}thread for #{accounts}accounts,(factor:#{accounts.to_f/(clients.size * parallels * py_parallels)}) wait for end@"
STDOUT.flush
loop do
	break if works <= done_work
	sleep 0.01
end
puts "work done. #{done_work}"
finish = Time.now
puts "#{done_work} works in #{finish-start}sec.\n#{done_work.to_f / (finish - start)} qps"

exit
Thread.new{
	threads.each{ |t|
    Thread.new{
      t.kill
    }
  }
}
threads = []
clients.each{ |target|
	threads << Thread.new(target){|t|
		`ssh #{t} "pkill -KILL python < /dev/null &> /dev/null"`
	}
}
STDOUT.flush
exit


threads.each{ |t| t.join}

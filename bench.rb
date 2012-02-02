#!/usr/bin/ruby
def printf s
  print s
  STDOUT.flush
end
`pkill -KILL launch.rb`
printf "sending newest workingset..."
`./send_flareset.sh &> /dev/null`
printf "done"
`./send_benchmark.sh &> /dev/null`

prefix = "hoge"

accounts = (ARGV[0] || 1000).to_i
works = (ARGV[1] || 1000000).to_i
chunk = (ARGV[2] || 1000).to_i
servers = (ARGV[3] || 1).to_i

default_money = 1000

printf "initializing... "
`./init.sh`
puts "done."

printf "launching flares..."

flare_boot = `./launch.rb #{servers}`
STDOUT.flush
raise "invalid server number" unless flare_boot.match /flare boot done/

puts "done."

#puts "ssh manager \"ruby benchmark/account_init.rb #{prefix} #{accounts} #{default_money}\""
#`ssh manager "./killall.rb"`
#`ssh manager "killall ruby -q"`
#`ssh manager "ruby benchmark/account_init.rb #{prefix} #{accounts} #{default_money}"`

 "initialized accounts #{prefix}0~#{accounts} with #{default_money} ok"
=begin
prefix = ARGV[0]
accounts = ARGV[1]
works = ARGV[2].to_i
chunk = ARGV[3].to_i
parallels = ARGV[4].to_i
=end
puts "launch feeder #{accounts} #{chunk}chunk #{works}works 10parallel "
result = `ssh manager "ruby ~/benchmark/work_feeder.rb #{prefix} #{accounts} #{works} #{chunk} 10"`
puts result

exit
verify = `ssh manager "ruby benchmark/verify.rb #{prefix} #{accounts}"`
unless verify.match /^[0-9]*$/
  raise "invalid result for verify.rb [#{verify.sub /\n/, "\\n"}]"
end

scaned = verify.scan(/\n([0-9]*)\n/)[0][0]
result = scaned.to_i
if result == default_money.to_i
  puts "verify ok."
elsif
  puts "bad verify #{result}"
end

=begin work_feeder.rb

prefix = ARGV[0]
accounts = ARGV[1]
works = ARGV[2].to_i
chunk = ARGV[3].to_i
parallels = ARGV[4].to_i
=end

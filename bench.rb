#!/usr/bin/ruby

prefix = "hoge"
accounts = (ARGV[0] || 1000).to_i
works = (ARGV[1] || 1000000).to_i
chunk = (ARGV[2] || 1000).to_i
servers = (ARGV[3] || 1).to_i

default_money = 1000

print "initializing... "
STDOUT.flush
`./init.sh`
puts "done."

print "launching flares..."
STDOUT.flush

flare_boot = `./launch.rb #{servers}`

raise "invalid server number" unless flare_boot.match /flare boot done/

puts "done."

puts "ssh manager \"ruby benchmark/account_init.rb #{prefix} #{accounts} #{default_money}\""
`ssh manager "killall ruby -q"`
`ssh manager "ruby benchmark/account_init.rb #{prefix} #{accounts} #{default_money}"`

puts "initialized accounts #{prefix}0~#{accounts} with #{default_money} ok"
10.times{ |n|
=begin
prefix = ARGV[0]
accounts = ARGV[1]
works = ARGV[2].to_i
chunk = ARGV[3].to_i
parallels = ARGV[4].to_i
=end
  puts "launch feeder #{accounts} #{chunk}chunk #{works}works #{n+1}parallel "
  result = `ssh manager "ruby ~/benchmark/work_feeder.rb #{prefix} #{accounts} #{works} #{chunk} #{n+1}"`
  puts result
}

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

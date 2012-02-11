#!/usr/bin/ruby
def printf s
  print s
  STDOUT.flush
end
`pkill -KILL launch.rb`
printf "sending newest workingset..."
`./send_flareset.sh &> /dev/null`
puts "done"
`./send_benchmark.sh &> /dev/null`

prefix = "hoge"
accounts = (ARGV[0] || 1000).to_i
works = (ARGV[1] || 1000000).to_i
chunk = (ARGV[2] || 1000).to_i
max_servers = ARGV[3].to_i
clients = ARGV[4].to_i
default_money = 1000

puts "\n" + "#"*5 + "start benchmarking!" + "#"*5


max_servers.times{ |servers|
  next if servers == 0
  printf "killall ruby on remote cluster... "
  `./init.sh`
  `./connection_keepalive.rb &`
  puts "done."

  printf "launching flares...#{clients}clients #{servers}server... "
  flare_boot = `./launch.rb #{servers} #{clients}`
  puts "done."
  if flare_boot.match /only [0-9]* exists/
    puts "cannnot lauch #{servers + clients} nodes"
    exit
  end
  launched_clients =  flare_boot.scan(/([0-9]*)client/)[0][0].to_i
  launched_servers = flare_boot.scan(/([0-9])*server/)[0][0].to_i
  puts "#{launched_clients}clients & #{launched_servers}servers ready."

  puts "ssh base \"ruby benchmark/account_init.rb #{prefix} #{accounts} #{default_money}\""
  printf "initializing first data #{prefix}0~#{accounts} with #{default_money} ... "
  `ssh base "ruby benchmark/account_init.rb #{prefix} #{accounts} #{default_money}"`
  puts "done"
=begin
./work_feeder.rb
prefix = ARGV[0]
accounts = ARGV[1]
works = ARGV[2].to_i
chunk = ARGV[3].to_i
parallels = ARGV[4].to_i
=end
  puts "launch feeder #{accounts} #{chunk}chunk #{works}works 4parallel "
  result = `ssh base "ruby ~/benchmark/work_feeder.rb #{prefix} #{accounts} #{works} #{chunk} 4"`
  qps = result.scan(/([0-9]*\.[0-9]*) qps*/)[0][0].to_f unless result[0].nil? unless result.nil?
  if qps == 0 or qps.nil?
    retry
    puts "failed to benchmarking for #{clients}client #{servers}server bench"
    puts "-"*10 + "result" + "-"*10 + result + "-"*8 + "result end" + "-"*8
  elsif
    puts "#{clients}client -> #{servers}server: #{qps} qps"
  end

  verify = `ssh base "ruby benchmark/verify.rb #{prefix} #{accounts}"`
  begin
    result = verify.scan(/\n([0-9]*)\n/)[0][0].to_i
    if result == default_money.to_i
      puts "verify ok."
    elsif
      puts "bad verify #{result}"
    end
    unless verify.match /^[0-9]*$/
      raise "oi"
    end
  rescue
    puts "invalid result for verify.rb [#{verify.sub /\n/, "\\n"}]"
  end
}


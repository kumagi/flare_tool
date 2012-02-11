#!/usr/bin/ruby
require 'yaml'
require 'ap'
def printf s
  print s
  STDOUT.flush
end


prefix = "hoge"
offset = (ARGV[0] || 0).to_i
accounts = (ARGV[1] || 30000).to_i
works = (ARGV[2] || 10000).to_i
chunk = (ARGV[3] || 10).to_i
parallels = (ARGV[4] || 10).to_i
py_parallels = (ARGV[5] || 10).to_i
clients = (ARGV[6] || 10).to_i

=begin
prefix = "hoge"
offset = (ARGV[0] || 0).to_i
accounts = (ARGV[1] || 300000).to_i
works = (ARGV[2] || 5000).to_i
chunk = (ARGV[3] || 200).to_i
parallels = (ARGV[4] || 50).to_i
clients = (ARGV[5] || 5).to_i
=end

default_money = 1000

all_node_list = 'all_node_list.yaml'
`ssh base "./create_nodelist.rb"`
`scp base:~/#{all_node_list} .`

all_nodes = YAML.load_file all_node_list
puts "#{all_nodes.size} nodes ok"
puts "#{clients} client / #{all_nodes.size} nodes"

File.open("benchmark_result.txt", "a"){ |f|
  f.write "\n" + "-" * 10 + "\n"
  f.write "#{accounts}accounts #{works}works #{chunk}chunks for #{all_nodes.size}servers\n"
  f.write "#{parallels}python #{py_parallels}pythonthoread #{clients}clients = #{parallels * py_parallels * clients} parallels"
  f.write "-" * 10 + "\n"
}

silent = " < /dev/null 2> /dev/null "

(all_nodes.size - clients).times { |n|
  n = n+1
  next if n < offset
  puts "launch #{n} server and #{clients} client"
  split_result = `ssh base "./split_server_client.rb #{n} #{clients}"`
  break unless split_result.match /done/
  `ssh base ./killall.rb`
  printf 'passing server/client list...'
  `ssh base "./pass_yaml.rb"`
  puts 'done'
  printf 'getting server/client list...'
  `scp base:~/serverlist.yaml .`
  `scp base:~/clientlist.yaml .`
  puts 'done'

  puts "memcached configuring... #{n} nodes server"
  STDOUT.flush
  server_list = YAML.load_file 'serverlist.yaml'
  client_list = YAML.load_file 'clientlist.yaml'
  print 'server => '
  ap server_list
  print 'client => '
  ap client_list

  begin
    benchmark_result = ""

    File.open("benchmark_result.txt", "a"){ |f|
      f.write "#{server_list.size}servers #{client_list.size}clients  "
    }

    use_accounts = accounts * server_list.size

    # initialize
    init_begin = Time.now
    puts "ssh base \"ruby benchmark/account_init.rb #{prefix} #{use_accounts} #{default_money}\""
    STDOUT.flush
    `ssh base "ruby benchmark/account_init.rb #{prefix} #{use_accounts} #{default_money} #{silent}"`
    elapsed = Time.now - init_begin
    qps = accounts.to_f / elapsed
    puts "initialized accounts #{prefix}0~#{use_accounts} with #{default_money} in #{elapsed} (#{qps} qps)"
    File.open("benchmark_result.txt", "a"){ |f|
      f.write "#{qps} qps in raw data | "
    }
    STDOUT.flush

    # benchmarking
    puts "ssh base \"ruby ~/benchmark/work_feeder.rb #{prefix} #{use_accounts} #{server_list.size * chunk * 10} #{chunk} #{parallels} #{py_parallels} < /dev/null 2> /dev/null \" < /dev/null"
    benchmark_result = `ssh base "ruby ~/benchmark/work_feeder.rb #{prefix} #{use_accounts} #{server_list.size * chunk * 10} #{chunk} #{parallels} #{py_parallels}< /dev/null  "`
    puts benchmark_result
    qps = benchmark_result.scan(/([0-9][0-9.]*) qps/).flatten
    File.open("benchmark_result.txt", "a"){ |f|
      f.write "#{qps.join(' ')} qps in transaction\n"
    }

    puts "benchmark done. killing trash."
    # omit verify
    'ssh base "./killall.rb < /dev/null &> /dev/null"'
    next
    # verifying
    puts "ssh base \"ruby benchmark/verify.rb #{prefix} #{use_accounts}\""
    verify = `ssh base "ruby benchmark/verify.rb #{prefix} #{use_accounts} #{silent}" < /dev/null`
    begin
      unless verify.match /^[0-9.]*$/
        raise "invalid result for verify.rb [#{verify.sub /\n/, "\\n"}]"
      end
      scaned = verify.scan(/\n([0-9.]*)\n/)[0][0]
      result = scaned.to_i
      if result == default_money.to_f
        puts "verify ok."
      elsif
        puts "bad verify #{result}"
    end
    rescue => e
      p e
      puts "something wrong[#{verify}]"
    end
  rescue Interrupt
    'ssh base "./killall.rb"'
  end
  puts ""
}
'ssh base "./killall.rb"'

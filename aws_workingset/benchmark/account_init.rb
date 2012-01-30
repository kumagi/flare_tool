#!/usr/bin/ruby

if ARGV[0] == nil
  puts "you should set prefix"
  exit
end
if ARGV[1] == nil
  puts "you should set accounts"
  exit
end

prefix = ARGV[0]
accounts = ARGV[1]

File.open("clientlist.txt","r"){|c|
  client = c.gets.chomp
  puts "client #{client} is initializing flare"
  puts "command: ssh #{client} \"python flare/account_set.py #{prefix} #{accounts} 1000\""
  `ssh #{client} "python flare/account_set.py #{prefix} #{accounts} 1000"`
}

puts "#{accounts} accounts set."

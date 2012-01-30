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

result = nil
File.open("clientlist.txt","r"){|c|
  client = c.gets.chomp
  puts "client #{client} verifing accounts"
  result = `ssh #{client} "python flare/verify.py #{prefix} #{accounts}"`
}
print result

#!/usr/bin/ruby

command = ARGV.join(' ')
puts "command: #{command}"
File.open("nodelist.txt","r"){|file|
  while node = file.gets
    node.chomp!
    puts "node: #{node}"
    puts `ssh #{node} "#{command}"`
    # $stderr.write "ssh #{node} '#{command}'\n"
  end
}


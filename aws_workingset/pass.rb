#!/usr/bin/ruby
filename="workingset.tar.gz"
`tar cvzf #{filename} *`
File.open("nodelist.txt","r"){|file|
  while node = file.gets
    node.chomp!
    `ssh #{node} "rm * -rf"`
    `scp #{filename} #{node}:~/`
    `ssh #{node} "tar xvf #{filename}; rm #{filename}"`
    # $stderr.write "ssh #{node} '#{command}'\n"
  end
}
`rm #{filename}`

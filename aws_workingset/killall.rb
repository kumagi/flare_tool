#!/usr/bin/ruby

ths = []
IO.foreach("nodelist.txt"){|node|
  node.chomp!
  next if node == ""
  ths << Thread.new{
    `ssh #{node} "killall -q ruby"`
    `ssh #{node} "killall -q python"`
    `ssh #{node} "sudo killall -q flarei"`
    `ssh #{node} "sudo killall -q flared"`
  }
}
ths.each{ |t| t.join}

`killall -q python`
`sudo killall -q flarei`
`sudo killall -q flared`
`killall -q ruby`

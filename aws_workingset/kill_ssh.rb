#!/usr/bin/ruby

tree = `pstree -apn|grep ssh`
process = tree.scan(/ssh,([0-9]*) /).flatten
process.each{ |n|
  `kill #{n}`
}

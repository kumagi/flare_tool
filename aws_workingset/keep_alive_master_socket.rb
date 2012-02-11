#!/usr/bin/ruby
require 'yaml'

nodes = YAML.load_file 'nodelist.yaml'
threads = []
nodes.each{ |node|
  threads  << Thread.new{
    loop do
      begin
        `ssh #{node} while; do echo 'h'; sleep 5; done`
      rescue =>e
      end
    end
  }
}
threads.each{ |t| t.join}

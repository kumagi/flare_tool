import sys
import os
import memcache
import yaml
from time import time

serverlist = yaml.load(open('serverlist.yaml').read())
"""
os.system('./save_myip.rb')
myip = yaml.load(open('myip.yaml').read().decode('utf-8'))
if myip in serverlist:
  serverlist = ["127.0.0.1"]
"""

serverlist = [x+":11211" for x in serverlist]
print "target is " + str(serverlist)

try:
  sys.argv.remove("time")
  sys.argv.remove("python")
except ValueError:
  pass

def parse_args(arg, param_name):
  if len(arg) < len(param_name):
    print "You should set %s" % param_name[len(arg)]
    exit(1)
  return arg
name, first, number, init = parse_args(sys.argv[1:],
                                       ["prefix of accounts", "first index","number of accounts", "first value"])
first = int(first)
number = int(number)
init = int(init)

mc = memcache.Client(serverlist, socket_timeout=20)
kvp = {}
for i in xrange(first, first+number+1):
  kvp[name+str(i)] = init
begin = time()
while True:
  try:
    str(mc.set_multi(kvp))
    break
  except:
    sys.stderr.write("failed connection retry")
    mc = memcache.Client(serverlist, socket_timeout=20)
    continue
end = time()
print "set %s %d~%d accounts to %d (%f qps)" % (name, first, first+number, init, number/ (end-begin))


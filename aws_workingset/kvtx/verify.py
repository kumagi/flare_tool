import sys
import os
import kvtx
import yaml

serverlist = yaml.load(open('serverlist.yaml').read())
"""
os.system('./save_myip.rb')
myip = yaml.load(open('myip.yaml').read())
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
name, first, number, option = parse_args(sys.argv[1:],
                                ["prefix of accounts", "fist of accounts","number of accounts", "option"])

first = int(first)
number = int(number)
option = int(option)

mc = kvtx.WrappedClient(serverlist)
def account_verify(setter, getter):
  for i in range(first, first + number):
    getter(name + str(i))
result = None

if option == 0:
  while True:
    try:
      result = kvtx.rr_transaction(mc, account_verify)
      break
    except Exception,e:
      print e
      mc = kvtx.WrappedClient(serverlist)
      continue
else:
  target = [name + str(x) for x in xrange(first, first+number)]
  result = mc.get_multi(target)

try:
  accum = 0
  for r in result.keys():
    accum += int(result[r])
  print float(accum) / number
  print ' is it ok?'
except TypeError:
  none = []
  for r in result.keys():
    if result[r] == None:
      none.append(r)
  print str(none)

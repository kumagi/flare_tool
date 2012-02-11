import sys
import kvtx
import yaml
import os
from random import Random
from threading import Thread
from time import sleep

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
prefix, accounts, num, parallel = parse_args(sys.argv[1:],
                          ["prefix of accounts",
                           "number of accounts",
                           "number of work",
                           "parallels"])

num = int(num)
accounts = int(accounts)
parallel = int(parallel)

if num < parallel:
  print("you should set parallel less than numbers")
  exit(1)

done = []
done.append(0)
def work():
  mc = kvtx.WrappedClient(serverlist)
  rnd = Random()
  random_account = lambda:rnd.randint(0, accounts-1)
  random_money = lambda:rnd.randint(0, 100)
  while True:
    from_number = random_account()
    to_number = random_account()
    from_account = prefix + str(from_number)
    to_account = prefix + str(to_number)
    if from_account == to_account:
      continue
    moves = random_money()
    #print "%s =%s=> %s" % (from_account, moves, to_account)
    def move(s,g):
      from_money = g(from_account)
      to_money = g(to_account)
      try:
        assert(isinstance(from_money, int))
        assert(isinstance(to_money, int))
      except AssertionError:
        print("Invalid account. from_money %s(account:%d), to_money %s(account:%d)" % (str(from_money), from_number, str(to_money), to_number))
        raise kvtx.AbortException
      #print "%s[%d -> %d] =%d=> %s[%d -> %d]" % (from_account, from_money, from_money - moves, moves, to_account, to_money, to_money + moves)
      from_money -= moves
      to_money += moves
      s(from_account, from_money)
      s(to_account, to_money)
    kvtx.rr_transaction(mc, move)
    done[0] += 1
    if num <= done[0]:
      #print("all done. %d " % done[0])
      return
threads = []
for j in range(parallel):
  new_thread = Thread(target = work)
  new_thread.start()
  threads.append(new_thread)
while done[0] < num:
  sleep(0.1)
print "@work done@"
#sys.stderr.write("@work done@")

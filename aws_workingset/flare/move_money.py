import sys
import kvtx
from random import Random
from threading import Thread

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
prefix, num, accounts, parallel = parse_args(sys.argv[1:],
                          ["prefix of accounts",
                           "number of work",
                           "number of accounts",
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
  mc = kvtx.WrappedClient(["127.0.0.1:11211"])
  rnd = Random()
  random_account = lambda:rnd.randint(0, accounts-1)
  random_money = lambda:rnd.randint(0, 100)
  while True:
    from_account = prefix + str(random_account())
    to_account = prefix + str(random_account())
    if from_account == to_account:
      continue
    moves = random_money()
    #print "%s =%s=> %s" % (from_account, moves, to_account)
    def move(s,g):
      from_money = g(from_account)
      to_money = g(to_account)
      assert(isinstance(from_money, int))
      assert(isinstance(to_money, int))
      print "%s[%d -> %d] =%d=> %s[%d -> %d]" % (from_account, from_money, from_money - moves, moves, to_account, to_money, to_money + moves)
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
for j in range(len(threads)):
  threads[j].join()

import memcache
import sys
from time import time
from time import sleep
print 'start'

def parse_args(arg, param_name):
  if len(arg) < len(param_name):
    print "You should set %s" % param_name[len(arg)]
    exit(1)
  return arg
try:
  sys.argv.remove("time")
except ValueError:
  pass
# print sys.argv
num, palallel = parse_args(sys.argv[1:], ["number", "parallel"])

num = int(num)
palallel = int(palallel)
hostname = "localhost:11211"
if num == 0:
  raise "num must be bigger than 0"
setcount = 0

def set_for_limit():
  global setcount
  counter = 0
  while True:
    try:
      client = memcache.Client([hostname])
      while setcount < num:
        client.set("key" + str(counter), 'p'*20)
        counter += 1
        setcount += 1
      return
    except Exception, e:
      print "except", e


from threading import Thread
start = time()
threads = []
for j in range(palallel):
  new_thread = Thread(target = set_for_limit)
  new_thread.start()
  threads.append(new_thread)
while setcount < num:
  sleep(0.1)
print setcount / (time() - start) ,"qps"
print "@work done@"
exit()

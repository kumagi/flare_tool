import memcache
import sys
from time import time

hostname = '127.0.0.1:11211'
#hostname = str(sys.argv[1]) + ':11212'

def parse_args(arg, param_name):
  if len(arg) < len(param_name):
    print "You should set %s" % param_name[len(arg)]
    exit(1)
  return arg

try:
  sys.argv.remove("time")
except ValueError:
  pass
print sys.argv
num, key, palallel = parse_args(sys.argv[1:], ["number of keys", "prefix of keys", "palallel"])


print num
num = int(num)
palallel = int(palallel)

print "set %d key" % num

if num == 0:
  raise "num must be bigger than 0"

setcount = 0

def set_for_limit(hostname, limit, prefix):
  global setcount
  counter = 0
  while True:
    try:
      client = memcache.Client([hostname])
      while setcount < limit:
        client.set(prefix + str(counter), 'p'*1)
        counter += 1
        setcount += 1
      return
    except Exception, e:
      print "except", e


from threading import Thread
start = time()
threads = []
for j in range(num / palallel):
  new_thread = Thread(target = lambda prefix: set_for_limit(hostname, num, prefix),
                      args = ("%s:%s:" % (key, str(j)),))
  new_thread.start()
  threads.append(new_thread)
for j in range(len(threads)):
  threads[j].join()
print setcount / (time() - start) ,"qps"
quit()


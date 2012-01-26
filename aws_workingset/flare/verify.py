import sys
import kvtx

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
name, number = parse_args(sys.argv[1:],
                                ["prefix of accounts", "number of accounts"])
number = int(number)

mc = kvtx.WrappedClient(["127.0.0.1:11211"])
def account_verify(setter, getter):
  for i in range(number):
    getter(name + str(i))
result = kvtx.rr_transaction(mc, account_verify)

sum = 0
for k in result.keys():
  sum += result[k]
print sum

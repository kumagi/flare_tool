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
name, number, init = parse_args(sys.argv[1:],
                                ["prefix of accounts", "number of accounts", "first value"])
number = int(number)
init = int(init)

mc = kvtx.WrappedClient(["127.0.0.1:11211"])
def account_make(setter, getter):
  for i in range(number):
    setter(name + str(i), init)
kvtx.rr_transaction(mc, account_make)
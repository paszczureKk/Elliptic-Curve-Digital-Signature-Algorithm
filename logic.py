#!/usr/bin/python

import sys

result = 0

var1 = int(sys.argv[2],10)
var2 = int(sys.argv[3],16)

if sys.argv[1] == '<=':
    if var1 <= var2:
        result = 1
    else:
        result = 0
elif sys.argv[1] == '>=':
    if var1 >= var2:
        result = 1
    else:
        result = 0
elif sys.argv[1] == '==':
    if var1 == var2:
        result = 1
    else:
        result = 0
elif sys.argv[1] == '!=':
    if var1 != var2:
        result = 1
    else:
        result = 0


print result

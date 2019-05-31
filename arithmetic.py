#!/usr/bin/python

import sys

result = 0

var1 = int(sys.argv[2],16)
var2 = int(sys.argv[3],16)

if sys.argv[1] == "sum":
    result = var1 + var2
elif sys.argv[1] == "sub":
    result = var1 - var2
elif sys.argv[1] == "div":
    result = var1 / var2
elif sys.argv[1] == "fdiv":
    result = var1 // var2
elif sys.argv[1] == "mul":
    result = var1 * var2
elif sys.argv[1] == "pow":
    result = var1 ** var2
elif sys.argv[1] == "mod":
    result = var1 % var2
elif sys.argv[1] == "con":
    result = var1 & var2


print '{:x}'.format(result)

#!/usr/bin/python

import sys

result = 0

p = int(sys.argv[2],16)

u = 1
w = int(sys.argv[1],16)

x = 0
z = p

while w != 0 :

    print w

    if w < z :
        u, x = x, u
        w, z = z, w
        
    q = w // z

    u = u - q * x
    w = w - q * z

if z != 1 :
    result = 1
else :
    if x < 0 :
        x = x + p

    result = x


print '{:064x}'.format(result)

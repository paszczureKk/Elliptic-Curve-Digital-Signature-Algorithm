#!/usr/bin/python

import sys

def rightrotate(word, d):

    if isinstance(word, str):
        temp = word
    else:
        temp = "{:b}".format(word)

    first = temp[0 : len(temp)-d] 
    second = temp[len(temp)-d : ]

    return (second + first)

def rightshift(word, d):

    temp = int(word, 2)
    temp = temp >> d
    return "{:b}".format(temp)

def xor(a, b):

    if isinstance(a, str):
        tempa = int(a, 2)
    else:
        tempa = a

    if isinstance(b, str):
        tempb = int(b, 2)
    else:
        tempb = b

    result = tempa ^ tempb

    return "{:b}".format(result)


result = 0

message = sys.argv[1]
numbermessage=""

for i in bytearray(message, 'ascii'):
    numbermessage = numbermessage + str(i);

numbermessage = "{:b}".format(int(numbermessage))

#constants initialization

p = 2 ** 32

#first 32 bits of fractional part of square root within range 8 first prime numbers [2-19]
h = [
1779033703, 3144134277, 1013904242, 2773480762,
1359893119, 2600822924, 528734635,  1541459225
]

#first 32 bits of fractional part of cube root within range first 64 first prime numbers [2-311]
k = [
1116352408, 1899447441, 3049323471, 3921009573, 961987163,  1508970993, 2453635748, 2870763221,
3624381080, 310598401,  607225278,  1426881987, 1925078388, 2162078206, 2614888103, 3248222580,
3835390401, 4022224774, 264347078,  604807628,  770255983,  1249150122, 1555081692, 1996064986,
2554220882, 2821834349, 2952996808, 3210313671, 3336571891, 3584528711, 113926993,  338241895,
666307205,  773529912,  1294757372, 1396182291, 1695183700, 1986661051, 2177026350, 2456956037,
2730485921, 2820302411, 3259730800, 3345764771, 3516065817, 3600352804, 4094571909, 275423344,
430227734,  506948616,  659060556,  883997877,  958139571,  1322822218, 1537002063, 1747873779,
1955562222, 2024104815, 2227730452, 2361852424, 2428436474, 2756734187, 3204031479, 3329325298
]

#pretreatment
meslen = "{:064b}".format(len(numbermessage))

numbermessage = numbermessage + "1"

while len(numbermessage) % 512 != 448:
    numbermessage = numbermessage + "0"

numbermessage = numbermessage + meslen

slices = [numbermessage[i:i+512] for i in range(0, len(numbermessage), 512)]

for m in slices:
    w = [m[i:i+32] for i in range(0, len(m), 32)]
    
    for i in range(16, 64):
        s0 = xor(xor(rightrotate(w[i-15], 7), rightrotate(w[i-15], 18)),rightshift(w[i-15], 3))
        #s0 := (w[i-15] rightrotate  7) xor  (w[i-15] rightrotate  18) xor  (w[i-15] rightshift  3)
        s1 = xor(xor(rightrotate(w[i-2], 17), rightrotate(w[i-2], 19)), rightshift(w[i-2], 10))
        #s1 = (w[i-2] rightrotate  17) xor  (w[i-2] rightrotate  19) xor  (w[i-2] rightshift  10)
        w.append("{:b}".format(int(w[i-16], 2) +  int(s0, 2) +  int(w[i-7], 2) + int(s1, 2)))
        #w[i] := w[i-16] +  s0 +  w[i-7] +  s1

    a = h[0]
    b = h[1]
    c = h[2]
    d = h[3]
    e = h[4]
    f = h[5]
    g = h[6]
    j = h[7]

    for i in range(0, 64):
        s1  = xor(xor(rightrotate(e, 6), rightrotate(e, 11)), rightrotate(e, 25))
        #s1  = (e rightrotate 6) xor (e rightrotate 11) xor (e rightrotate 25)
        ch  = xor((e & f), ((~e) & g))
        #ch  = (e and f) xor ((not e) and g)
        t1  = j + int(s1, 2) + int(ch, 2) + k[i] + int(w[i], 2)
        #t1 := j + s1 + ch + k[i] + w[i]
        s0 = xor(xor(rightrotate(a, 2), rightrotate(a, 13)), rightrotate(a, 22))
        #s0  = (a rightrotate 2) xor (a rightrotate 13) xor (a rightrotate 22)
        maj = xor(xor((a & b), (a & c)), (b & c))
        #maj = (a and b) xor (a and c) xor (b and c)
        t2  = int(s0, 2) + int(maj, 2)

        j = g
        g = f
        f = e
        e = d + t1
        d = c
        c = b
        b = a
        a = t1 + t2

    h[0] = (h[0] + a) % p
    h[1] = (h[1] + b) % p
    h[2] = (h[2] + c) % p
    h[3] = (h[3] + d) % p
    h[4] = (h[4] + e) % p
    h[5] = (h[5] + f) % p
    h[6] = (h[6] + g) % p
    h[7] = (h[7] + j) % p

seed = "{:08x}".format(h[0]) + "{:08x}".format(h[1]) + "{:08x}".format(h[2]) + "{:08x}".format(h[3])\
     + "{:08x}".format(h[4]) + "{:08x}".format(h[5]) + "{:08x}".format(h[6]) + "{:08x}".format(h[7])
#hash = h0 append  h1 append  h2 append  h3 append  h4 append  h5 append  h6 append  h7

print seed


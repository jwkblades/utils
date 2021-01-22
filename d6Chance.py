#!/bin/python

from math import factorial

def choose(a, b):
    return factorial(a) / (factorial(b) * factorial(a - b))

def chance(dice, passes):
    num = sum([choose(dice, x) for x in range(0, dice - passes + 1)])
    return num / (2 ** dice)

def chance2(dice, passes, prob = 1/2):
    pct = 0;
    for x in range(0, dice - passes + 1):
        pct += ((prob) ** (dice - x)) * ((1 - prob) ** (x)) * choose(dice, x)
    return pct


print("d \ p", end="\t")
for i in range(1, 10):
    print(i, end="\t")
print()

for dice in range(1, 20):
    print(dice, end="\t")
    for passes in range(1, min(dice + 1, 10)):
        print("{0:1.3f}".format(chance2(dice, passes, 2/3)), end="\t") 
    for j in range(min(dice + 1, 10), 10):
        print("0", end="\t")
    print()

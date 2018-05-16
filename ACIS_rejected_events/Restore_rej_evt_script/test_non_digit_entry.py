#!/usr/local/bin/python

#################################################################################
#                                                                               #
#      t_non_digit_entry.py: test whether any line has non digit entry          #
#                                                                               #
#           author: t. isobe (tisobe@cfa.harvard.edu)                           #
#                                                                               #
#           last update: Apr. 14, 2015                                          #
#                                                                               #
#################################################################################

import re
import os
import sys

file = sys.argv[1]
file.strip()

f   = open(file, 'r')
data = [line.strip() for line in f.readlines()]
f.close()

i = 0
for ent in data:
    atemp = re.split('\s+', ent)
    for test in atemp:
        try:
            out = float(test)
        except:
            print str(i) + '<--->' + ent
            break
    i += 1
    

#!/usr/bin/env /proj/sot/ska/bin/python

###################################################################
#
#       sort_by_first_val.py
#
#       author: t. isobe (tisobe@cfa.harvard.edu)
#       last update Nov 24, 2015
#
###################################################################

import sys
import os
import re
import random
import numpy as np

#----------------------------------------------------------------
#-- sort_list: sort by the first column assuming that it is numeric 
#----------------------------------------------------------------

def sort_list(file):
    """
    sort by the first column assuming that it is numeric
    input:  file    --- file name
    output: zout    --- file containing the sorted data 
    """

    f    = open(file, 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()

    data.sort()
    updated = []
    prev    = ''
    for ent in data:
        if ent == prev:
            continue
        else:
            updated.append(ent)


    tlist = []
    for ent in updated:
        atemp = re.split('\s+', ent)
        try:
            val   = float(atemp[0])
        except:
            continue

        tlist.append(val)

    sind = np.argsort(tlist)

    prev    = ''
    fo = open('./zout', 'w')
    for k in sind:
        if updated[k] == prev:
            continue
        else:
            fo.write(updated[k])
            fo.write('\n')
            prev = updated[k]

    fo.close()

    cmd = 'mv ./zout ' +  file
    os.system(cmd)
        

#----------------------------------------------------------------

if __name__ == "__main__":

    file = sys.argv[1]
    file.strip()

    sort_list(file)





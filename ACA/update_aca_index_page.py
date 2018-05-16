#!/usr/bin/env /proj/sot/ska/bin/python

#############################################################################################
#                                                                                           #  
#       update_aca_index_page.py: update aca index page                                     #
#                                                                                           #
#           author: t. isobe (tisobe@cfa.harvard.edu)                                       #
#                                                                                           #
#           last update: Mar 27, 2018                                                       #
#                                                                                           #
#############################################################################################

import os
import sys
import re
import random
import time
#
#--- reading directory list
#
path = '/data/mta/Script/Python_script2.7/dir_list_py'

f    = open(path, 'r')
data = [line.strip() for line in f.readlines()]
f.close()

for ent in data:
    atemp = re.split(':', ent)
    var  = atemp[1].strip()
    line = atemp[0].strip()
    exec "%s = %s" %(var, line)

#
#--- append a path to a private folder to python directory
#
sys.path.append(mta_dir)

import mta_common_functions as mcf
import convertTimeFormat    as tcnv

#
#--- temp writing file name
#
rtail  = int(10000 * random.random())       #---- put a romdom # tail so that it won't mix up with other scripts space
zspace = '/tmp/zspace' + str(rtail)
#
#--- main path
#
dir_path = '/data/mta4/www/DAILY/mta_pcad/ACA/Script/'
out_path = '/data/mta4/www/DAILY/mta_pcad/ACA/'

smon = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']

#-------------------------------------------------------------------------------------------
#-- update_aca_index_page: update aca index page                                          --
#-------------------------------------------------------------------------------------------

def update_aca_index_page():
    """
    update aca index page
    input:  none, but use Template/index_template
    output: <out_path>/index.html
    """

    tfile = dir_path + 'Template/index_template'
    f     = open(tfile, 'r')
    page  = f.read()
    f.close()

    out   = time.strftime("%Y:%m", time.gmtime())
    atemp = re.split(':', out)
    lyear = int(float(atemp[0]))
    lmon  = int(float(atemp[1]))

    line  = ''
    for  year in range(lyear, 1998, -1):
        syear = str(year)
        syr   = syear[2] + syear[3]
        line  = line + '<tr>\n<th>' + str(year) + '</th>\n'
        for mon in range(1, 13):
            if (year == lyear) and (mon > lmon):
                cell = '<td>&#160;</td>\n'
            elif (year == 1999) and (mon < 8):
                cell = '<td>&#160;</td>\n'
            else:
                clink = smon[mon-1] + syr 
                cell = '<td><a href="https://cxc.cfa.harvard.edu/mta_days/mta_pcad/ACA/' 
                cell = cell + clink + '/Report/acatrd.html">' +  clink + '</a></td>\n'
            line = line + cell

        line  = line + '</tr>\n'

    page  = page.replace('#TABLE#', line)

    ofile = out_path + 'index.html'
    fo    = open(ofile, 'w')
    fo.write(page)
    fo.close()
    

#-------------------------------------------------------------------------------------------

if  __name__ == "__main__":

    update_aca_index_page()





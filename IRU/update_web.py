#!/usr/bin/env /proj/sot/ska/bin/python

#####################################################################################
#                                                                                   #
#       update_web.py: update bias.html page                                        #
#                                                                                   #
#           author: t. isobe (tisobe@cfa.harvard.edu)                               #
#           last update: Nov 18, 2015                                               #
#                                                                                   #
#####################################################################################

import os
import sys
import re
import string
import random
import datetime
#
#--- reading directory list
#
path = '/data/mta/Script/Python_script2.7/house_keeping/dir_list'

f= open(path, 'r')
data = [line.strip() for line in f.readlines()]
f.close()

for ent in data:
    atemp = re.split(':', ent)
    var  = atemp[1].strip()
    line = atemp[0].strip()
    exec "%s = %s" %(var, line)
#
#--- append  pathes to private folders to a python directory
#
sys.path.append(bin_dir)
sys.path.append(mta_dir)
#
#--- import several functions
#
import convertTimeFormat          as tcnv       #---- contains MTA time conversion routines
import mta_common_functions       as mcf        #---- contains other functions commonly used in MTA scripts

#--------------------------------------------------------------------------------
#-- update_web: updating bias.html                                             --
#--------------------------------------------------------------------------------

def update_web():
    """
    updating bias.html 
    input:  none
    output  the updated bias.html
    """

    mlist = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']
#
#--- read header part
#
    f    = open('./house_keeping/head_part', 'r')
    line = f.read()
    f.close()
#
#--- find today's date
#
    dtime = datetime.datetime.now()
    eyear = dtime.year
    month = dtime.month
#
#--- create monthly table
#
    line = line + '<table border=1 sytle="cellspace=1">' + '\n'
    line = line + '<tr>' + '\n'
    line = line + '<th>Year</th>' + '\n'
    for j in range(0, 12):
        line = line + '<th>' + mlist[j].upper() + '</th>' + '\n'
    line = line + '</tr>' + '\n'

    for year in range(eyear, 1999, -1):
        atemp = str(year)
        syear = atemp[2] + atemp[3]

        line = line + '<tr>' + '\n'
        line = line + '<th>'    + str(year) + '<br />' + '\n'
        line = line + '<a href="Plots/' + str(year) + '_bias.gif">bias</a> <br />' + '\n'
        line = line + '<a href="Plots/' + str(year) + '_hist.gif">hist</a> </th>' + '\n'

        for j in range(0, 12):
            line = line + '<td>' + '\n'
            if year == eyear:
                if j < month:
                    line = line + '<a href="Plots/' + mlist[j] + syear + '_1h_bias.gif">bias</a> <br />' + '\n'
                    line = line + '<a href="Plots/' + mlist[j] + syear + '_1h_hist.gif">hist</a> </td>' + '\n'
                else:
                    line = line + '&#160;</td>' + '\n'
            else:
                line = line + '<a href="Plots/' + mlist[j] + syear + '_1h_bias.gif">bias</a> <br />' + '\n'
                line = line + '<a href="Plots/' + mlist[j] + syear + '_1h_hist.gif">hist</a> </td>' + '\n'
                
        line = line + '</tr>' + '\n'
        line = line + '<tr><th colspan=13>&#160;</th></tr>' + '\n'

    line = line + '</table>' + '\n'
#
#--- read the footer part
#
    f     = open('./house_keeping/foot_part', 'r')
    eline = f.read()
    f.close()
    line  = line + eline
#
#--- update the bias.html
#
    fo   = open('/data/mta4/www/DAILY/mta_pcad/IRU/bias.html', 'w')
    fo.write(line)
    fo.close()

#-------------------------------------------------------------------------------------

if __name__ == "__main__":

    update_web()


            
    


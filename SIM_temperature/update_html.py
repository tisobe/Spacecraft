#!/usr/bin/env /proj/sot/ska/bin/python

#############################################################################################
#                                                                                           #
#       update_html.py: updating html pages                                                 #
#                                                                                           #
#               author: t. isobe (tisobe@cfa.harvard.edu)                                   #
#                                                                                           #
#               last update: Jan 14, 2016                                                   #
#                                                                                           #
#############################################################################################

import os
import sys
import re
import string
import random
import time
import operator
import math
import numpy
import unittest

#
#--- reading directory list
#
path = '/data/mta/Script/SIM/Scripts/house_keeping/dir_list'

f= open(path, 'r')
data = [line.strip() for line in f.readlines()]
f.close()

for ent in data:
    atemp = re.split(':', ent)
    var  = atemp[1].strip()
    line = atemp[0].strip()
    exec "%s = %s" %(var, line)

sys.path.append(mta_dir)
#
#--- import several functions
#
import convertTimeFormat          as tcnv       #---- contains MTA time conversion routines
import mta_common_functions       as mcf        #---- contains other functions commonly used in MTA scripts
#
#--- temp writing file name
#
rtail  = int(10000 * random.random())       #---- put a romdom # tail so that it won't mix up with other scripts space
zspace = '/tmp/zspace' + str(rtail)

#-----------------------------------------------------------------------------------------------------------
#-- update_html: check whether the update is needed and if so, run the update                            ---
#-----------------------------------------------------------------------------------------------------------

def update_html(update):
    """
    check whether the update is needed and if so, run the update
    input:  update  --- if it is 1, run the update without chekcing the file exist or not
    output: none, but updated html pages (in <web_dir>)
    """
#
#--- find today's date
#
    today = time.localtime()
    year  = today.tm_year
#
#--- if update is asked, just run the update
#
    if update > 0:
        run_update(year)
#
#--- otherwise, find the last update, and if needed, run the update
#
    else:
        cmd   = 'ls ' + web_dir +'*.html > ' + zspace
        os.system(cmd)
        f     = open(zspace, 'r')
        out   = f.read()
        f.close()
#
#--- chekcing the file existance (looking for year in the file name)
#
        mcf.rm_file(zspace)
        mc    = re.search(str(year), out)

        if mc is None:
            run_update(year)
            

#-----------------------------------------------------------------------------------------------------------
#-- run_update: update all html pages and add a new one for the year, if needed                          ---
#-----------------------------------------------------------------------------------------------------------

def run_update(year):
    """
    update all html pages and add a new one for the year, if needed
    input:  year    --- this year
    output: none but updated html pages and a new one for this year (in <web_dir>)
    """

    file = house_keeping + 'html_template'
    f    = open(file, 'r')
    data = f.read()
    f.close()
#
#--- full range page
#
    line = '<li>\n'
    line = line + '<span style="padding-right:15px;color:red;font-size:105%">\n'
    line = line + 'Full Range \n'
    line = line + '</span>\n'
    line = line + '</li>\n'

    for lyear in range(1999, year+1):
        line = line + '<li><a href="./sim_' + str(lyear) + '.html">' + str(lyear) + '</a></li>\n'

    out = data.replace('#YEARLIST#', line)
    out = out.replace('#YEAR#', 'fullrange')
    
    file = web_dir + 'fullrange.html'
    fo   = open(file, 'w')
    fo.write(out)
    fo.close()

#
#--- each year page
#
    for lyear in range(1999, year+1):
        line = '<li>\n'
        line = line + '<span style="padding-right:15px">\n'
        line = line + '<a href="./fullrange.html">Full Range</a>\n'
        line = line + '</span>\n'
        line = line + '</li>\n'

        for eyear in range(1999, year+1):
            if eyear == lyear:
                line = line + '<span style="color:red;font-size:105%">\n'
                line = line + str(eyear) + '\n'
                line = line + '</span>\n'
                line = line + '</li>\n'
            else:
                line = line + '<li><a href="./sim_' + str(eyear) + '.html">' + str(eyear) + '</a></li>\n'

        out = data.replace('#YEARLIST#', line)
        out = out.replace('#YEAR#', str(lyear))
    
        file = web_dir + 'sim_' + str(lyear) + '.html'
        fo   = open(file, 'w')
        fo.write(out)
        fo.close()



#-----------------------------------------------------------------------------------------------------------
 
if __name__ == "__main__":

    if len(sys.argv) == 2:
        update = 1
    else:
        update = 0

    update_html(update)

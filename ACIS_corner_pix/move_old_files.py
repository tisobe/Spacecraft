#!/usr/bin/env /proj/sot/ska/bin/python

#################################################################################################
#                                                                                               #
#       move_old_files.py: move old acis plots to a saving directory                            #
#                                                                                               #
#               author: t. isobe (tisobe@cfa.harvard.edu)                                       #
#                                                                                               #
#               last update: Jan 05, 2016                                                       #
#                                                                                               #
#################################################################################################

import sys
import os
import re
import random
import datetime

#
#--- from ska
#
from Ska.Shell import getenv, bash

ascdsenv = getenv('source /home/ascds/.ascrc -r release', shell='tcsh')
ascdsenv['IDL_PATH'] = "+/usr/local/rsi/user_contrib/astron_Oct09/pro:+/home/mta/IDL:/home/nadams/pros:+/data/swolk/idl_libs:/home/mta/IDL/tara:widget_tools:utilities:event_browser"
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
import mta_common_functions       as mcf        #---- contains other functions c
#   
#--- temp writing file name
#
rtail  = int(10000 * random.random())       #---- put a romdom # tail so that it won't mix up with other scripts space
zspace = '/tmp/zspace' + str(rtail)
#
#--- a couple of things needed
#
bin_data = '/data/mta/MTA/data/'
dare   = mcf.get_val('.dare',   dir = bin_data, lst=1)
hakama = mcf.get_val('.hakama', dir = bin_data, lst=1)

web_dir    = '/data/mta_www/mta_acis_sci_run/Corner_pix/'
script_dir = '/data/mta/Script/Corner_pix/Scripts/'

#---------------------------------------------------------------------------------------------------
#-- move_old_files: move older gif files to saving directory                                      --
#---------------------------------------------------------------------------------------------------

def move_old_files():
    """
    move older gif files to saving directory
    input:  none
    output: none
    """
#
#--- find today's date
#
    today = datetime.datetime.now()
    year  = today.year
    month = today.month
    day   = today.day

    syear = str(year)
    smon  = str(month)
    if month < 10:
        smon = '0' + smon
    sday  = str(day)
    if day < 10:
        sday = '0' + sday

    stop   = smon + '/' + sday + '/' + syear[2] + syear[3]
#
#--- find date of 3 months ago
#
    lyear  = year
    lmonth = month - 3
    if lmonth < 1:
        lmonth   = 12 + lmonth
        lyear -= 1

    syear = str(lyear)
    smon  = str(lmonth)
    if lmonth < 10:
        smon = '0' + smon

    start = smon + '/01/' + syear[2] + syear[3]
#
#--- find which acis observations were made duing the past 3 months
#
    flist = find_acis_evt1(start, stop)
    obslist = []
    for ent in flist:
        mc = re.search('acisf', ent)
        if mc is None:
            continue

        atemp = re.split('_', ent)
        btemp = re.split('acisf', atemp[0])
        obslist.append(btemp[1])
#
#--- find any acis observations older than 3 months and moved to Acis_Plots dir
#
    cmd  = 'ls ' + web_dir + 'Week/acisf*gif > ' + zspace
    os.system(cmd)
    f    = open(zspace, 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()
    mcf.rm_file(zspace)

    for ent in data:
        chk = 0
        for comp in obslist:
            mc = re.search(comp, ent)
            if mc is not None:
                chk = 1
                break
        
        if chk == 0:
            cmd = 'mv ' + ent + ' ' + web_dir + 'Acis_Plots/.'
            os.system(cmd)

    cmd =  'gzip  -f ' + web_dir + 'Acis_Plots/*gif'
    os.system(cmd)


#---------------------------------------------------------------------------------------------------
#-- find_acis_evt1: find  acis evt1 files for a given time period                                 --
#---------------------------------------------------------------------------------------------------

def find_acis_evt1(start, stop):
    """
    find  acis evt1 files for a given time period
    input:  start   --- start time in the format of mm/dd/yy (e.g. 05/01/15)
            stop    --- sop time in the format of mm/dd/yy
    output: acisf*evt1.fits.gz
    """
#
#--- write  required arc4gl command
#
    line = 'operation=browse\n'
    line = line + 'dataset=flight\n'
    line = line + 'detector=acis\n'
    line = line + 'level=1\n'
#    line = line + 'version=last\n'
    line = line + 'filetype=evt1\n'
    line = line + 'tstart=' + start + '\n'
    line = line + 'tstop='  + stop  + '\n'
    line = line + 'go\n'
    f    = open(zspace, 'w')
    f.write(line)
    f.close()

    cmd1 = "/usr/bin/env PERL5LIB="
    cmd2 =  ' echo ' +  hakama + ' |arc4gl -U' + dare + ' -Sarcocc -i' + zspace +  '> ./ztemp'
    cmd  = cmd1 + cmd2

    bash(cmd,  env=ascdsenv)
    mcf.rm_file(zspace)

    f    = open('./ztemp', 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()
    mcf.rm_file('./ztemp')

    return data

#---------------------------------------------------------------------------------------------------

if __name__ == "__main__":

    move_old_files()


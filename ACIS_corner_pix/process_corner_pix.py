#!/usr/bin/env /proj/sot/ska/bin/python

#################################################################################################
#                                                                                               #
#       process_corner_pix.py: extract data and create acis corner pixel plots                  #
#                                                                                               #
#               author: t. isobe (tisobe@cfa.harvard.edu)                                       #
#                                                                                               #
#               last update: Jan 05, 2015                                                       #
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
#-- process_corner_pix: extract data and plot indivisual plots and trend plots                   ---
#---------------------------------------------------------------------------------------------------

def process_corner_pix(start, stop):
    """
    extract data and plot indivisual plots and trend plots
    input:  start   --- start time in the format of mm/dd/yy (e.g. 05/01/15)
            stop    --- sop time in the format of mm/dd/yy
    output: <web_dir>/I2cp.dat, I3cp.dat, S2cp.dat, S3cp.dat --- udated data set
            <web_dir>/Acis_Plots/*gif
            <web_dir>/Trend_Plots/*gif
    """
#
#--- set up data period
#
    if start == '':
        [start,stop] = get_data_period()

    print str(start) + '<---->' + str(stop)
#
#--- extract acis evt1 files
#
    extract_acis_evt1(start, stop)
#
#--- unzip the fits files
#
    cmd  = 'gzip -d *gz'
    os.system(cmd)
#
#--- create idl scripts to extract data
#
    cmd  = 'ls *.fits > ' + zspace
    os.system(cmd)
    f    = open(zspace, 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()
    mcf.rm_file(zspace)
#
#--- if there is no data, just exit
#
    if len(data) == 0:
        exit(1)

    line = '.run ' + script_dir +'cpix\n'
    line = line + '.run ' + script_dir +'cpix_afaint\n'
    for ent in data:
        line = line +  'cpix, "' + ent + '", /hist \n'
    line = line + 'exit\n'

    fo   = open('./run.pro', 'w')
    fo.write(line)
    fo.close()
#
#--- copy the data to the current directory
#
#    cmd = 'cp ' + web_dir + '*.dat .'
#    os.system(cmd)
#
#
#--- extract data
#
    cmd = 'idl run'
    os.system(cmd)

    cmd = 'rm -rf *fits'
    os.system(cmd)
#
#--- append  extracted data to the main data table in web_dir
#
    for dat in ('I2cp.dat', 'I3cp.dat', 'S2cp.dat', 'S3cp.dat'):
        cmd = 'cat ./' + dat + ' >>  ' + web_dir + dat 
        os.system(cmd)
#
#--- clean up the data by sort by time and then remove the duplicate
#
        cmd = script_dir + 'sort_by_first_val.py ' +  web_dir + dat
        os.system(cmd)

        cmd = 'rm ' + dat
        os.system(cmd)
#
#--- plot data
#
    cmd1 = "/usr/bin/env PERL5LIB="
    cmd = cmd1 + ' idl ' + script_dir + 'run_plot'
    
    bash(cmd,  env=ascdsenv)
#
#--- move all histogram plots to Week dir
#
    cmd = 'mv acis*gif ' + web_dir + 'Week/.'
    os.system(cmd)
#
#--- move trend plots to trend dir
#
    cmd = 'mv I*cp*gif S*cp*gif ' + web_dir + 'Trend_Plots/. 2>/dev/null'
    os.system(cmd)

#---------------------------------------------------------------------------------------------------
#-- get_data_period: set start and stop time of the data period                                  ---
#---------------------------------------------------------------------------------------------------

def get_data_period():
    """
    set start and stop time of the data period
    input:  none
    output: [start, stop]   --- in format of mm/dd/yy
    """
#
#--- find the last date of the data update
#
    maxt = 0
    for dname in ('I2cp.dat', 'I3cp.dat', 'S2cp.dat', 'S3cp.dat'):
        file = web_dir + dname
        f    = open(file, 'r')
        data = [line.strip() for line in f.readlines()]
        f.close()
        atemp = re.split('\s+', data[-1])
        val   = float(atemp[0])
        if val > maxt:
            maxt = int(val)

    atemp = tcnv.axTimeMTA(str(maxt))
    ttemp = re.split(':', atemp)
    year  = int(float(ttemp[0]))
    ydate = int(float(ttemp[1]))
    (month, mdate) =  tcnv.changeYdateToMonDate(year, ydate)

    smon = str(month)
    if month < 10:
        smon = '0' + smon

    sday = str(mdate)
    if mdate < 10:
        sday = '0' + sday

    start = smon + '/' + sday + '/' + ttemp[0][2] + ttemp[0][3]
#
#--- find today's date; it will be the last date of the period
#
    ctime = datetime.datetime.now()
    syear = str(ctime.year)
    month = ctime.month
    cmon  = str(month)

    if month < 10:
        cmon = '0' + cmon

    date  = ctime.day
    cday  = str(date)

    if date < 10:
        cday = '0' + cday

    stop = cmon + '/' + cday + '/' + syear[2] + syear[3]

    return [start, stop]

#---------------------------------------------------------------------------------------------------
#-- extract_acis_evt1: extract acis evt1 files                                                    --
#---------------------------------------------------------------------------------------------------

def extract_acis_evt1(start, stop):
    """
    extract acis evt1 files
    input:  start   --- start time in the format of mm/dd/yy (e.g. 05/01/15)
            stop    --- sop time in the format of mm/dd/yy
    output: acisf*evt1.fits.gz
    """
#
#--- write  required arc4gl command
#
    line = 'operation=retrieve\n'
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
    cmd2 =  ' echo ' +  hakama + ' |arc4gl -U' + dare + ' -Sarcocc -i' + zspace
    cmd  = cmd1 + cmd2

    bash(cmd,  env=ascdsenv)
    mcf.rm_file(zspace)


#---------------------------------------------------------------------------------------------------

if __name__ == "__main__":

    if len(sys.argv) > 2:
        start = sys.argv[1]
        stop  = sys.argv[2]
    else:
        start = ''
        stop  = ''

    process_corner_pix(start, stop)


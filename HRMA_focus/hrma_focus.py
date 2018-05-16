#!/usr/bin/env /proj/sot/ska/bin/python

#################################################################################################
#                                                                                               #
#           hrma_focus.py: extract data and plot hrma focus related plots                       #
#                                                                                               #
#               author: t. isobe (tisobe@cfa.harvard.edu)                                       #
#                                                                                               #
#               last update: Apr 25, 2016                                                       #
#                                                                                               #
#################################################################################################


import os
import sys
import re
import string
import random
import operator
import math
import numpy
import astropy.io.fits  as pyfits
import time
#
#--- from ska
#
from Ska.Shell import getenv, bash

ascdsenv = getenv('source /home/ascds/.ascrc -r release; source /home/mta/bin/reset_param', shell='tcsh')
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

#
#--- temp writing file name
#
# couple of things needed
#
bin_data = '/data/mta4/MTA/data/'
dare     = mcf.get_val('.dare',   dir = bin_data, lst=1)
hakama   = mcf.get_val('.hakama', dir = bin_data, lst=1)
rtail    = int(10000 * random.random())       #---- put a romdom # tail so that it won't mix up with other scripts space
zspace   = '/tmp/zspace' + str(rtail)

tdir     = '/data/mta4/www/DAILY/mta_src/'

idir     = '/usr/local/bin/'

#-----------------------------------------------------------------------------------------
#-- extract_data: extract data to compute HRMA focus plots                              --
#-----------------------------------------------------------------------------------------

def extract_data(start, stop):
    """
    extract data to compute HRMA focus plots
    input:  start   ---- start time in the foramt of mm/dd/yy (e.g. 05/01/15)
            stio    ---- stop time in the format of mm/dd/yy
    output: acis*evt2.fits.gz, hrc*evt2.fits.gz
    """

    os.system('rm -rf param')
    os.system('mkdir param')
#
#--- check whether previous fits files are still around, and if so, remove them
#
    cmd = 'ls * > ' + zspace
    os.system(cmd)
    f   = open(zspace, 'r')
    chk = f.read(10000000)
    f.close()
    mcf.rm_file(zspace)
    mc  = re.search('fits', chk)
    if mc is not None:
        cmd = 'rm *fits*'
        os.system(cmd)
#
#--- if time interval is not given, set for a month interval
#
    if start == '':
        [start, stop] = set_interval()
#
#--- extract acis and hrc evt2 files
#
    inst = 'acis'
    run_arc(inst, start, stop)
    inst = 'hrc'
    run_arc(inst, start, stop)

#-----------------------------------------------------------------------------------------
#-- set_interval: set time inteval for a month                                          --
#-----------------------------------------------------------------------------------------

def set_interval():
    """
    set time inteval for a month
    if today's date is < 10, the inteval starts 1st of the last month till 1st of this month
    if today's date is >=10, the inteval starts 1st of the this month till 1st of the next month
    input:  none
    output: start   --- start time in format of mm/dd/yy (e.g., 05/01/15)
            stop    --- stop time in format of mm/dd/yy
    """
#
#--- find today's year, mon and date
#
    tlist = tcnv.currentTime()
    year  = tlist[0]
    mon   = tlist[1]
    day   = tlist[2]
#
#--- create time stamp for the beginning of this month
#
    syear = str(year)
    smon  = str(mon)
    if mon < 10:
        smon = '0' + smon

    time1 = smon + '/01/' + syear[2] + syear[3]

#
#--- if today's date is < 10, set the start time to the 1st of the last month
#
    if day < 10:
        lyear = year
        lmon  = mon - 1
        if lmon < 1:
            lmon  = 12
            lyear -= 1

        syear = str(lyear)
        smon  = str(lmon)
        if mon < 10:
            smon = '0' + smon

        start = smon + '/01/' + syear[2] + syear[3]
        stop  = time1
#
#--- if today's date is >= 10, set the stop time to the 1st of the next month
#
    else:
        lyear = year
        lmon  = mon + 1
        if lmon > 12:
            lmon   = 1
            lyear += 1

        syear = str(lyear)
        smon  = str(lmon)
        if mon < 10:
            smon = '0' + smon

        stop  = smon + '/01/' + syear[2] + syear[3]
        start = time1

    return (start, stop)

#-----------------------------------------------------------------------------------------
#-- run_arc: run arc4gl and extract evt2 data for "inst"                                --
#-----------------------------------------------------------------------------------------

def run_arc(inst, start, stop):
    """
    run arc4gl and extract evt2 data for "inst"
    input:  inst    --- instrument, acis or hrc
            start   --- interval start time in format of mm/dd/yy (e.g. 05/01/15)
            stop    --- interval stop time in format of mm/dd/yy
    """

    line = 'operation=retrieve\n'
    line = line + 'dataset=flight\n'
    line = line + 'detector=' + inst + '\n'
    line = line + 'level=2\n'
    line = line + 'filetype=evt2\n'
    line = line + 'tstart=' + start + '\n'
    line = line + 'tstop=' + stop  + '\n'
    line = line + 'go\n'
    f    = open(zspace, 'w')
    f.write(line)
    f.close()

    cmd1 = "/usr/bin/env PERL5LIB="
    cmd2 =  ' echo ' +  hakama + ' |arc4gl -U' + dare + ' -Sarcocc -i' + zspace
    cmd  = cmd1 + cmd2
#
#--- run arc4gl
#
    bash(cmd,  env=ascdsenv)
    mcf.rm_file(zspace)

#-----------------------------------------------------------------------------------------
#-- create_run_script: create cell detect command list for the current data set         --
#-----------------------------------------------------------------------------------------

def create_run_script():
    """
    create cell detect command list for the current data set
    input:  none but create a list from fits files in the current directory
    output: ./run_script    ---- cell detect command list file
    """


    cmd = 'ls *.fits.gz > ' + zspace
    os.system(cmd)
    
    f    = open(zspace, 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()

    cmd = 'ls acisf5*.fits.gz hrcf5*.fits.gz  > ' + zspace
    os.system(cmd)
    
    f    = open(zspace, 'r')
    comp = [line.strip() for line in f.readlines()]
    f.close()


    list3 = [item for item in data if item not in comp]
    data  = list3

    cmd1 = "/usr/bin/env PERL5LIB="
    cmd2 =  ' run_script > /dev/null'
    bcmd = cmd1 + cmd2

    for ent in data:
#
#--- handle only none grating observations
#
        grating = read_header_value(ent, 'GRATING')

        if grating == 'NONE':
            ent2 = ent.replace('evt', 'src')
            ent2 = ent2.replace('.gz', '')
            line = "pset celldetect infile=" + ent + "\n"
            line = line + "pset celldetect outfile=" + ent2 + "\n"
            line = line + "celldetect mode=h\n"
            fo   = open('./run_script', 'w')
            fo.write(line)
    
            fo.close()
            cmd = 'chmod 755 ./run_script'
            os.system(cmd)
#
#--- run celldetect script
#
            try:
                bash(bcmd,  env=ascdsenv)
            except:
                pass


#-----------------------------------------------------------------------------------------
#-- run_idl_scripts:  run cell detect script list and then analyze the data and make plots 
#-----------------------------------------------------------------------------------------

def run_idl_scripts():
    """
    run cell detect script list and then analyze the data and make plots
    input:  none but just run: "./run_script"
    output: *src2.fits
    """
    mcf.rm_file(zspace)
#
#--- run the rest of the idl scripts
#
    cmd = 'rm -rf *_evt2.fits.gz'
    os.system(cmd)

    cmd = 'ls *src2.fits* > src_mon.lst'
    os.system(cmd)

    cmd =  idir + 'idl ' + tdir + 'Scripts/run'
    os.system(cmd)

    cmd = 'cat src_mon.tab >> src_mon.txt'        #----!!! move sc_mon.txt to house_keeping !!!
    os.system(cmd)

    cmd = idir + 'idl ' + tdir + 'Scripts/run_txt'
    os.system(cmd)

    cmd = 'mv -f *.html *.gif ' + tdir + '/.'
    os.system(cmd)

    cmd = 'rm -f *.fits xafit* xtmpsrcdata'
    os.system(cmd)

#-----------------------------------------------------------------------------------------
#-- update_index_page: change "Last Updated" date                                       --
#-----------------------------------------------------------------------------------------

def update_index_page():
    """
    change "Last Updated" date
    input:  original index.hmlt page 
    output: updated index.html page
    """

    today = time.strftime("%b %d %Y",  time.localtime())
    uline = 'Last Updated: ' + today

    file = tdir + 'index.html'
    f    = open(file, 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()

    fo   = open(file, 'w')
    for ent in data:
        mc  = re.search("Last", ent)
        if mc is not None:
            fo.write(uline)
        else:
            fo.write(ent)

        fo.write("\n")

    fo.close()

#-----------------------------------------------------------------------------------------------
#-- read_header_value: read fits header value for a given parameter name                      --
#-----------------------------------------------------------------------------------------------

def read_header_value(fits, name):
    """
    read fits header value for a given parameter name
    input:  fits--- fits file name
    name--- parameter name
    output: val --- parameter value
    if the parameter does not exist, reuturn "NULL"
    """

    hfits = pyfits.open(fits)
    hdr   = hfits[1].header
    try:
        val   = hdr[name.lower()]
    except:
        val   = NULL
    
    hfits.close()
    
    return val


#-----------------------------------------------------------------------------------------

if __name__ == "__main__":

    if len(sys.argv) > 2:
        start = sys.argv[1].strip()
        stop  = sys.argv[2].strip()
    else:
        start = ''
        stop  = ''

    extract_data(start, stop)

    create_run_script()

    run_idl_scripts()

    update_index_page()

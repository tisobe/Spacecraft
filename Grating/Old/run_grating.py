#!/usr/bin/env /proj/sot/ska/bin/python

#################################################################################
#                                                                               #
#       run_grating.py: process grating data                                    #
#                                                                               #
#           author: t. isobe (tisobe@cfa.harvard.edu)                           #
#                                                                               #
#           last update: May 10, 2016                                           #
#                                                                               #
#################################################################################

import os
import sys
import re
import string
import math
import numpy
import unittest
import time
import datetime

#
#--- from ska
#
from Ska.Shell import getenv, bash
ascdsenv  = getenv('source /home/ascds/.ascrc -r release', shell='tcsh')

bin_dir = '/data/mta4/Gratings/Script/'
mta_dir = '/data/mta/Script/Python_script2.7/'
dat_dir = '/data/mta/MTA/data/'

#
#--- append a path to a private folder to python directory
#
sys.path.append(bin_dir)
sys.path.append(mta_dir)
#
#--- converTimeFormat contains MTA time conversion routines
#
import convertTimeFormat    as tcnv
import mta_common_functions as mcf

#
#--- a couple of things needed
#
dare   = mcf.get_val('.dare',   dir = dat_dir, lst=1)
hakama = mcf.get_val('.hakama', dir = dat_dir, lst=1)

m_list = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

rtail  = int(time.time())
zspace = '/tmp/zspace' + str(rtail)

#--------------------------------------------------------------------------------------
#-- run_grating: controlling function to run the script                              --
#--------------------------------------------------------------------------------------

def run_grating():
    """
    controlling function to run the script
    input:  none
    output: /data/mta/www/mta_grat/<dir> where dir is <Mon><yy>
    """
#
#--- set data collecting range
#
    (start, stop, dir) = find_time_interval()
#
#--- extract needed data fits files
#
    run_arc4gl(start, stop)
#
#--- process fits files
#
    run_idl(dir)
#
#--- update records
#
    update_record(dir)
#
#--- move the data to an appropriate location
#
    cdir = '/data/mta/www/mta_grat/' + dir
    if os.path.isdir(cdir):
        cmd = 'cp -f /data/mta4/Gratings/' + dir + '/* ' + cdir + '.'
        os.system(cmd)
        cmd = ' rm -rf  /data/mta4/Gratings/' + dir
        os.system(cmd)
    else:
        cmd = 'mv /data/mta4/Gratings/' + dir + ' /data/mta/www/mta_grat/.'
        os.system(cmd)
#
#--- clean up
#
    os.system('rm -rf *.fits.gz')
    os.system('rm -rf run_arc mk_idl_command.pl mkcommand.idl')

#--------------------------------------------------------------------------------------
#-- run_arc4gl: extract acis and hrc evt1a.fits files using arc4gl                   --
#--------------------------------------------------------------------------------------

def run_arc4gl(start, stop):
    """
    extract acis and hrc evt1a.fits files using arc4gl
    input:  start   --- start time in the format of 03/01/15
            stop    --- stop time
    output: fits files (e.g., acisf17108_001N002_evt1a.fits.gz)
    """
#
#--- read a template and create the current command file
#
    file = bin_dir + 'house_keeping/arc_template'

    line = open(file, 'r').read()
    line = line.replace('#START#', start)
    line = line.replace('#STOP#',  stop)

    fo   = open('./run_arc', 'w')
    fo.write(line)
    fo.close()
#
#--- run arc4gl
#
    cmd1 = "/usr/bin/env PERL5LIB="
    cmd2 =  ' echo ' +  hakama + ' |arc4gl -U' + dare + ' -Sarcocc -i./run_arc '
    cmd  = cmd1 + cmd2
    bash(cmd,  env=ascdsenv)
#
#--- remove unwanted fits files
#
    os.system('rm *src1a*')

#--------------------------------------------------------------------------------------
#-- run_idl: process fits files with an updated idl scripts                          --
#--------------------------------------------------------------------------------------

def run_idl(dir):
    """
    process fits files with an updated idl scripts
    input:  dir --- the name of output directory
    output: dir/<stemp> --- a directory which contains the processed data
    """
#
#--- read a template and create the current command file
#
    file = bin_dir + 'house_keeping/pl_template'

    line = open(file, 'r').read()
    line = line.replace('#DIR#', dir)

    fo   = open('./mk_idl_command.pl', 'w')
    fo.write(line)
    fo.close()
#
#--- make an output directory
#
    cmd = 'mkdir /data/mta4/Gratings/' + dir
    os.system(cmd)
#
#--- run a perl script to create an idl script
#
    cmd1 = "/usr/bin/env PERL5LIB="
    cmd2 =  ' perl ./mk_idl_command.pl '
    cmd  = cmd1 + cmd2
    bash(cmd,  env=ascdsenv)
#
#--- run the idl script to process fits files
#
    os.system('idl  ./mkcommand.idl')

#--------------------------------------------------------------------------------------
#-- find_time_interval: create start and stop time and output directory name        ---
#--------------------------------------------------------------------------------------

def find_time_interval(test='NO', month=4, year=2015):
    """
    create start and stop time and output directory name
    input:  test    --- if it is test, yes. default: 'NO'
            month   --- test month input. default: 4. it is ignored if not test.
            year    --- test year input.  default: 2015. it is ignored if not test.
    output: start   --- start time in the format of mm/01/yy (e.g. 03/01/15)
            stop    --- stop time
            dir     --- output directory name in the format of <Mon><yy> (e.g. Jan15)
    """

#
#--- for the case if you want to run the test, there is option...
#
    if test == 'NO':
#
#--- this function gives you the current time. year in the format of 2015, and month in 4
#
        [year, month, day, hours, min, sec, weekday, yday, dst] = tcnv.currentTime()
#
#--- if the date is later 5th of the month, work on this month
#
    if day > 4:
        month += 1
        if month > 12:
            month = 1
            year += 1
#
#--- we need start and stop times in the formats of 03/01/15, 04/01/15
#
    year_start = year
    year_end   = year

    this_month = str(month)
    if month < 10:
        this_month = '0' + this_month

    temp_month = month -1
    if temp_month < 1:
        temp_month = 12
        year_start -= 1
    last_month = str(temp_month)
    if temp_month < 10:
        last_month = '0' + last_month

    temp       = str(year_start)
    year_start = temp[2] + temp[3]

    temp       = str(year_end)
    year_end   = temp[2] + temp[3]

    start = last_month + '/01/' + year_start
    stop  = this_month + '/01/' + year_end
#
#--- create the output directory name (format example: Apr15)
#
    cmonth = tcnv.changeMonthFormat(temp_month)
    dir    = cmonth + year_start

    return (start, stop, dir)


#--------------------------------------------------------------------------------------
#-- update_record: update the recormed of the process data                           --
#--------------------------------------------------------------------------------------

def update_record(dir):
    """
    update the recormed of the process data
    input:  none    but read from the current output directory
    outpu:  obslist in 'Angles', 'EdE', 'Focus', 'Zero' directories
    """
##
##--- find out which data are processed from the output directory
##
#    cmd = 'ls /data/mta4/Gratings/' + dir + '> ./ztemp'
#    os.system(cmd)
#    f   = open('./ztemp', 'r')
#    data = [line.strip() for line in f.readlines()]
#    f.close()
#    os.system('rm ./ztemp')
#
#    line = ''
#    for each in data:
#        line = line + '../' + dir + '/' + each + '\n'
##
##--- there are four directories with "obslist"
##
#    for odir in ('Angles', 'EdE', 'Focus', 'Zero'):
#        file =  '/data/mta/www/mta_grat/' + odir + '/obslist'
#        fo   = open(file, 'a')
#        fo.write(line)
#        fo.close()

    
    tdate = datetime.datetime.today().strftime("%Y:%m")
    atemp = re.split(':', tdate)
    tyear = int(atemp[0])
    tmon  = int(float(atemp[1]))
    
    obslist = []
    for year in range(1999, tyear+1):
        temp  = str(year)
        pyear = temp[2] + temp[3]
    
        for k in range(0, 12):
            if (year == 1999) and (k < 7):
                continue
            elif (year == tyear) and (k >= tmon):
                break
    
            month = m_list[k]
            tdir = month + pyear
            cmd = 'ls -d /data/mta_www/mta_grat/' + tdir +'/* >' +  zspace
            os.system(cmd)
            f    = open(zspace, 'r')
            data = [line.strip() for line in f.readlines()]
            f.close()
         
            for ent in data:
                atemp = re.split('\/', ent)
                try:
                    test = float(atemp[-1])
                except:
                    test = 0
                if test != 0:
                    line = '../' +  tdir + '/' + atemp[-1]
                    obslist.append(line)
    
    fo = open('./obsliist', 'w')
    for ent in obslist:
        fo.write(ent)
        fo.write('\n')
    
    fo.close()

    for odir in ('Angles', 'EdE', 'Focus', 'Zero'):
        file =  '/data/mta/www/mta_grat/' + odir + '/obslist'
        cmd  = 'cp ./obslist ' + file
        os.system(cmd)

#--------------------------------------------------------------------------------------
#---TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST----
#--------------------------------------------------------------------------------------


class TestFunctions(unittest.TestCase):
    """
    testing functions
    """

#------------------------------------------------------------

    def test_find_time_interval(self):

        out  = find_time_interval(test='YES')
        comp = ('03/01/15', '04/01/15', 'Mar15')
        self.assertEquals(out, comp)

#--------------------------------------------------------------------------------------

if __name__ == '__main__':

#
#--- if you like to run test, uncomment the next, and commend 
#--- on the main script calling
#
    #unittest.main()
    run_grating()


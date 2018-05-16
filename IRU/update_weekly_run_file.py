#!/usr/bin/env /proj/sot/ska/bin/python

#############################################################################################################
#                                                                                                           #
#           update_weekly_run_file.py: update update_plt_data.pro for the given week                        #
#           author: t. isobe (tisobe@cfa.harvard.edu)                                                       #
#                                                                                                           #
#           Last Update: Jan 05, 2018                                                                       #
#                                                                                                           #
#############################################################################################################

import sys
import os
import string
import re
import copy
import math
import unittest
import time
import random

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
#--- append path to a private folders
#
#sys.path.append(base_dir)
sys.path.append(mta_dir)

import mta_common_functions as mcf
import convertTimeFormat    as tcnv

#
#--- temp writing file name
#
rtail  = int(10000 * random.random())       #---- put a romdom # tail so that it won't mix up with other scripts space
zspace = '/tmp/zspace' + str(rtail)
#
#--- set directory paths
#
s_dir = '/data/mta4/www/DAILY/mta_pcad/IRU/Script/'
o_dir = '/data/mta4/www/DAILY/mta_pcad/IRU/'

#--------------------------------------------------------------------------------------
#-- update_weekly_run_file: update idl script: update_plt_data.pro                  ---
#--------------------------------------------------------------------------------------

def update_weekly_run_file():
    """
    update idl script: update_plt_data.pro
    input:  none, but read from ./Template/update_plt_data_template
    outpu:  updated update_plt_data.pro
    """

#
#--- find today's date information (in local time)
#
    tlist = time.localtime()
    year  = tlist[0]
    mon   = tlist[1]
    day   = tlist[2]
    wday  = tlist[6]
    yday  = tlist[7]
#
#--- find the difference to Thursday. wday starts on Monday (0)
#--- that is the ending date
#
    diff = 3 - wday
    if diff != 0:
        yday += diff
        if yday < 1:
            year -= 1
            base = find_base(year)
            yday = base - yday
        else:
            base = find_base(year)
            if yday > base:
                year += 1
                yday = yday - base
#
#--- converting the year and ydate into the standard date output
#
    [mon, day] = find_mon_day_from_ydate(year, yday)
#
#--- find starting time; assume a week ago (Thursday)
#
    start = yday - 6
    if start < 1:
        syear = year -1
        base  = find_base(syear)
        syday = 365 + start
    else:
        syear = year
        syday = start

    [smon, sday] = find_mon_day_from_ydate(syear, syday)
#
#--- set dates in a few different format
#
    dsyday = str(syday)
    if syday < 10:
        dsyday = '00' + dsyday
    elif syday < 100:
        dsyday = '0'  + dsyday

    dyday = str(yday)
    if yday < 10:
        dyday = '00' + dyday
    elif yday < 100:
        dyday = '0'  + dyday

    period = str(syear) + '_' + str(dsyday) + '_' + str(dyday)

    begin = convert_date_format(syear, smon, sday)
    end   = convert_date_format(year,  mon,  day)
#
#--- month start/stop
#
    mstart = str(syear) + '-' + str(smon) + '-01'
    if smon == 12:
        mstop = str(syear+1) + '-01-01'
    else:
        nmon = smon + 1
        lnmon = str(nmon)
        if nmon < 10:
            lnmon = '0' + lnmon
        mstop = str(syear) + '-' + lnmon + '-01'
#
#--- set mmmyy (e.g., sep15)
#
    mon = tcnv.changeMonthFormat(smon)
    tmp = str(syear)
    monyr = mon.lower() + tmp[2] + tmp[3]
#
#-- read the template
#
    file  = s_dir + 'Template/update_plt_data_template'
    f     = open(file, 'r')
    data  = f.read()
    f.close()
#
#--- substitute the dates
#
    data  = data.replace("#PERIOD#", period)
    data  = data.replace("#WSTART#", begin)
    data  = data.replace("#WSTOP#",  end)
    data  = data.replace("#MONYR#",  monyr)
    data  = data.replace("#MSTART#", mstart)
    data  = data.replace("#MSTOP#",  mstop)
    data  = data.replace("#YEAR1#",  str(syear))
    data  = data.replace("#YEAR2#",  str(syear))
    data  = data.replace("#NYEAR#",  str(syear + 1))

    #ofile = o_dir + 'update_plt_data.pro'
    ofile = 'update_plt_data_test.pro'
    fo    = open(ofile, 'w')
    fo.write(data)
    fo.close()

#--------------------------------------------------------------------------------------
#-- find_base: find how many days in a given year                                   ---
#--------------------------------------------------------------------------------------

def find_base(year):
    """
    find how many days in a given year
    input:  year    --- year in 4 digit
    outpu:  base    --- either 365 or 366 (leap year)
    """

    if tcnv.isLeapYear(year):
        base = 366
    else:
        base = 365

    return base

#--------------------------------------------------------------------------------------
#-- find_mon_day_from_ydate: find month and mday of given year and yday              --
#--------------------------------------------------------------------------------------

def find_mon_day_from_ydate(year, yday):
    """
    find month and mday of given year and yday
    input:  year    --- year
            yday    --- yday
    output: [mon, day]  --- month and mday
    """
    tline = str(year) + ' ' +str(yday)
    tlist = time.strptime(tline, "%Y %j")
    mon   = tlist[1]
    day   = tlist[2]

    return [mon, day]

#--------------------------------------------------------------------------------------
#-- convert_date_format: create yyy-mm-dd date format                                --
#--------------------------------------------------------------------------------------

def convert_date_format(year, mon, day):
    """
    create yyy-mm-dd date format
    input:  year    --- year
            mon     --- month
            day     --- day
    output: fdate   --- date in yyyy-mm-dd (e.g. 2015-09-10)
    """

    lmon  = str(mon)
    if mon < 10:
        lmon = '0' + lmon
    lday  = str(day)
    if day < 10:
        lday = '0' + lday

    fdate= str(year) + '-' + lmon + '-' + lday

    return fdate


#--------------------------------------------------------------------------------------

if __name__ == '__main__':

    update_weekly_run_file()

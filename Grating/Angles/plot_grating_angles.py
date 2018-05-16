#!/usr/bin/env /proj/sot/ska/bin/python

#################################################################################################
#                                                                                               #
#       plot_grating_angles.py: update grating angle plots                                      #
#                                                                                               #
#           author: t. isobe (tisobe@cfa.harvard.edu)                                           #
#                                                                                               #
#           last update: Apr 04, 2018                                                           #
#                                                                                               #
#################################################################################################

import os
import sys
import re
import random
import numpy
import time
import Chandra.Time

import matplotlib as mpl

if __name__ == '__main__':
    mpl.use('Agg')

sys.path.append('/data/mta/Script/Python_script2.7/')
import convertTimeFormat    as tcnv
import mta_common_functions as mcf
#
#--- temp writing file name
#
rtail  = int(time.time())
zspace = '/tmp/zspace' + str(rtail)

a_dir  = '/data/mta_www/mta_grat/Angles/'

#----------------------------------------------------------------------------------------------
#-- update_angle_data_plot: update grating angle plots                                      ---
#----------------------------------------------------------------------------------------------

def update_angle_data_plot():
    """
    update grating angle plots
    input:  none, but read from hetg_angles.txt and letg_angles.txt
    output: hetg_all_angle.png, metg_all_angle.png, letg_all_angle.png
    """
#
#--- create updated data lists
#
    cmd = 'mv ' + a_dir + 'hetg_angles.txt ' + a_dir + 'hetg_angles.txt~'
    os.system(cmd)
    cmd = 'mv ' + a_dir + 'letg_angles.txt ' + a_dir + 'letg_angles.txt~'
    os.system(cmd)

    cmd = 'cd ' + a_dir + '; ' + a_dir + 'filters_full'
    os.system(cmd)
#
#--- work on hetg and metg
#
    [time, data1, data2, data3] = read_data('./hetg_angles.txt')
    plot_data(time, data1, 'HETG', 'hetg_all_angle.png')
    plot_data(time, data2, 'METG', 'metg_all_angle.png')
#
#--- work on letg
#
    [time, data1, data2, data3] = read_data('./letg_angles.txt')
    plot_data(time, data3, 'LETG', 'letg_all_angle.png')

#----------------------------------------------------------------------------------------------
#-- plot_data: plot data                                                                     --
#----------------------------------------------------------------------------------------------

def plot_data(xdata, ydata, title, outname):
    """
    plot data
    input:  xdata   --- x data
            ydata   --- y data
            title   --- tile of the data
            outname --- output plot file; assume it is png
    output: hetg_all_angle.png, metg_all_angle.png, letg_all_angle.png
    """

    xmin = 1999
    xmax = max(xdata) 
    diff = xmax - int(xmax)
    if diff > 0.7:
        xmax = int(xmax) + 2
    else:
        xmax = int(xmax) + 1

    if title.lower() == 'hetg':
        ymin = -5.3
        ymax = -5.1
    elif title.lower() == 'metg':
        ymin =  4.5
        ymax =  5.0
    else:
        ymin = -0.5
        ymax =  0.5

    plt.close('all')

    ax  = plt.subplot(111)
    ax.set_autoscale_on(False)
    ax.set_xbound(xmin,xmax)
    ax.set_xlim(xmin=xmin, xmax=xmax, auto=False)
    ax.set_ylim(ymin=ymin, ymax=ymax, auto=False)

    plt.plot(xdata, ydata, color='blue', marker='+', markersize=6, lw=0)
    plt.xlabel('Time (year)')
    plt.ylabel('Detector Degree')

    fig = matplotlib.pyplot.gcf()
    fig.set_size_inches(10.0, 5.0)
    plt.savefig(outname, format='png')

    plt.close('all')

#----------------------------------------------------------------------------------------------
#-- read_data: read data file and extract data needed                                        --
#----------------------------------------------------------------------------------------------

def read_data(infile):
    """
    read data file and extract data needed
    input:  infile  --- input file name
    output  otime   --- a list of time in fractional year
            data1   --- a list of hetg data; it can be empty if the infile is for letg
            data2   --- a list of metg data; it can be empty if the infile is for letg
            data3   --- a list of letg data; it can be empty if the infile is for hetg
    """

    f    = open(infile, 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()

    otime = []
    data1 = []
    data2 = []
    data3 = []
    chk1  = 0
    chk2  = 0
    chk3  = 0
    chk4  = 0
    for ent in data:
        mc1  = re.search('abs_start_time', ent)
        mc2  = re.search('heg_all_angle',  ent)
        mc3  = re.search('meg_all_angle',  ent)
        mc4  = re.search('leg_all_angle',  ent)

        if mc1 is not None:
            atime = find_value(ent)
            ytime = convert_time_format(atime)
            chk1  = 1
        if mc2 is not None:
            hetg  = find_value(ent)
            chk2  = 1

        if mc3 is not None:
            metg  = find_value(ent)
            chk3  = 1

        if mc4 is not None:
            letg  = find_value(ent)
            chk4  = 1

        if (chk1 == 1) and (chk2 == 1) and (chk3 == 1):
            otime.append(ytime)
            data1.append(hetg)
            data2.append(metg)
            chk1 = 0
            chk2 = 0
            chk3 = 0
        elif (chk1 == 1) and (chk4 == 1):
            otime.append(ytime)
            data3.append(letg)
            chk1 = 0
            chk4 = 0

    return [otime, data1, data2, data3]

#----------------------------------------------------------------------------------------------
#-- find_value: find a needed value                                                          --
#----------------------------------------------------------------------------------------------

def find_value(line):
    """
    find a needed value
    input:  line    --- the line which contains the value
    output: value   --- vaoule needed
    """
    atemp = re.split(':', line)
    btemp = re.split('\+\/\-', atemp[1])
    value = float(btemp[0].strip())

    return value

#----------------------------------------------------------------------------------------------
#-- convert_time_format: convert time in seconds from 1998.1.1 to a fractional year          --
#----------------------------------------------------------------------------------------------

def convert_time_format(atime):
    """
    convert time in seconds from 1998.1.1 to a fractional year
    input:  atime   --- time in seconds from 1998.1.1
    output: otime   --- time in a fractional year
    """

    date = Chandra.Time.DateTime(atime).date

    atemp = re.split(':', date)
    year  = float(atemp[0])
    yday  = float(atemp[1])
    hh    = float(atemp[2])
    mm    = float(atemp[3])
    ss    = float(atemp[4])

    if tcnv.isLeapYear(year) == 1:
        base = 366.0
    else:
        base = 365.0


    otime = year + yday / base + hh / 24.0 + mm / 1440.0 + ss / 86400.0

    return otime

#---------------------------------------------------------------------------------------------

from pylab import *
import matplotlib.pyplot as plt
import matplotlib.font_manager as font_manager
import matplotlib.lines as lines


if __name__ == "__main__":

    update_angle_data_plot()
            

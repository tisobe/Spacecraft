#!/usr/bin/env /proj/sot/ska/bin/python

#########################################################################################################
#                                                                                                       # 
#       plot_corner_pix_trend.py: create trend plots of acis corner pixcel centroid means               #
#                                                                                                       #
#       author: t. isobe (tisobe@cfa.harvard.edu)                                                       #
#                                                                                                       #
#       last update: Jan 05, 2016                                                                       #
#                                                                                                       #
#########################################################################################################

import os
import sys
import re
import string
from time import localtime, strftime

import matplotlib as mpl

if __name__ == '__main__':

    mpl.use('Agg')

from pylab import *
import matplotlib.pyplot       as plt
import matplotlib.font_manager as font_manager
import matplotlib.lines        as lines
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
sys.path.append(bin_dir)
sys.path.append(mta_dir)
#
#--- converTimeFormat contains MTA time conversion routines
#
import convertTimeFormat    as tcnv
import mta_common_functions as mcf
import find_moving_average  as fmv
import robust_linear        as robust

ddir = '/data/mta_www/mta_acis_sci_run/Corner_pix/'
odir = '/data/mta_www/mta_acis_sci_run/Corner_pix/Trend_Plots/'
wdir = '/data/mta_www/mta_acis_sci_run/Corner_pix/'

#-----------------------------------------------------------------------------------------------
#--plot_corner_pix_trend: create trend plots of acis corner pixcel centroid means             --
#-----------------------------------------------------------------------------------------------

def plot_corner_pix_trend():
    """
    create trend plots of acis corner pixcel centroid means
    input:  none but read from data (I2cp.dat, I3cp.dat, S2cp.dat, S3cp.dat)
    output: all, faint, afaint, and vfaint trend plots of each ccds
    """

    al_slope = []
    f_slope  = []
    af_slope = []
    vf_slope = []

    for ccd in ['I2', 'I3', 'S2', 'S3']:

        file = ddir + ccd + 'cp.dat'

        [time, val, mid] = read_data(file)

        ftime = []
        fval  = []
        vtime = []
        vval  = []
        atime = []
        aval  =[]

        for j in range(0, len(time)):
            if mid[j] == 0:
                ftime.append(time[j])
                fval.append(val[j])
            elif mid[j] == 1:
                atime.append(time[j])
                aval.append(val[j])
            else:
                vtime.append(time[j])
                vval.append(val[j])
#
#--- all data points; mark special with very faint data points
#
        [xmin, xmax, ymin, ymax] = set_min_max(time, val)
        ymin      = -2
        ymax      =  2
        xname     = "Time (year)"
        yname     = "cent (ADU)"

        label = 'All Data'
        outname   = odir + ccd + 'cp.gif'
        slope = plot_single_panel(xmin, xmax, ymin, ymax, time, val, 0,   xname, yname, label, outname, linefit=1, fsize=12, pcolor=2, lcolor=3)
        al_slope.append(slope)

        label = 'Faint'
        outname   = odir + ccd + 'cp_faint.gif'
        slope = plot_single_panel(xmin, xmax, ymin, ymax, ftime, fval, 0, xname, yname, label, outname, linefit=1, fsize=12, pcolor=2, lcolor=3)
        f_slope.append(slope)

        label = 'AFaint'
        outname   = odir + ccd + 'cp_afaint.gif'
        slope = plot_single_panel(xmin, xmax, ymin, ymax, atime, aval, 0, xname, yname, label, outname, linefit=1, fsize=12, pcolor=2, lcolor=3)
        af_slope.append(slope)

        label = 'VFaint'
        outname   = odir + ccd + 'cp_vfaint.gif'
        slope = plot_single_panel(xmin, xmax, ymin, ymax, vtime, vval, 0, xname, yname, label, outname, linefit=1, fsize=12, pcolor=2, lcolor=3)
        vf_slope.append(slope)
#
#--- update web page
#
    update_web_page(al_slope, f_slope, af_slope, vf_slope)

#-----------------------------------------------------------------------------------------------
#-- read_data: read data and convert time in the fractional year                              --
#-----------------------------------------------------------------------------------------------

def read_data(file):
    """
    read data and convert time in the fractional year
    input:  file    --- file name
    output: time    --- time in fractional year
            val     --- corner pix centroid mean 
            mid     --- id of the data point. 0: faint, 1: afaint, 2: vfaint
    """

    f    = open(file, 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()

    time = []
    val  = []
    mid  = []
    for ent in data:
        atemp = re.split('\s+', ent)
#
#--- convert time in fractional year
#
        ytime = tcnv.sectoFracYear(float(atemp[0]))
        time.append(ytime)
        try:
            val.append(float(atemp[2]))
            if atemp[5] == 'AFAINT':
                mid.append(1)
            elif atemp[5] == 'VFAINT':
                mid.append(2)
            else:
                mid.append(0)
        except:
            pass

    return [time, val, mid]


#---------------------------------------------------------------------------------------------------
#-- plot_single_panel: plot a single data set on a single panel                                  ---
#---------------------------------------------------------------------------------------------------

def plot_single_panel(xmin, xmax, ymin, ymax, xdata, ydata, yerror, xname, yname, label, outname, fsize = 9, psize = 2.0, marker = 'o', pcolor =7, lcolor=7,lsize=1, resolution=100, linefit=1, connect=0):

    """
    plot a single data set on a single panel
    Input:  xmin    --- min x
            xmax    --- max x
            ymin    --- min y
            ymax    --- max y
            xdata   --- independent variable
            ydata   --- dependent variable
            yerror  --- error in y axis; if it is '0', no error bar
            xname   --- x axis label
            ynane   --- y axis label
            label   --- a text to indecate what is plotted
            outname --- the name of output file
            fsize   ---  font size, default = 9
            psize   ---  plotting point size, default = 2.0
            marker  ---  marker shape, defalut = 'o'
            pcolor  ---  color of the point, default= 7 ---> 'black'
            lcolor  ---  color of the fitted line, default = 7 ---> 'black'
                colorList = ('blue', 'red', 'green', 'aqua', 'fuchsia','lime', 'maroon', 'black', 'olive', 'yellow')
            lsize:      fitted line width, defalut = 1
            resolution-- the resolution of the plot in dpi
            linefit  --- if it is 1, fit a line estimated by robust method
            connect  --- if it is > 0, lsize data point with a line, the larger the value thinker the line
    Output: png plot named <outname>
    """
    colorList = ('blue', 'green', 'red', 'aqua', 'lime', 'fuchsia', 'maroon', 'black', 'yellow', 'olive')
#
#--- fit line --- use robust method
#
    if linefit == 1:
        (sint, slope, serr) = robust.robust_fit(xdata, ydata)
        lslope = '%2.4f' % (round(slope, 4))
#
#--- close everything opened before
#
    plt.close('all')
#
#--- set font size
#
    mpl.rcParams['font.size'] = fsize
    props = font_manager.FontProperties(size=9)
#
#--- set plotting range
#
    ax  = plt.subplot(111)
    ax.set_autoscale_on(False)
    ax.set_xbound(xmin,xmax)
    ax.set_xlim(xmin=xmin, xmax=xmax, auto=False)
    ax.set_ylim(ymin=ymin, ymax=ymax, auto=False)
#
#--- plot data
#
    plt.plot(xdata, ydata, color=colorList[pcolor], marker=marker, markersize=psize, lw = connect)
#
#--- plot error bar
#
    if yerror != 0:
        plt.errorbar(xdata, ydata, yerr=yerror, lw = 0, elinewidth=1)
#
#--- plot fitted line
#
    if linefit == 1:
        start = sint + slope * xmin
        stop  = sint + slope * xmax
        plt.plot([xmin, xmax], [start, stop], color=colorList[lcolor], lw = lsize)
#
#--- label axes
#
    plt.xlabel(xname, size=fsize)
    plt.ylabel(yname, size=fsize)
#
#--- add what is plotted on this plot
#
    xdiff = xmax - xmin
    xpos  = xmin + 0.5 * xdiff
    ydiff = ymax - ymin
    ypos  = ymax - 0.08 * ydiff

    if linefit == 1:
        label = label + ': Slope:  ' + str(lslope) + ' (delta ADU/yr)'

    plt.text(xpos, ypos, label, size=fsize)

#
#--- set the size of the plotting area in inch (width: 10.0in, height 5 in)
#
    fig = matplotlib.pyplot.gcf()
    fig.set_size_inches(10.0, 5.0)
#
#--- save the plot in png format
#
    plt.savefig(outname, format='png', dpi=resolution)

    slope = '%2.5f' % (round(slope, 5))
    return slope

#---------------------------------------------------------------------------------------------------
#-- set_min_max: set plotting range                                                              ---
#---------------------------------------------------------------------------------------------------

def set_min_max(xdata, ydata, xtime = 0, ybot = -999):

    """
    set plotting range
    Input:  xdata   ---- xdata
            ydata   ---- ydata
            xtime   ---- if it is >0, it set the plotting range from 1999 to the current in year
            ybot    ---- if it is == 0, the ymin will be 0, if the ymin computed is smaller than 0
    Output: [xmin, xmax, ymin, ymax]
    """

    xmin  = min(xdata)
    xmax  = max(xdata)
    xdiff = xmax - xmin
    xmin -= 0.1 * xdiff
    xmax += 0.2 * xdiff

    if xtime > 0:
        xmin  = 1999
        tlist = tcnv.currentTime()
        xmax  = tlist[0] + 1

    ymin  = min(ydata)
    ymax  = max(ydata)
    ydiff = ymax - ymin
    ymin -= 0.1 * ydiff
    ymax += 0.2 * ydiff

    if ybot == 0:
        if ymin < 0:
            ymin = 0

    return [xmin, xmax, ymin, ymax]

#---------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------

def update_web_page(aslope, fslope, afslope, vfslope):

    file = '/data/mta/Script/Corner_pix/Scripts/house_keeping/cpix.html'
    f    = open(file, 'r')
    text = f.read()
    f.close()

    text = text.replace('#I2_ALL#', aslope[0]) 
    text = text.replace('#I2_FIN#', fslope[0]) 
    text = text.replace('#I2_AFN#', afslope[0]) 
    text = text.replace('#I2_VFN#', vfslope[0]) 

    text = text.replace('#I3_ALL#', aslope[1]) 
    text = text.replace('#I3_FIN#', fslope[1]) 
    text = text.replace('#I3_AFN#', afslope[1]) 
    text = text.replace('#I3_VFN#', vfslope[1]) 

    text = text.replace('#S2_ALL#', aslope[2]) 
    text = text.replace('#S2_FIN#', fslope[2]) 
    text = text.replace('#S2_AFN#', afslope[2]) 
    text = text.replace('#S2_VFN#', vfslope[2]) 

    text = text.replace('#S3_ALL#', aslope[3]) 
    text = text.replace('#S3_FIN#', fslope[3]) 
    text = text.replace('#S3_AFN#', afslope[3]) 
    text = text.replace('#S3_VFN#', vfslope[3]) 

    stime = strftime("%a, %d %b %Y %H:%M:%S", localtime())

    text = text.replace('#UPDATE#', stime) 

    file = wdir + 'cpix.html'
    f    = open(file, 'w')
    f.write(text)
    f.close()
    
#----------------------------------------------------------------------------------------------------

if __name__ == "__main__":

    plot_corner_pix_trend()

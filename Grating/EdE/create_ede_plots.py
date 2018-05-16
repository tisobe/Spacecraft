#!/usr/bin/env /proj/sot/ska/bin/python

#################################################################################################
#                                                                                               #
#           create_ede_plots.py: create ede plots                                               #
#                                                                                               #
#           author: t. isobe (tisobe@cfa.harvard.edu)                                           #
#                                                                                               #
#           last update: Apr 02, 2018                                                           #
#                                                                                               #
#################################################################################################

import os
import sys
import re
import random
import numpy
import time
import Chandra.Time

#
#--- interactive plotting module
#
import mpld3
from mpld3 import plugins, utils

import matplotlib as mpl

if __name__ == '__main__':
    mpl.use('Agg')

sys.path.append('/data/mta/Script/Python_script2.7/')
import convertTimeFormat    as tcnv
import mta_common_functions as mcf
import robust_linear        as robust

#
#--- temp writing file name
#
rtail  = int(time.time())
zspace = '/tmp/zspace' + str(rtail)

a_dir  = '/data/mta_www/mta_grat/EdE/'

css = """
    p{
        text-align:left;
    }
"""

out_dir = './EdE_out/'

#----------------------------------------------------------------------------------------------
#-- plot_ede_data: create letg, metg, and hetg ede plots                                     --
#----------------------------------------------------------------------------------------------

def plot_ede_data():
    """
    create letg, metg, and hetg ede plots
    input:  none, but read from <type><side>_all.txt'
    output: <out_dir>/<type>_<side>_<start>_<stop>.png
            <out_dir>/<type>_ede_plot.html
    """

    pfile = 'hegp1_all.txt'
    mfile = 'hegm1_all.txt'
    type  = 'hetg'
    create_plot(pfile, mfile, type)

    pfile = 'megp1_all.txt'
    mfile = 'megm1_all.txt'
    type  = 'metg'
    create_plot(pfile, mfile, type)

    pfile = 'legp1_all.txt'
    mfile = 'legm1_all.txt'
    type  = 'letg'
    create_plot(pfile, mfile, type)

#----------------------------------------------------------------------------------------------
#-- create_plot: creating plots for given catgories                                          --
#----------------------------------------------------------------------------------------------

def create_plot(pfile, mfile, type):
    """
    creating plots for given catgories
    input:  pfile   --- plus side data file name
            mfile   --- minus side data file name
            type    --- type of the data letg, metg, hetg
    output: <out_dir>/<type>_<side>_<start>_<stop>.png
            <out_dir>/<type>_ede_plot.html
    """

    pdata    = read_file(pfile)
    pdata    = select_data(pdata, type)
    p_p_list = plot_each_year(pdata, type, 'p')

    mdata    = read_file(mfile)
    mdata    = select_data(mdata, type)
    m_p_list = plot_each_year(mdata, type, 'm')

    create_html_page(type, p_p_list, m_p_list)

#----------------------------------------------------------------------------------------------
#-- plot_each_year: create plots for each year for the given categories                     ---
#----------------------------------------------------------------------------------------------

def plot_each_year(tdata, type,  side):
    """
    create plots for each year for the given categories
    input:  tdata   --- a list of lists of data (see select_data below)
            type    --- a type of grating; letg, metg, hetg
            side    --- plus or mius
    """
#
#--- find the current year and group data for 5 year interval
#
    tyear   = int(float(datetime.datetime.today().strftime("%Y")))
    nstep   = int((tyear - 1999)/5) + 1
    tarray  = numpy.array(tdata[0])
    energy  = numpy.array(tdata[3])
    denergy = numpy.array(tdata[5])

    p_list  = []
    for k in range(0, nstep):
        start = 1999 + 5 * k
        stop  = start + 5
#
#--- selecting out data
#
        selec = [(tarray > start) & (tarray < stop)]
        eng   = energy[selec]
        ede   = denergy[selec]

        outfile = str(type) + '_' + str(side) + '_' + str(start) + '_' + str(stop) + '.png'
        p_list.append(outfile)

        outfile = out_dir + outfile
#
#--- actually plotting data
#
        plot_data(eng, ede, start, stop,  type, outfile)
        
    return p_list

#----------------------------------------------------------------------------------------------
#-- select_data: select out data which fit to the selection criteria                         --
#----------------------------------------------------------------------------------------------

def select_data(idata, type):

    """
    select out data which fit to the selection criteria
    input:  indata
                    idata[0]:   year    
                    idata[1]:   obsid   
                    idata[2]:   links   
                    idata[3]:   energy  
                    idata[4]:   fwhm    
                    idata[5]:   denergy 
                    idata[6]:   error   
                    idata[7]:   order   
                    idata[8]:   cnt     
                    idata[9]:   roi_cnt 
                    idata[10]:  acf     
                    idata[11]:  acf_err 
            type    --- type of the data; letg, metg, hetg
    output: out --- selected potion of the data
    """

    out = []
    for k in range(0, 12):
        out.append([])

    for m in range(0, len(idata[0])):

        if (idata[6][m] / idata[4][m] < 0.15):
#
#-- letg case
#
            if type == 'letg':
                for k in range(0, 12):
                    out[k].append(idata[k][m])
#
#--- metg case
#
            elif idata[4][m] * 1.0e3 / idata[3][m] < 5.0:
                if type == 'metg':
                    for k in range(0, 12):
                        out[k].append(idata[k][m])
#
#--- hetg case
#
                else:
                    if abs(idata[3][m] - 1.01) > 0.01:
                        for k in range(0, 12):
                            out[k].append(idata[k][m])

    return out


#----------------------------------------------------------------------------------------------
#-- read_file: read data file                                                                --
#----------------------------------------------------------------------------------------------

def read_file(infile):
    """
    read data file
    input:  infile  --- input file name
    output: a list of:
                    idata[0]:   year    
                    idata[1]:   obsid   
                    idata[2]:   links   
                    idata[3]:   energy  
                    idata[4]:   fwhm    
                    idata[5]:   denergy 
                    idata[6]:   error   
                    idata[7]:   order   
                    idata[8]:   cnt     
                    idata[9]:   roi_cnt 
                    idata[10]:  acf     
                    idata[11]:  acf_err 
    """

    f    = open(infile, 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()

    year    = []
    obsid   = []
    links   = []
    energy  = []
    fwhm    = []
    error   = []
    denergy = []
    order   = []
    cnt     = []
    roi_cnt = []
    acf     = []
    acf_err = []
    for ent in data:
        atemp = re.split('\s+', ent)
        btemp = re.split('\/', atemp[0])

        val = str(btemp[1][-2] + btemp[1][-1])
        yr    = int(float(val))

        if yr > 90:
            yr = 1900 + yr
        else:
            yr = 2000 + yr

        link = '../' + btemp[1] + '/' + btemp[2] + '/obsid_' + btemp[2] + '_Sky_summary.html'
        links.append(link)
#
#--- drop bad data
#
        if (atemp[3].lower() == 'nan') or (atemp[7].lower() == 'nan'):
            continue

        if (float(atemp[3]) < 0.0)  or (float(atemp[7]) < 0.0):
            continue

        year.append(yr)
        obsid.append(btemp[2])
        energy.append(float(atemp[3]))
        fwhm.append(float(atemp[5]))
        error.append(float(atemp[6]))
        denergy.append(float(atemp[7]))
        order.append(1)
        cnt.append(int(float(atemp[1])))
        roi_cnt.append(float(atemp[8]))
        acf.append(float(atemp[9]))
        acf_err.append(float(atemp[10]))
#
#--- a couple of data are useful as numpy array
#
    year    = numpy.array(year)
    energy  = numpy.array(energy)
    denergy = numpy.array(denergy)

    return [year, obsid, links, energy, fwhm, denergy, error, order, cnt, roi_cnt, acf, acf_err]

#----------------------------------------------------------------------------------------------
#-- plot_data: plot a data in log-log form                                                   --
#----------------------------------------------------------------------------------------------

def plot_data(x, y, start, stop, type,  outfile):
    """
    plot a data in log-log form
    input:  x       --- x data
            y       --- y data
            start   --- starting year
            stop    --- stopping year
            type    --- type of the data, letg, metg, hetg
            outfile --- output png file name
    output; outfile
    """
#
#--- set plotting range
#
    if type == 'letg':
        xmin = 0.05 
        xmax = 20.0
        ymin = 0.01
        ymax = 100000
        xpos = 2
        ypos = 15000
        ypos2 = 9000
    else:
        xmin = 0.2 
        xmax = 10.0
        ymin = 1
        ymax = 100000
        xpos = 2
        ypos = 30000
        ypos2 =18000

    plt.close('all')

    ax  = plt.subplot(111)
    ax.set_autoscale_on(False)
    ax.set_xbound(xmin,xmax)
    ax.set_xlim(xmin=xmin, xmax=xmax, auto=False)
    ax.set_ylim(ymin=ymin, ymax=ymax, auto=False)
    ax.set_xscale('log')
    ax.set_yscale('log')

    props = font_manager.FontProperties(size=24)
    mpl.rcParams['font.size']   = 24
    mpl.rcParams['font.weight'] = 'bold'
#
#--- plot data
#
    plt.plot(x, y, color='blue', marker='o', markersize=6, lw=0)
    plt.xlabel('Energy (KeV)')
    plt.ylabel('E / dE')

    text = 'Years: ' + str(start) + ' - ' + str(stop)

    plt.text(xpos, ypos, text)
#
#--- compute fitting line and plot on the scattered plot
#
    [xe, ye, a, b]  =  fit_line(x, y, xmin, xmax)
    plt.plot(xe, ye, color='red', marker='', markersize=0, lw=2)

    line = 'Slope(log-log): %2.3f' % (b)
    plt.text(xpos, ypos2, line)


    fig = matplotlib.pyplot.gcf()
    fig.set_size_inches(15.0, 10.0)

    plt.tight_layout()

    plt.savefig(outfile, format='png')

    plt.close('all')

#----------------------------------------------------------------------------------------------
#-- fit_line: fit robust fit line on the data on log-log plane                               --
#----------------------------------------------------------------------------------------------

def fit_line(x, y, xmin, xmax):
    """
    fit robust fit line on the data on log-log plane
    input:  x       --- x data
            y       --- y data
            xmin    --- min of x
            xmax    --- max of x
    """
#
#--- convert the data into log 
#
    xl = numpy.log10(x)
    yl = numpy.log10(y)
#
#--- fit a line on log-log plane with robust fit
#
    [a, b, e] = robust.robust_fit(xl, yl)
#
#--- compute plotting data points on non-log plane; it is used by the plotting routine
#
    xsave = []
    ysave = []
    step = (xmax - xmin) /100.0
    for k in range(0, 100):
        xe = xmin + step * k
        ye = 10**(a + b * math.log10(xe))
        xsave.append(xe)
        ysave.append(ye)

    return [xsave, ysave, a , b]

#----------------------------------------------------------------------------------------------
#-- create_html_page: create html page for the given type                                    --
#----------------------------------------------------------------------------------------------

def create_html_page(type, p_p_list, m_p_list):
    """
    create html page for the given type
    input:  type    --- type of data; letg, metg, hetg
            p_p_list    --- a list of plus side png plot file names
            m_p_list    --- a list of minus side png plot file names
    output: <out_dir>/<type>_ede_plot.html
    """

    if type == 'letg':
        rest = ['metg', 'hetg']
    elif type == 'metg':
        rest = ['letg', 'hetg']
    else:
        rest = ['letg', 'metg']

    line = "<!DOCTYPE html>"
    line = line + '<html>\n<head>\n\t<title>E - EdE Plot</title>\n</head>\n'
    line = line + '<body style="width:95%;margin-left:10px; margin-right;10px;'
    line = line + 'background-color:#FAEBD7;font-family:Georgia, "Times New Roman", Times, serif">\n'


    line = line + '<h2>' + type.upper() + '</h2>\n'

    line = line + '<p style="text-align:right;">\n'
    for ent in rest:
        line = line + '<a href="' + ent + '_ede_plot.html">Open: ' + ent.upper() + '</a></br>\n'
    line = line + '<a href="../index.html">Back to Main Page</a>'
    line = line + '</p>\n'

    line = line + '<table border = 0 >\n'
    line = line + '<tr><th style="width:45%;">Minus Side</th><th style="width:45%;">Plus Side</th></tr>\n'
    for k in range(0, len(p_p_list)):

        line = line + '<tr>'
        line = line + '<th style="width:45%;"><img src="' + m_p_list[k] + '" style="width:95%;"></th>'
        line = line + '<th style="width:45%;"><img src="' + p_p_list[k] + '" style="width:95%;"></th>'
        line = line + '</tr>\n'

    line = line + '</table>\n'


    line = line + '</body>\n</html>\n'

    outname = out_dir + type + '_ede_plot.html'

    fo  = open(outname, 'w')
    fo.write(line)
    fo.close()



#----------------------------------------------------------------------------------------------

from pylab import *
import matplotlib.pyplot as plt
import matplotlib.font_manager as font_manager
import matplotlib.lines as lines

if __name__ == '__main__':

    plot_ede_data()



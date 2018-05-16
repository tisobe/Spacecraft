print, "making plots ..."  ; debug
bias_plot, '2000_2003_tot_bias_1h.fits', outroot='Plots/2016_8_14', freq=3600, tstart=cxtime('2016-01-08T00:00:00','cal','sec'), tstop=cxtime('2016-01-14T00:00:00','cal','sec'), ynum=1, rnum=1
bias_plot, '2000_2003_tot_bias_1h.fits', outroot='Plots/jan16_1h', freq=3600, tstart=cxtime('2016-1-01T00:00:00','cal','sec'), tstop=cxtime('2016-02-01T00:00:00','cal','sec'), ynum=1, rnum=1
bias_plot, '2000_2003_tot_bias_1h.fits', outroot='Plots/2016', freq=3600, tstart=cxtime('2016-01-01T00:00:00','cal','sec'), tstop=cxtime('2017-01-01T00:00:00','cal','sec'), ynum=1, rnum=1
bias_plot, '2000_2003_tot_bias_1h.fits', tstart=cxtime('2000-01-01T00:00:00','cal','sec'), outroot='Plots/total_1h', freq=3600,ynum=1, rnum=1
exit

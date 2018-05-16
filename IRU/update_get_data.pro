print, "running mk_avg ..."  ; debug
mk_avg,'list_mk_avg','recent_bias_5m.fits',binsize=300
print, "running mg_avg ..."  ; debug
mg_avg,'list_mg_avg','2000_2003_tot_bias_5m.fits'
print, "running mk_avg2 ..."  ; debug
mk_avg2,'list_mk_avg2','2000_2003_tot_bias_1h.fits',binsize=3600
exit

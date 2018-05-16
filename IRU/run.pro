; testing stuff
freq=3600.0
;freq=300.0
rad2sec=360.0*60*60/(2*!pi)

;bias=mrdfits('test_bias.fits', 1)
;bias=mrdfits('2001_208_212_bias.fits', 1)
bias=mrdfits('2001_032_059_bias.fits', 1)
time=bias.time-min(bias.time)
b=where(fix(time) mod freq eq 0)
!p.multi=[0,1,3,0,0]

bias(b).aogbias1=bias(b).aogbias1*rad2sec
bias(b).aogbias2=bias(b).aogbias2*rad2sec
bias(b).aogbias3=bias(b).aogbias3*rad2sec

xmin = min(sdom(bias(b).time))
xmax = max(sdom(bias(b).time))
xmin = xmin - 0.1*(xmax-xmin)
xmax = xmax + 0.1*(xmax-xmin)

;ymin = min([bias(b).aogbias2, bias(b).aogbias3])
;ymax = max([bias(b).aogbias2, bias(b).aogbias3])
;ymin = ymin - 0.1*(ymax-ymin)
;ymax = ymax + 0.1*(ymax-ymin)

plot, sdom(bias(b).time), bias(b).aogbias1, $
      xrange=[xmin,xmax], xstyle=1, ystyle=1, $
      ytitle="Roll Bias (arcsec/sec)", charsize=2

plot, sdom(bias(b).time), bias(b).aogbias2, $
      xrange=[xmin,xmax], xstyle=1, ystyle=1, $
      ytitle="Pitch Bias (arcsec/sec)", charsize=2

plot, sdom(bias(b).time), bias(b).aogbias3, $
      xrange=[xmin,xmax], xstyle=1, ystyle=1, $
      ytitle="Yaw Bias (arcsec/sec)", xtitle="Time (DOM)", charsize=2

shift1=freq*(1.0*[bias(b).aogbias1,0]-[0,bias(b).aogbias1])/(1.0*[bias(b).time,0]-[0,bias(b).time])
shift1=shift1[1:n_elements(shift1)-2]
;print, shift1  ; debug
;print, (1.0*[bias(b).time,0]-[0,bias(b).time]) ; debug
shift2=freq*(1.0*[bias(b).aogbias2,0]-[0,bias(b).aogbias2])/(1.0*[bias(b).time,0]-[0,bias(b).time])
shift2=shift2[1:n_elements(shift2)-2]
shift3=freq*(1.0*[bias(b).aogbias3,0]-[0,bias(b).aogbias3])/(1.0*[bias(b).time,0]-[0,bias(b).time])
shift3=shift3[1:n_elements(shift3)-2]

window,2
!p.multi=[0,1,3,0,0]
bin_sz=0.001
hist1=histogram(shift1, binsize=bin_sz, omax=max1, omin=min1)
xarr1=(indgen(n_elements(hist1))*bin_sz)+min1
hist2=histogram(shift2, binsize=bin_sz, omax=max2, omin=min2)
xarr2=(indgen(n_elements(hist2))*bin_sz)+min2
hist3=histogram(shift3, binsize=bin_sz, omax=max3, omin=min3)
xarr3=(indgen(n_elements(hist3))*bin_sz)+min3
xmin = min([min3,min2,min1])
xmax = max([max3,max2,max1])
xmin = xmin - 0.1*(xmax-xmin)
xmax = xmax + 0.1*(xmax-xmin)
plot, xarr1, hist1, psym=10, charsize=2, $
      xrange=[xmin,xmax], xstyle=1, ystyle=1, $
      title=strcompress("Frequency (arcsec/"+string(freq)+"s shift)"), $
      ytitle="Roll"
plot, xarr2, hist2, psym=10, charsize=2, $
      xrange=[xmin,xmax], xstyle=1, ystyle=1, $
      ytitle="Pitch"
plot, xarr3, hist3, psym=10, charsize=2, $
      xrange=[xmin,xmax], xstyle=1, ystyle=1, $
      ytitle="Yaw", xtitle=strcompress("Bias shift over "+string(freq)+"s")

PRO BIAS_PLOT, infile, outroot=OUTROOT, freq=FREQ, $
               tstart=TSTART, tstop=TSTOP, $
               ynum=YNUM, rnum=RNUM, yper=YPER, rper=RPER, $
               plotx=PLOTX
; plot bias data and histograms of bias shifts based on freq
; optional parameters: outroot- filename root for saving gif files 
;                               (default none)
;                      freq- time in seconds to resample (default 3600)
;                      tstart- start time filter (seconds)
;                      tstop- stop time filter (seconds)
;                      ynum- set yellow limit number
;                      yper- set yellow limit percentage (overrides number)
;                      rnum- set red limit number
;                      rper- set red limit percentage (overrides number)
;                      plotx- set_plot'X' instead of default 'Z'

if (keyword_set(plotx)) then begin
  set_plot, 'X'
endif else begin
  set_plot, 'Z'
endelse

if (NOT keyword_set(freq)) then freq=3600.0
;freq=300.0
rad2sec=360.0*60*60/(2.0*!pi)

bias=mrdfits(infile, 1)
print, infile
print, n_elements(bias)
b1_avg = moment(bias.bias1*rad2sec)
b2_avg = moment(bias.bias2*rad2sec)
b3_avg = moment(bias.bias3*rad2sec)
;bias = bias(sort(bias.time))
;time=1.0*(bias.time-bias(0).time)
;b = intarr(1)
;tstart = time(0)
;for i = 1L, n_elements(time)-1 do begin
;  while (abs(time(i)-tstart) lt freq and i lt n_elements(time)-2) do begin
;    ;print, i, abs(time(i)-tstart) ;debug
;    i = i + 1
;  endwhile
;  b = [b, i-1]
;  tstart = time(i-1)
;endfor
;b=where(fix(time) mod freq eq 0)
!p.multi=[0,1,3,0,0]
if (NOT keyword_set(tstart)) then tstart=0
if (NOT keyword_set(tstop)) then tstop=max(bias.time)+1
print, tstart, tstop ; debug
b=where(bias.time ge tstart and bias.time lt tstop and $
        bias.bias1 gt -1 and bias.bias2 gt -1 and bias.bias3 gt -1 and $
        bias.bias1 lt 1e-4)
print, bias(n_elements(bias)-1).time
print, bias(n_elements(bias)-1).bias1
print, bias(n_elements(bias)-1).bias2
print, bias(n_elements(bias)-1).bias3
print, b, " b"
bias(b).bias1=bias(b).bias1*rad2sec
bias(b).bias2=bias(b).bias2*rad2sec
bias(b).bias3=bias(b).bias3*rad2sec

xmin1 = max([min(bias(b).time),49075263])
xmax1 = max(bias(b).time)
xmin = xmin1 - 0.1*(xmax1-xmin1)
xmax = xmax1 + 0.1*(xmax1-xmin1)

;ymin = min([bias(b).bias2, bias(b).bias3])
;ymax = max([bias(b).bias2, bias(b).bias3])
;ymin = ymin - 0.1*(ymax-ymin)
;ymax = ymax + 0.1*(ymax-ymin)

calmin=strsplit(cxtime(xmin1,'sec','cal'),"-", /extract)
calmax=strsplit(cxtime(xmax1,'sec','cal'),"-", /extract)
titl=strcompress("GYRO BIAS DRIFT "+string(calmin(0))+string(calmin(1))+ $
                  " - "+string(calmax(0))+string(calmax(1)))

nticks=7
doyticks = pick_doy_ticks(xmin1,xmax1,num=nticks)
nticks=n_elements(doyticks)

bias_all=bias
bias=bias_all(b)
m=moment(bias.bias1)
b=where(abs(bias.bias1-m(0)) lt 3*sqrt(m(1)))
b1_avg=moment(bias(b).bias1)

ymin=min(bias(b).bias1)
ymax=max(bias(b).bias1)
yrange=ymax-ymin
ymin=ymin-(0.15*yrange)
ymax=ymax+(0.06*yrange)
plot, bias(b).time, bias(b).bias1, $
      yrange=[ymin,ymax],xrange=[xmin,xmax], xstyle=1, ystyle=1, $
      ytitle="Roll Bias (arcsec/sec)", charsize=1.5, $
      title=titl, $
      xticks=nticks-1, xtickv = doyticks, xminor=5, $
      xtickformat='s2doy_axis_labels'
xyouts, !X.CRANGE(1)-(0.1*(!X.CRANGE(1)-!X.CRANGE(0))), $
        !Y.CRANGE(0)+(0.07*(!Y.CRANGE(1)-!Y.CRANGE(0))), $
        strcompress("Mean: "+string(b1_avg(0))+ $
                    " std dev: "+string(sqrt(b1_avg(1)))), alignment=1.0

m=moment(bias.bias2)
b=where(abs(bias.bias2-m(0)) lt 15*sqrt(m(1)))
b2_avg=moment(bias(b).bias2)
ymin=min(bias(b).bias2)
ymax=max(bias(b).bias2)
yrange=ymax-ymin
ymin=ymin-(0.15*yrange)
ymax=ymax+(0.06*yrange)
plot, bias(b).time, bias(b).bias2, $
      yrange=[ymin,ymax],xrange=[xmin,xmax], xstyle=1, ystyle=1, $
      ytitle="Pitch Bias (arcsec/sec)", charsize=1.5, $
      xticks=nticks-1, xtickv = doyticks, xminor=5, $
      xtickformat='s2doy_axis_labels'
xyouts, !X.CRANGE(1)-(0.1*(!X.CRANGE(1)-!X.CRANGE(0))), $
        !Y.CRANGE(0)+(0.07*(!Y.CRANGE(1)-!Y.CRANGE(0))), $
        strcompress("Mean: "+string(b2_avg(0))+ $
                    " std dev: "+string(sqrt(b2_avg(1)))), alignment=1.0

m=moment(bias.bias3)
b=where(abs(bias.bias3-m(0)) lt 15*sqrt(m(1)))
b3_avg=moment(bias(b).bias3)
ymin=min(bias(b).bias3)
ymax=max(bias(b).bias3)
yrange=ymax-ymin
ymin=ymin-(0.15*yrange)
ymax=ymax+(0.06*yrange)
plot, bias(b).time, bias(b).bias3, $
      yrange=[ymin,ymax],xrange=[xmin,xmax], xstyle=1, ystyle=1, $
      ytitle="Yaw Bias (arcsec/sec)", xtitle="Time (DOY)", charsize=1.5, $
      xticks=nticks-1, xtickv = doyticks, xminor=5, $
      xtickformat='s2doy_axis_labels'
xyouts, !X.CRANGE(1)-(0.1*(!X.CRANGE(1)-!X.CRANGE(0))), $
        !Y.CRANGE(0)+(0.07*(!Y.CRANGE(1)-!Y.CRANGE(0))), $
        strcompress("Mean: "+string(b3_avg(0))+ $
                    " std dev: "+string(sqrt(b3_avg(1)))), alignment=1.0
ycon = convert_coord([0],[0], /device, /to_data)
label_year, xmin1, xmax1, ycon(1), csize=1.2

if (keyword_set(outroot)) then write_gif, outroot+'_bias.gif', tvrd()

shift1=freq*(1.0*[bias(b).bias1,0]-[0,bias(b).bias1])/(1.0*[bias(b).time,0]-[0,bias(b).time])
shift1=shift1[1:n_elements(shift1)-2]
;print, shift1  ; debug
;print, (1.0*[bias(b).time,0]-[0,bias(b).time]) ; debug
shift2=freq*(1.0*[bias(b).bias2,0]-[0,bias(b).bias2])/(1.0*[bias(b).time,0]-[0,bias(b).time])
shift2=shift2[1:n_elements(shift2)-2]
shift3=freq*(1.0*[bias(b).bias3,0]-[0,bias(b).bias3])/(1.0*[bias(b).time,0]-[0,bias(b).time])
shift3=shift3[1:n_elements(shift3)-2]

if (keyword_set(plotx)) then window,2
!p.multi=[0,1,3,0,0]
bin_sz=0.0001
;print, n_elements(shift1) ;debug
hist1=histogram(shift1, binsize=bin_sz, omax=max1, omin=min1)
xarr1=(indgen(n_elements(hist1))*bin_sz)+min1
hist2=histogram(shift2, binsize=bin_sz, omax=max2, omin=min2)
xarr2=(indgen(n_elements(hist2))*bin_sz)+min2
hist3=histogram(shift3, binsize=bin_sz, omax=max3, omin=min3)
xarr3=(indgen(n_elements(hist3))*bin_sz)+min3
;xmin = min([min3,min2,min1])
;xmax = max([max3,max2,max1])
;xmin = xmin - 0.1*(xmax-xmin)
;xmax = xmax + 0.1*(xmax-xmin)
xmin = -0.003
xmax = 0.003
ymin = 0.5
ymax = max([hist1,hist2, hist3])*1.1
xmin = min1 - 0.1*(max1-min1)
xmax = max1 + 0.1*(max1-min1)
plot, xarr1(1:n_elements(xarr1)-2), hist1(1:n_elements(xarr1)-2), psym=10, charsize=2, $
      xrange=[xmin,xmax], xstyle=1, ystyle=1, $
      yrange=[ymin,ymax], /ylog, $
      title=strcompress("Frequency (arcsec/"+string(freq)+"s shift)"), $
      ytitle="Roll"
xmin = min2 - 0.1*(max2-min2)
xmax = max2 + 0.1*(max2-min2)
plot, xarr2(1:n_elements(xarr2)-2), hist2(1:n_elements(xarr2)-2), psym=10, charsize=2, $
      xrange=[xmin,xmax], xstyle=1, ystyle=1, $
      yrange=[ymin,ymax], /ylog, $
      ytitle="Pitch"

;print, xarr3, hist3 ; debug
;print, (1.0*[bias(b).bias3,0]-[0,bias(b).bias3]) ; debug
;print, (1.0*[bias(b).time,0]-[0,bias(b).time]) ; debug

xmin = min3 - 0.1*(max3-min3)
xmax = max3 + 0.1*(max3-min3)
plot, xarr3(1:n_elements(xarr3)-2), hist3(1:n_elements(xarr3)-2), psym=10, charsize=2, $
      xrange=[xmin,xmax], xstyle=1, ystyle=1, $
      yrange=[ymin,ymax], /ylog, $
      ytitle="Yaw", xtitle=strcompress("Bias drift shift over "+string(freq)+"s")
if (keyword_set(outroot)) then write_gif, outroot+'_hist.gif', tvrd()

; make cumulative plots
;;chistwindow,3
;;chist!p.multi=[0,1,3,0,0]
;;chist;xmin = min([min3,min2,min1])
;;chist;xmax = max([max3,max2,max1])
;;chist;xmin = xmin - 0.1*(xmax-xmin)
;;chist;xmax = xmax + 0.1*(xmax-xmin)
;;chistxmin=-0.005
;;chistxmax=0.005
;;chistymin = 0
;;chistymax = 1
;;chistcplot=cumul(hist1)
;;chistplot, xarr1, 1.0*cplot/max(cplot), psym=10, charsize=2, $
;;chist      xrange=[xmin,xmax], xstyle=1, ystyle=1, $
;;chist      yrange=[ymin,ymax], $
;;chist      title=strcompress("Cumulative Frequency (arcsec/"+string(freq)+"s shift)"), $
;;chist      ytitle="Roll"
;;chistcplot=cumul(hist2)
;;chistplot, xarr2, 1.0*cplot/max(cplot), psym=10, charsize=2, $
;;chist      xrange=[xmin,xmax], xstyle=1, ystyle=1, $
;;chist      yrange=[ymin,ymax], $
;;chist      ytitle="Pitch"
;;chistcplot=cumul(hist3)
;;chistplot, xarr3, 1.0*cplot/max(cplot), psym=10, charsize=2, $
;;chist      xrange=[xmin,xmax], xstyle=1, ystyle=1, $
;;chist      yrange=[ymin,ymax], $
;;chist      ytitle="Yaw", xtitle=strcompress("Bias shift over "+string(freq)+"s")
;;chistif (keyword_set(outroot)) then write_gif, outroot+'_chist.gif', tvrd()

if (keyword_set(plotx)) then wset, 0

; find con intervals
yel_num=lonarr(2)
red_num=lonarr(2)
base_num=n_elements(shift1)

if (keyword_set(ynum)) then yel_num[0]=ynum $
  else yel_num[0]=fix(base_num*0.01)
if (keyword_set(rnum)) then red_num[0]=rnum $
  else red_num[0]=fix(base_num*0.005)
if (keyword_set(yper)) then yel_num[0]=fix(base_num*yper/100)
if (keyword_set(rper)) then red_num[0]=fix(base_num*rper/100)

yel_num[1]=base_num-yel_num[0]
red_num[1]=base_num-red_num[0]

print, strcompress("Red limits at top/bottom "+string(red_num[0])+" samples.")
print, strcompress("Red limits at top/bottom "+string(100.0*red_num[0]/base_num)+" percent.")
print, strcompress("Yellow limits at top/bottom "+string(yel_num[0])+" samples.")
print, strcompress("Yellow limits at top/bottom "+string(100.0*yel_num[0]/base_num)+" percent.")

s = sort(abs(shift1))
abs_lim = abs(shift1(s(red_num[1])))
maxr = where(shift1 ge abs_lim)
if (maxr(0) gt -1) then begin
  max_r = min(shift1(maxr))
endif else max_r = 99
minr = where(shift1 le -1.0*abs_lim)
if (minr(0) gt -1) then begin
  min_r = max(shift1(minr))
endif else min_r = -99
abs_lim = abs(shift1(s(yel_num[1])))
maxy = where(shift1 ge abs_lim)
if (maxy(0) gt -1) then begin
  max_y = min(shift1(maxy))
endif else max_y = 99
miny = where(shift1 le -1.0*abs_lim)
if (miny(0) gt -1) then begin
  min_y = max(shift1(miny))
endif else min_y = -99

;print, abs_lim ; debug
;print, shift1(maxr) ; debug
;print, shift1(minr) ; debug

print, strcompress("Roll lower red: "+string(min_r))
print, strcompress("Roll lower yellow: "+string(min_y))
print, strcompress("Roll upper yellow: "+string(max_y))
print, strcompress("Roll upper red: "+string(max_r))
ralert=where(shift1 le min_r or shift1 ge max_r)
yalert=where(shift1 le min_y or shift1 ge max_y)
for i=0,n_elements(ralert)-1 do begin
  print, "RED "+cxtime(bias(b(ralert(i))).time, 'sec', 'cal')+" "+string(shift1(ralert(i)))
endfor
for i=0,n_elements(yalert)-1 do begin
  print, "YELLOW "+cxtime(bias(b(yalert(i))).time, 'sec', 'cal')+" "+string(shift1(yalert(i)))
endfor
s = sort(abs(shift2))
abs_lim = abs(shift2(s(red_num[1])))
maxr = where(shift2 ge abs_lim)
if (maxr(0) gt -1) then begin
  max_r = min(shift2(maxr))
endif else max_r = 99
minr = where(shift2 le -1.0*abs_lim)
if (minr(0) gt -1) then begin
  min_r = max(shift2(minr))
endif else min_r = -99
abs_lim = abs(shift2(s(yel_num[1])))
maxy = where(shift2 ge abs_lim)
if (maxy(0) gt -1) then begin
  max_y = min(shift2(maxy))
endif else max_y = 99
miny = where(shift2 le -1.0*abs_lim)
if (miny(0) gt -1) then begin
  min_y = max(shift2(miny))
endif else min_y = -99
print, strcompress("PITCH lower red: "+string(min_r))
print, strcompress("PITCH lower yellow: "+string(min_y))
print, strcompress("PITCH upper yellow: "+string(max_y))
print, strcompress("PITCH upper red: "+string(max_r))
ralert=where(shift2 le min_r or shift2 ge max_r)
yalert=where(shift2 le min_y or shift2 ge max_y)
for i=0,n_elements(ralert)-1 do begin
  print, "RED "+cxtime(bias(b(ralert(i))).time, 'sec', 'cal')+" "+string(shift2(ralert(i)))
endfor
for i=0,n_elements(yalert)-1 do begin
  print, "YELLOW "+cxtime(bias(b(yalert(i))).time, 'sec', 'cal')+" "+string(shift2(yalert(i)))
endfor
s = sort(abs(shift3))
abs_lim = abs(shift3(s(red_num[1])))
maxr = where(shift3 ge abs_lim)
if (maxr(0) gt -1) then begin
  max_r = min(shift3(maxr))
endif else max_r = 99
minr = where(shift3 le -1.0*abs_lim)
if (minr(0) gt -1) then begin
  min_r = max(shift3(minr))
endif else min_r = -99
abs_lim = abs(shift3(s(yel_num[1])))
maxy = where(shift3 ge abs_lim)
if (maxy(0) gt -1) then begin
  max_y = min(shift3(maxy))
endif else max_y = 99
miny = where(shift3 le -1.0*abs_lim)
if (miny(0) gt -1) then begin
  min_y = max(shift3(miny))
endif else min_y = -99
print, strcompress("YAW lower red: "+string(min_r))
print, strcompress("YAW lower yellow: "+string(min_y))
print, strcompress("YAW upper yellow: "+string(max_y))
print, strcompress("YAW upper red: "+string(max_r))
ralert=where(shift3 le min_r or shift3 ge max_r)
yalert=where(shift3 le min_y or shift3 ge max_y)
for i=0,n_elements(ralert)-1 do begin
  print, "RED "+cxtime(bias(b(ralert(i))).time, 'sec', 'cal')+" "+string(shift3(ralert(i)))
endfor
for i=0,n_elements(yalert)-1 do begin
  print, "YELLOW "+cxtime(bias(b(yalert(i))).time, 'sec', 'cal')+" "+string(shift3(yalert(i)))
endfor

end

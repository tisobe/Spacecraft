pro cpix, evtlist, PLOTX=plotx, HIST=hist, TEST=test
; make corner pixel centroid plots
; set plotx to set_plot, 'x' (set_plot, 'Z' ids default)
; set hist to save examples of histograms and fits
; set test to NOT write data files

; how many frames in a bin ?
binsize = 75

; root for output data file
namroot = strmid(evtlist, strpos(evtlist, "acisf"), 10)
outroot = "cp.dat"
obsid = strmid(evtlist, strpos(evtlist, "acis")+5, 5)

if (keyword_set(plotx)) then begin
  set_plot, 'X'
  window, 0, xsize=700, ysize=600
endif else begin
  set_plot, 'Z'
  device, set_resolution = [700, 600]
endelse

print, evtlist

data = mrdfits(evtlist, 1)

data = data(where(data.grade eq 0 or data.grade eq 2 or data.grade eq 3 or $
                  data.grade eq 4 or data.grade eq 6))

;data = data(where(data.grade eq 1 or data.grade eq 5 or data.grade eq 7))
;data = data(where(data.status eq 0))
;data = data(where(data.status ne 0))

if (n_elements(data(0).phas) eq 9) then begin
  cpixels=[0,2,6,8]
  apixels=[-1]
  print, 'This is FAINT MODE data'
  mode = "FAINT"
endif else begin
  cpixels=[0,1,2,3,4,5,6,8,9,10,14,15,16,18,19,20,21,22,23,24]
  apixels=[6,8,16,18]
  print, 'This is VERY FAINT MODE data'
  mode = "VFAINT"
  cpix_afaint, evtlist, /hist
endelse

ccds = [2,3,6,7]
ccd_id = ["I2", "I3", "S2", "S3"]

; struct to save centroids
size = ((max(data.expno)-min(data.expno))/binsize)+1
z = {xvals: make_array(size, /float, value=-1 ), $
      cent: make_array(size, /float, value=999), $
      width: make_array(size, /float, value=999)}
data_struct = replicate(z, n_elements(ccds))

for i = 0, n_elements(ccds)-1 do begin
  a = where(data.ccd_id eq ccds(i))
  if (n_elements(a) gt 1) then begin
    tmp = data(a) 
    minexpo = min(tmp.expno)
    maxexpo = max(tmp.expno)

    ;expu=tmp(uniq(tmp.expno)).expno
    print, "Working CCD", ccds(i)
    print, "N events ", n_elements(data)
    print, "N expno ", maxexpo-minexpo
    cent = fltarr(1)
    xvals = fltarr(1)
    width = fltarr(1)
    k = 0 ; bin skip counter - reset after each hist plotted
    m = 0 ; bin counter
    j = minexpo
    !P.MULTI = [0, 4, 4, 0, 0]
    while (j lt maxexpo) do begin
      k = k + 1
      m = m + 1
      ;print, "Working on expno ", j ;debug
      b = where(tmp.expno ge j and tmp.expno lt j + binsize)
      ;print, n_elements(b) ;debug
      list = tmp(b).phas(cpixels)
      freq = histogram(list)
      xlist = min(list)+indgen(n_elements(freq))
      ;yfit = gaussfit(xlist, freq, coeff)
      yfit = gaussfit(xlist, freq, coeff, nterms=3)
      ;maxg = where(yfit eq max(yfit))
      if (n_elements(b) ge 3) then begin
        xave = moment(tmp(b).expno)
      endif else begin
        xave=[0,0]
      endelse
      xvals = [xvals, xave(0)]
      ;cent = [cent, xlist(maxg(0))]
      cent = [cent, coeff(1)]
      width = [width,coeff(2)]

      if (k eq fix((maxexpo-minexpo)/16/binsize)+1) then begin
        print, "   Done expno ", j, " of ", maxexpo
        xmin = min(xlist(where(freq gt 0.1*max(freq))))
        xmax = max(xlist(where(freq gt 0.1*max(freq))))
        if (keyword_set(hist)) then begin
          plot, xlist, freq, psym=10, xstyle=1, $
                ;xrange=[coeff(1)-10, coeff(1)+10], $
                xrange=[xmin, xmax], $
                title=strcompress(ccd_id[i]+"  BIN: "+string(m))
          oplot, xlist, yfit
          oplot, [coeff(1), coeff(1)], [0,0], psym=2
         endif
        k = 0
      endif

      j = j + binsize
    endwhile
    if (keyword_set(hist)) then begin
      write_gif, strcompress(namroot+'_'+ccd_id[i]+'hist.gif', /remove_all), $
                 tvrd()
    endif
    ; save for below
    data_struct(i).cent=cent[1:*]
    data_struct(i).xvals=xvals[1:*]
    data_struct(i).width=width[1:*]
  endif
endfor

!P.MULTI = [0, 1, 4, 0, 0]
for i = 0, n_elements(ccds)-1 do begin
  a = where(data.ccd_id eq ccds(i))
  if (n_elements(a) gt 1) then begin
    xvals = data_struct(i).xvals(where(data_struct(i).xvals ge 0))
    cent = data_struct(i).cent(where(data_struct(i).cent lt 999))
    width = data_struct(i).width(where(data_struct(i).width lt 999))
    plot, xvals, cent, psym=4, charsize=1.8, $
          xtitle = "Frame", ytitle="Corner Pix Centroid", $
          title=evtlist+"  "+ccd_id[i]+"  "+mode
    ; update data file
    if (not keyword_set(test)) then begin
      get_lun, ounit
      openw, ounit, strcompress(ccd_id[i]+outroot, /remove_all), /append
      print, m, n_elements(xvals), n_elements(cent), maxexpo-minexpo ;debug

      fit = svdfit(xvals, cent, 2)
      spread = moment(cent)
      wspread = moment(width)

      ; get rid of outliers
      b = where(abs(cent-spread(0)) lt abs(spread(0))+3*sqrt(spread(1)))
      spread = moment(cent(b))

      printf, ounit, strcompress(string(data(0).time)+" "+ $
                     string(fit(1))+" "+ $
                     string(spread(0))+" "+ $
                     string(sqrt(spread(1)))+" "+ $
                     string(obsid)+" "+ $
                     mode+" "+ $
                     string(wspread(0))+" "+ $
                     string(sqrt(wspread(1))))
      ;printf, ounit, data(0).time, " ", fit(1), " ", $
                     ;spread(0), " ", sqrt(spread(1)), " ", $
                     ;obsid, " ", mode
      free_lun, ounit
    endif ; (not keyword_set(test))

  endif else begin ; if (n_elements(a) gt 1)
    plot, [0, 1], [0, 0], charsize=1.8, xrange=[0,1], yrange=[0,1], $
          xstyle=1, ystyle=1, $
          title=evtlist+"  "+ccd_id[i]+"  "+mode
    xyouts, 0.5, 0.5, "N/A", /data
  endelse
endfor
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 255, /normal
write_gif, strcompress(namroot+'cp.gif', /remove_all), tvrd() 
retall

;if (mode eq "VFAINT") then begin
  ;cpix_afaint, evtlist, /hist
;endif

end

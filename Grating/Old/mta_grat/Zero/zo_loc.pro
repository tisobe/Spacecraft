PRO zo_loc

; ACIS_HETG
; figure num lines input
xnum = strarr(1)
spawn, 'wc -l zo_acis_hetg.txt', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'zo_acis_hetg.txt'

array = strarr(numlns)
readf, inunit, array
free_lun, inunit

numobs = numlns/6
times = fltarr(numobs)
xsky = fltarr(numobs)
ysky = fltarr(numobs)
xchip = fltarr(numobs)
ychip = fltarr(numobs)

j = -1
for i = 0, numlns - 1, 6 do begin
  j = j + 1
  tmp = strarr(2)
  tmp = strsplit(array(i+1), ':', /extract)
  tmp1 = strsplit(tmp(1), '\+\/\-', /extract, /regex)
  times(j) = float(tmp1(0))
  tmp = strsplit(array(i+2), ':', /extract)
  tmp1 = strsplit(tmp(1), '+', /extract) 
  xsky(j) = float(tmp1(0))
  tmp = strsplit(array(i+3), ':', /extract)
  tmp1 = strsplit(tmp(1), '+', /extract) 
  ysky(j) = float(tmp1(0))
  tmp = strsplit(array(i+4), ':', /extract)
  tmp1 = strsplit(tmp(1), '+', /extract) 
  xchip(j) = float(tmp1(0))
  tmp = strsplit(array(i+5), ':', /extract)
  tmp1 = strsplit(tmp(1), '+', /extract) 
  ychip(j) = float(tmp1(0))
endfor

plot, sdom(times), xsky, psym = 2, $
      title = 'ACIS_HETG_XSKY Zero Order', $
      xtitle = 'time (DOM)', ytitle = 'Sky X Position', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 1.5, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'zo_acis_hetg_xsky.gif', tvrd()

plot, sdom(times), ysky, psym = 2, $
      title = 'ACIS_HETG_YSKY Zero Order', $
      xtitle = 'time (DOM)', ytitle = 'Sky Y Position', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 1.5, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'zo_acis_hetg_ysky.gif', tvrd()

plot, sdom(times), xchip, psym = 2, $
      title = 'ACIS_HETG_XCHIP Zero Order', $
      xtitle = 'time (DOM)', ytitle = 'Chip X Position', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 1.5, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'zo_acis_hetg_xchip.gif', tvrd()

plot, sdom(times), ychip, psym = 2, $
      title = 'ACIS_HETG_YCHIP Zero Order', $
      xtitle = 'time (DOM)', ytitle = 'Chip Y Position', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 1.5, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'zo_acis_hetg_ychip.gif', tvrd()

; ACIS_LETG
; figure num lines input
xnum = strarr(1)
spawn, 'wc -l zo_acis_letg.txt', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'zo_acis_letg.txt'

array = strarr(numlns)
readf, inunit, array
free_lun, inunit

numobs = numlns/6
times = fltarr(numobs)
xsky = fltarr(numobs)
ysky = fltarr(numobs)
xchip = fltarr(numobs)
ychip = fltarr(numobs)

j = -1
for i = 0, numlns - 1, 6 do begin
  j = j + 1
  tmp = strarr(2)
  tmp = strsplit(array(i+1), ':', /extract)
  tmp1 = strsplit(tmp(1), '\+\/\-', /extract, /regex)
  times(j) = float(tmp1(0))
  tmp = strsplit(array(i+2), ':', /extract)
  tmp1 = strsplit(tmp(1), '+', /extract) 
  xsky(j) = float(tmp1(0))
  tmp = strsplit(array(i+3), ':', /extract)
  tmp1 = strsplit(tmp(1), '+', /extract) 
  ysky(j) = float(tmp1(0))
  tmp = strsplit(array(i+4), ':', /extract)
  tmp1 = strsplit(tmp(1), '+', /extract) 
  xchip(j) = float(tmp1(0))
  tmp = strsplit(array(i+5), ':', /extract)
  tmp1 = strsplit(tmp(1), '+', /extract) 
  ychip(j) = float(tmp1(0))
endfor

plot, sdom(times), xsky, psym = 2, $
      title = 'ACIS_LETG_XSKY Zero Order', $
      xtitle = 'time (DOM)', ytitle = 'Sky X Position', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 1.5, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'zo_acis_letg_xsky.gif', tvrd()

plot, sdom(times), ysky, psym = 2, $
      title = 'ACIS_LETG_YSKY Zero Order', $
      xtitle = 'time (DOM)', ytitle = 'Sky Y Position', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 1.5, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'zo_acis_letg_ysky.gif', tvrd()

plot, sdom(times), xchip, psym = 2, $
      title = 'ACIS_LETG_XCHIP Zero Order', $
      xtitle = 'time (DOM)', ytitle = 'Chip X Position', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 1.5, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'zo_acis_letg_xchip.gif', tvrd()

plot, sdom(times), ychip, psym = 2, $
      title = 'ACIS_LETG_YCHIP Zero Order', $
      xtitle = 'time (DOM)', ytitle = 'Chip Y Position', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 1.5, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'zo_acis_letg_ychip.gif', tvrd()

; HRC_LETG
; figure num lines input
xnum = strarr(1)
spawn, 'wc -l zo_hrc_letg.txt', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'zo_hrc_letg.txt'

array = strarr(numlns)
readf, inunit, array
free_lun, inunit

numobs = numlns/6
times = fltarr(numobs)
xsky = fltarr(numobs)
ysky = fltarr(numobs)
xchip = fltarr(numobs)
ychip = fltarr(numobs)

j = -1
for i = 0, numlns - 1, 6 do begin
  j = j + 1
  tmp = strarr(2)
  tmp = strsplit(array(i+1), ':', /extract)
  tmp1 = strsplit(tmp(1), '\+\/\-', /extract, /regex)
  times(j) = float(tmp1(0))
  tmp = strsplit(array(i+2), ':', /extract)
  tmp1 = strsplit(tmp(1), '+', /extract) 
  xsky(j) = float(tmp1(0))
  tmp = strsplit(array(i+3), ':', /extract)
  tmp1 = strsplit(tmp(1), '+', /extract) 
  ysky(j) = float(tmp1(0))
  tmp = strsplit(array(i+4), ':', /extract)
  tmp1 = strsplit(tmp(1), '+', /extract) 
  xchip(j) = float(tmp1(0))
  tmp = strsplit(array(i+5), ':', /extract)
  tmp1 = strsplit(tmp(1), '+', /extract) 
  ychip(j) = float(tmp1(0))
endfor

plot, sdom(times), xsky, psym = 2, $
      title = 'HRC_LETG_XSKY Zero Order', $
      xtitle = 'time (DOM)', ytitle = 'Sky X Position', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 1.5, charthick =2, min_value=32000, max_value=34000
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'zo_hrc_letg_xsky.gif', tvrd()

plot, sdom(times), ysky, psym = 2, $
      title = 'HRC_LETG_YSKY Zero Order', $
      xtitle = 'time (DOM)', ytitle = 'Sky Y Position', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 1.5, charthick =2,min_value=-34000, max_value=-32000
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'zo_hrc_letg_ysky.gif', tvrd()

plot, sdom(times), xchip, psym = 2, $
      title = 'HRC_LETG_XCHIP Zero Order', $
      xtitle = 'time (DOM)', ytitle = 'Chip X Position', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 1.5, charthick =2,min_value=1900, max_value=2600
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'zo_hrc_letg_xchip.gif', tvrd()

plot, sdom(times), ychip, psym = 2, $
      title = 'HRC_LETG_YCHIP Zero Order', $
      xtitle = 'time (DOM)', ytitle = 'Chip Y Position', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 1.5, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'zo_hrc_letg_ychip.gif', tvrd()

end

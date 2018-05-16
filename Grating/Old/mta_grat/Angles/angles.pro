PRO angles

; HETG ANGLES
; figure num lines input
xnum = strarr(1)
spawn, 'wc -l hetg_angles.txt', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'hetg_angles.txt'

array = strarr(numlns)
readf, inunit, array
free_lun, inunit

numobs = numlns/4
hetg_times = fltarr(numobs)
metg_times = fltarr(numobs)
heg_angle = fltarr(numobs)
meg_angle = fltarr(numobs)

j = -1
for i = 0, numlns - 1, 4 do begin
print,i
  j = j + 1
  tmp = strarr(2)
  tmp = strsplit(array(i+1), ':', /extract)
  if (strmatch(tmp(0),'*obsid*')) then begin
    j=-1 
    continue
  endif
  tmp1 = strsplit(tmp(1), '\+\/\-', /extract, /regex) 
  hetg_times(j) = long(float(tmp1(0)))
  ; print, hetg_times(j)
  tmp = strsplit(array(i+2), ':', /extract)
  print, tmp(0)
  if (strmatch(tmp(0),'*obsid*')) then begin
    j=-1 
    continue
  endif
  tmp1 = strsplit(tmp(1), '+', /extract) 
  heg_angle(j) = float(tmp1(0))
  tmp = strsplit(array(i+3), ':', /extract)
  if (strmatch(tmp(0),'*obsid*')) then begin
    j=-1 
    continue
  endif
  tmp1 = strsplit(tmp(1), '+', /extract) 
  meg_angle(j) = float(tmp1(0))
endfor

metg_times = hetg_times
plot, sdom(hetg_times), heg_angle, psym = 2, $
      title = 'HEG_ALL_ANGLE', $
      xtitle = 'time (DOM)', ytitle = 'Detector degrees', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 2, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'heg_all_angle.gif', tvrd()

plot, sdom(metg_times), meg_angle, psym = 2, $
      title = 'MEG_ALL_ANGLE', $
      xtitle = 'time (DOM)', ytitle = 'Detector degrees', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 2, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'meg_all_angle.gif', tvrd()

; LETG ANGLES
; figure num lines input
xnum = strarr(1)
spawn, 'wc -l letg_angles.txt', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'letg_angles.txt'

array = strarr(numlns)
readf, inunit, array
free_lun, inunit

numobs = numlns/3
letg_times = long(fltarr(numobs))
leg_angle = fltarr(numobs)

j = -1
for i = 0, numlns - 1, 3 do begin
  j = j + 1
  tmp = strarr(2)
  tmp = strsplit(array(i+1), ':', /extract)
  tmp1 = strsplit(tmp(1), '\+\/\-', /extract, /regex) 
  letg_times(j) = float(tmp1(0))
  tmp = strsplit(array(i+1), ':', /extract)
  print, i, tmp(0)
  if (strmatch(tmp(0),'*obsid*')) then begin
    j=-1 
    continue
  endif
  tmp = strsplit(array(i+2), ':', /extract)
  if (strmatch(tmp(0),'*obsid*')) then begin
    j=-1 
    continue
  endif
  tmp1 = strsplit(tmp(1), '+', /extract) 
  leg_angle(j) = float(tmp1(0))
endfor

plot, sdom(letg_times), leg_angle, psym = 2, $
      title = 'LEG_ALL_ANGLE', $
      xtitle = 'time (DOM)', ytitle = 'Detector degrees', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 2, charthick =2, yrange=[-1,1]
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, 'leg_all_angle.gif', tvrd()

; summary
get_lun, sunit
openw, sunit, 'angles.out'

printf, sunit, 'HETG'
for i = 0, n_elements(hetg_times)-1 do begin
  printf, sunit, sdom(hetg_times(i)), ' ', heg_angle(i)
endfor

printf, sunit, 'METG'
for i = 0, n_elements(metg_times)-1 do begin
  printf, sunit, sdom(metg_times(i)), ' ', meg_angle(i)
endfor

printf, sunit, 'LETG'
for i = 0, n_elements(letg_times)-1 do begin
  printf, sunit, sdom(letg_times(i)), ' ', leg_angle(i)
endfor

free_lun, sunit

end

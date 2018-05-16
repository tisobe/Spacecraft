PRO OFFSET
; This program considers the intended offset of gratings observations
;  and plots essentially th epointing error based on zero order location

; ********************* read Zero obslist and filter bad data ********
; figure num lines input
;  obslist - good zero order estimates
xnum = strarr(1)
spawn, 'wc -l obslist', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'obslist'

array = strarr(numlns)
readf, inunit, array
free_lun, inunit

obsid = fltarr(numlns - 1)
; expects one line header in obslist
for i = 1, numlns - 1 do begin
  parser = strarr(3)
  parser = strsplit(array(i), '/', /extract)
  obsid(i-1) = parser(2)
endfor

; ************************* read data ($gratweb/obsmerge.pro output) **
; figure num lines input
;  gratdata.db - gratings analysis output
xnum = strarr(1)
spawn, 'wc -l ../obsmerge.out', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, '../obsmerge.out'

array = strarr(numlns)
readf, inunit, array
free_lun, inunit

numobs = n_elements(obsid)

struct = {time: 0.0, inst: '', grat: '', xchip: 0.0, ychip: 0.0, $
          xoff: 0.0, yoff: 0.0}
data = replicate(struct, numobs)

gratdata = strarr(numobs)
grattime = strarr(numobs)
gratdatao = strarr(numobs)
gratdatai = strarr(numobs)
gratdatag = strarr(numobs)
gratxchip = strarr(numobs)
gratychip = strarr(numobs)
gratxoff = strarr(numobs)
gratyoff = strarr(numobs)

for j = 0, numobs - 1 do begin
  i = 1
  parser = strarr(24)
  parser(0) = 0
  while (float(parser(0)) ne obsid(j)) do begin
    parser = strarr(24)
    parser = strsplit(array(i), '|', /extract)
    i = i + 1
  endwhile
  data(j).time = float(parser(1))
  data(j).inst = parser(2)
  data(j).grat = parser(3)
  data(j).xchip = parser(6)
  data(j).ychip = parser(7)
  data(j).xoff = parser(20)
  data(j).yoff = parser(21)
endfor

off_plot, data(where(data.inst eq 'ACIS-S' and data.grat eq 'HETG'))
off_plot, data(where(data.inst eq 'ACIS-S' and data.grat eq 'LETG'))
off_plot, data(where(data.inst eq 'HRC-S' and data.grat eq 'LETG'))

end

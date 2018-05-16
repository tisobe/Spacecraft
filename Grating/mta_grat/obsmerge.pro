PRO obsmerge

; figure num lines input
;  gratdata.db - gratings analysis output
xnum = strarr(1)
spawn, 'wc -l gratdata.db', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'gratdata.db'

array = strarr(numlns)
readf, inunit, array
free_lun, inunit

gratdatat = array(0)
gratdata = strarr(numlns - 1)
gratdatao = fltarr(numlns - 1)
gratdatai = strarr(numlns - 1)
gratdatag = strarr(numlns - 1)
j = 0
for i = 1, numlns - 1 do begin
  gratdata(j) = array(i)
  parser = strarr(11)
  parser = strsplit(gratdata(j), '|', /extract)
  gratdatao(j) = float(parser(0))
  gratdatai(j) = parser(2)
  gratdatag(j) = parser(3)
  j = j + 1
endfor

; obscat_filt.txt - obscat data
xnum = strarr(1)
spawn, 'wc -l obscat_filt.txt', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'obscat_filt.txt'

array = strarr(numlns)
readf, inunit, array
free_lun, inunit

obscdatat = array(0)
obscdata = strarr(numlns - 2)
obscdatao = fltarr(numlns - 2)
obscdatai = strarr(numlns - 2)
obscdatag = strarr(numlns - 2)
j = 0
for i = 2, numlns - 1 do begin
  obscdata(j) = array(i)
  parser = strarr(13)
  parser = strsplit(obscdata(j), '|', /extract)
  obscdatao(j) = float(parser(7))
  obscdatai(j) = parser(0)
  obscdatag(j) = parser(1)
  j = j + 1
endfor

get_lun, ounit
openw, ounit, 'obsmerge.out'
printf, ounit, gratdatat+'|'+obscdatat

j = 0
for i = 0, n_elements(gratdata) - 1 do begin
  while (gratdatao(i) ne obscdatao(j) and j lt n_elements(obscdatao)-2) do begin
    j = j + 1
  endwhile
  if (gratdatai(i) ne obscdatai(j)) then print, gratdatao(i), 'Inst mismatch'
  if (gratdatag(i) ne obscdatag(j)) then print, gratdatao(i), 'Grat mismatch'
  printf, ounit, gratdata(i)+obscdata(j)
endfor

free_lun, ounit

end

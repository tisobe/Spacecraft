PRO obs2html

xnum = strarr(1)
spawn, 'wc -l obs2html.lst', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'obs2html.lst'

array = strarr(numlns)
readf, inunit, array
free_lun, inunit

; initializations
AL = 0
AH = 0
HL = 0
go = 0
ahmonth = strarr(1)
almonth = strarr(1)
hlmonth = strarr(1)
ahdate = strarr(1)
aldate = strarr(1)
hldate = strarr(1)
ahobsid = strarr(1)
alobsid = strarr(1)
hlobsid = strarr(1)

for i = 0, numlns - 1 do begin
  line = array(i)
  case 1 of
    (line eq 'ACIS-S/HETG'): begin
      AL = 0
      AH = 1
      HL = 0
      go = 0
    end
    (line eq 'ACIS-S/LETG'): begin
      AL = 1
      AH = 0
      HL = 0
      go = 0
    end
    (line eq 'HRC-S/LETG'): begin
      AL = 0
      AH = 0
      HL = 1
      go = 0
    end
    else: go = 1
  endcase

; collect data
  if (go eq 1) then begin
    tmpln = strarr(3)
    tmpln = strsplit(line, ' ', /extract)

    case 1 of
      (AH eq 1): begin
        ahmonth = [ahmonth, tmpln(0)]
        ahdate = [ahdate, tmpln(1)]
        ahobsid = [ahobsid, tmpln(2)]
      end
      (AL eq 1): begin
        almonth = [almonth, tmpln(0)]
        aldate = [aldate, tmpln(1)]
        alobsid = [alobsid, tmpln(2)]
      end
      (HL eq 1): begin
        hlmonth = [hlmonth, tmpln(0)]
        hldate = [hldate, tmpln(1)]
        hlobsid = [hlobsid, tmpln(2)]
      end
    endcase
  endif
endfor

;  num ACIS/HETG is divided by 2 because it gets two columns
nah = (n_elements(ahmonth))/2
nal = n_elements(almonth)
nhl = n_elements(hlmonth)

maxobs = ceil(max([nah, nal, nhl]))

;  pad al and hl, assuming ah is largest
for i = nal, maxobs do begin
  almonth = [almonth, ' ']
  aldate = [aldate, ' ']
  alobsid = [alobsid, ' ']
endfor

for i = nhl, maxobs do begin
  hlmonth = [hlmonth, ' ']
  hldate = [hldate, ' ']
  hlobsid = [hlobsid, ' ']
endfor

ahmonth = [ahmonth, ' ']
ahdate = [ahdate, ' ']
ahobsid = [ahobsid, ' ']

get_lun, hunit
openw, hunit, 'out.html'
printf, hunit, '<table border=1 width=100% align=center>'
printf, hunit, '  <tr><th width=25% align=center>ACIS-S/LETG</th>'
printf, hunit, '      <th width=50% align=center>ACIS-S/HETG</th>'
printf, hunit, '      <th width=25% align=center>HRC-S/LETG</th></tr></table>'
printf, hunit, '<table border=3 width=100% align=center>'
printf, hunit, '  <tr><th>OBSID</th><th>OBS Date</th>'
printf, hunit, '      <th>  </th>'
printf, hunit, '     <th>  </th>'
printf, hunit, '      <th>  </th>'
printf, hunit, '      <th>OBSID</th><th>OBS Date</th>'
printf, hunit, '      <th>  </th>'
printf, hunit, '      <th>OBSID</th><th>OBS Date</th>'
printf, hunit, '      <th>  </th>'
printf, hunit, '     <th>  </th>'
printf, hunit, '      <th>  </th>'
printf, hunit, '      <th>OBSID</th><th>OBS Date</th></tr>'
for i = 1, maxobs do begin
  printf, hunit, ' <tr><th><a href="', almonth(i), '/', alobsid(i), '/obsid_', alobsid(i), '_Sky_summary.html">', alobsid(i), '</th>
  printf, hunit, '     <th>', aldate(i), '</th>'
  printf, hunit, '     <th>  </th>'
  printf, hunit, '     <th>  </th>'
  printf, hunit, '     <th>  </th>'
  printf, hunit, '     <th><a href="', ahmonth(i), '/', ahobsid(i), '/obsid_', ahobsid(i), '_Sky_summary.html">', ahobsid(i), '</th>
  printf, hunit, '     <th>', ahdate(i), '</th>'
  printf, hunit, '     <th>  </th>'
  printf, hunit, '     <th><a href="', ahmonth(maxobs+i), '/', ahobsid(maxobs+i), '/obsid_', ahobsid(maxobs+i), '_Sky_summary.html">', ahobsid(maxobs+i), '</th>
  printf, hunit, '     <th>', ahdate(maxobs+i), '</th>'
  printf, hunit, '     <th>  </th>'
  printf, hunit, '     <th>  </th>'
  printf, hunit, '     <th>  </th>'
  printf, hunit, '     <th><a href="', hlmonth(i), '/', hlobsid(i), '/obsid_', hlobsid(i), '_Sky_summary.html">', hlobsid(i), '</th>
  printf, hunit, '     <th>', hldate(i), '</th>'
  printf, hunit, '</tr>'
endfor

printf, hunit, '</table>'

free_lun, hunit

spawn, "sed '1,/SUMMARY START/s/^/X/' obs_index.html > xindex1"
spawn, "sed '/SUMMARY END/,$s/^/Y/' xindex1 > xindex2"
spawn, "grep '^X' xindex2 | sed 's/^X//' > obs_index.html"
spawn, "cat out.html >> obs_index.html"
spawn, "grep '^Y' xindex2 | sed 's/^Y//' >> obs_index.html"
spawn, "rm -f out.html xindex1 xindex2"

end

FUNCTION CPIX_LINKS, obsid, mode, default
; custom find plot to link to
;  look in Save/ and Week/
;  return array of links

links = strarr(n_elements(obsid))

;  get obsid right, pad with 0's
y = where(obsid lt 10000)
w = where(obsid lt 1000)
v = where(obsid lt 100)
obs = strcompress(string(obsid), /remove_all)
if (y(0) gt -1) then obs(y) = '0'+obs(y)
if (w(0) gt -1) then obs(w) = '0'+obs(w)
if (v(0) gt -1) then obs(v) = '0'+obs(v)

list1 = findfile('Save/*cp.gif')
list2 = findfile('Week/*cp.gif')
for i=0, n_elements(obs)-1 do begin
  links(i) = default
  if (mode(i) eq "AFAINT") then begin
    b = where(list1 eq 'Save/acisf'+obs(i)+'acp.gif')
    if (b(0) ge 0) then links(i) = list1(b(0))
    b = where(list2 eq 'Week/acisf'+obs(i)+'acp.gif')
    if (b(0) ge 0) then links(i) = list2(b(0))
  endif else begin
    b = where(list1 eq 'Save/acisf'+obs(i)+'cp.gif')
    if (b(0) ge 0) then begin
      links(i) = list1(b(0))
    endif
    b = where(list2 eq 'Week/acisf'+obs(i)+'cp.gif')
    if (b(0) ge 0) then links(i) = list2(b(0))
  endelse
endfor
return, links
end

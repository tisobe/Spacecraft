PRO GET_DATA
; collect new acis evt files for cpix processing

; list of available data
inlist = './Data/xcopy'
; see if it's already been processed and put here
wkdir = './Week'
; if not, put it here for cpix to process
cpdir = './Data'

; find cached ephin files
command = "find /dsops/ap/sdp/cache/*/acis/acis*evt1.fits -mtime -1> "+inlist
spawn, command, err

; ************************** read new data *************************
; figure num lines input
xnum = strarr(1)
command = 'wc -l '+inlist
spawn, command, xnum 
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numobs = long(xxnum(0))

get_lun, iunit
openr, iunit, inlist

array = strarr(numobs)
readf, iunit, array
  
free_lun, iunit

for k = 0, numobs - 1 do begin
  namroot = strmid(array(k), rstrpos(array(k), "acisf"), 10)
  loc = findfile(wkdir+"/"+namroot+"cp.gif",count=loc_count)
  ;print, wkdir+"/"+namroot+"cp.gif"
  if (loc_count eq 0) then begin
    command="cp "+array(k)+" "+cpdir
    print, command
    spawn, command
  endif
endfor

end

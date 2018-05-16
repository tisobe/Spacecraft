FUNCTION FILELEN, filename
; return the number of lines in filename
command = 'wc -l '+filename
spawn, command, xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = long(xxnum(0))
return, numlns
end

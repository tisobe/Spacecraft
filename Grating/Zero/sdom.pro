FUNCTION SDOM, secs 
; convert seconds since 1998:00:00:00.00 to days since 1999:204
tdom = (secs / 86400) - 204 - 365
return, tdom
end

FUNCTION FLIPY, inarr, base
; flipy y coord from convert_coord output for html map

for i=0, (n_elements(inarr)/3)-1 do begin
  inarr(1,i) = base-inarr(1,i)
endfor
return, inarr
end

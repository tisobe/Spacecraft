pro arctan

num = 1000
x = fltarr(4*num)
y = fltarr(4*num)

for i = 0, 4*num-1 do begin
  x(i) = float(i)/num
  print, x(i)
endfor
 
xx = [-x, x]
y = atan(xx, 1)

plot, xx, y, psym=2

end

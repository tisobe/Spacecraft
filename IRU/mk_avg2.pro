PRO MK_AVG2, inlist, outfile, binsize=BINSIZE
; mk binsize second averages (default 300s) from files listed in inlist
; write to outfile
; BDS 19. Nov 2001

; seconds to average
if (NOT keyword_set(binsize)) then binsize=300

; ************************** read new data *************************
readcol,inlist,array,format='a'
numobs=n_elements(array)

timet = fltarr(1)
times = fltarr(1)
bias1t = fltarr(1)
bias1s = fltarr(1)
bias2t = fltarr(1)
bias2s = fltarr(1)
bias3t = fltarr(1)
bias3s = fltarr(1)
numt = intarr(1)

for k = 0, numobs - 1 do begin
  ; figure num lines input
  print, 'Processing '+array(k)
  data_in = mrdfits(array(k), 1)
  
  ; filter out corrupted data
  ; 2003:228:06:00 to 2003:228:09:00
  b=where((data_in.time lt 177400863 or data_in.time gt 177411663) and $
          (data_in.time lt 178803500 or data_in.time gt 178804000) and $
          (data_in.time lt 179758200 or data_in.time gt 179758300) and $
          (data_in.time lt 180214000 or data_in.time gt 180214100) and $
          (data_in.time lt 180657020 or data_in.time gt 180657030) and $
          (data_in.time lt 189814000 or data_in.time gt 189818000))
  data_in=data_in(b)
  
  ;  collect INFO
  sort_list = sort(data_in.time)
  time = data_in(sort_list).time
  bias1 = data_in(sort_list).bias1
  bias2 = data_in(sort_list).bias2
  bias3 = data_in(sort_list).bias3
  
  time_tot = fltarr(1)
  bias1_tot = fltarr(1)
  bias2_tot = fltarr(1)
  bias3_tot = fltarr(1)
  start = data_in(0).time
  j = 1L
  
  l = 0
  for i = 0L, n_elements(data_in)-1 do begin
    diff = time(i) - start
    ;print, time(i), diff ; debug
    if (diff le binsize) then begin
      l = 1
      time_tot = [time_tot,time(i)]
      bias1_tot = [bias1_tot,bias1(i)]
      bias2_tot = [bias2_tot,bias2(i)]
      bias3_tot = [bias3_tot,bias3(i)]
      j = j + 1;
    endif else begin
      if (l gt 0) then begin
        ; filter above (bad times) instead 
        ; filter out extremes to remove bad data points
        b=where(bias1_tot gt min(bias1_tot) and $
                bias1_tot lt max(bias1_tot) and $
                bias2_tot gt min(bias2_tot) and $
                bias2_tot lt max(bias2_tot) and $
                bias3_tot gt min(bias3_tot) and $
                bias3_tot lt max(bias3_tot),bnum)
        if (bnum gt 1) then begin
          time_tot = time_tot(b)
          bias1_tot = bias1_tot(b)
          bias2_tot = bias2_tot(b)
          bias3_tot = bias3_tot(b)
        endif ; if (bnum gt 1) then begin
       
        l = 0
        avg = mymean(time_tot[1:*])
        timet = [timet, avg(0)]
        times = [timet, sqrt(avg(1))]
        avg = mymean(bias1_tot[1:*])
        bias1t = [bias1t, avg(0)]
        bias1s = [bias1s, sqrt(avg(1))]
        avg = mymean(bias2_tot[1:*])
        bias2t = [bias2t, avg(0)]
        bias2s = [bias2s, sqrt(avg(1))]
        avg = mymean(bias3_tot[1:*])
        bias3t = [bias3t, avg(0)]
        bias3s = [bias3s, sqrt(avg(1))]
        numt = [numt, j]
        start = time(i)
        time_tot = time(i)
        bias1_tot = bias1(i)
        bias2_tot = bias2(i)
        bias3_tot = bias3(i)
        j = 1
        time_tot = fltarr(1)
        bias1_tot = fltarr(1)
        bias2_tot = fltarr(1)
        bias3_tot = fltarr(1)
      endif else begin
        start = time(i)
        j = 1
      endelse
    endelse
  endfor
  
  if (n_elements(time_tot) gt 1) then begin
    avg = mymean(time_tot[1:*])
    timet = [timet, avg(0)]
    times = [timet, sqrt(avg(1))]
    avg = mymean(bias1_tot[1:*])
    bias1t = [bias1t, avg(0)]
    bias1s = [bias1s, sqrt(avg(1))]
    avg = mymean(bias2_tot[1:*])
    bias2t = [bias2t, avg(0)]
    bias2s = [bias2s, sqrt(avg(1))]
    avg = mymean(bias3_tot[1:*])
    bias3t = [bias3t, avg(0)]
    bias3s = [bias3s, sqrt(avg(1))]
    numt = [numt, j]
  endif ; if (n_elements(time_tot gt 1)) then 

endfor
  
timet = timet[1:*]
times = times[1:*]
bias1t = bias1t[1:*]
bias1s = bias1s[1:*]
bias2t = bias2t[1:*]
bias2s = bias2s[1:*]
bias3t = bias3t[1:*]
bias3s = bias3s[1:*]
numt = numt[1:*]

; put into structure
a = {mg_tab, time: 0.0, Navg: 0, bias1: 0.0, bias1s: 0.0, $
     bias2: 0.0, bias2s: 0.0, bias3: 0.0, bias3s: 0.0}
; sort and eliminate duplicates
u = uniq(timet, sort(timet))
struct = replicate({mg_tab}, n_elements(u))
struct.time = timet(u)
struct.Navg = numt(u)
struct.bias1 = bias1t(u)
struct.bias1s = bias1s(u)
struct.bias2 = bias2t(u)
struct.bias2s = bias2s(u)
struct.bias3 = bias3t(u)
struct.bias3s = bias3s(u)

; write output

mwrfits, struct, outfile,/create
  
end

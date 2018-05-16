PRO filt_plot, inmarray, inparray, plottitle, PLOTX=plotx

;filt_val = 0.15 ; keep only error/fwhm le filt_val
filt_val = 0.50 ; keep only error le filt_val

xwidth=512
yheight=400
if (keyword_set(plotx)) then begin
  set_plot, 'X'
  window, 0, xsize=xwidth, ysize=yheight
endif else begin
  set_plot, 'Z'
  device, set_resolution = [xwidth, yheight]
endelse

nummobs = n_elements(inmarray)
numpobs = n_elements(inparray)
numtot = nummobs+numpobs
energy = fltarr(numtot)
fwhm = fltarr(numtot)
denergy = fltarr(numtot)
error = fltarr(numtot)
links = strarr(numtot)
obsid = strarr(numtot)
year = intarr(numtot)
order = intarr(numtot)
cnts = fltarr(numtot)
roi_counts = fltarr(numtot)
acf = fltarr(numtot)
acf_err = fltarr(numtot)

for i = 0, nummobs - 1 do begin
  tmp = strarr(10)
  tmp = strsplit(inmarray(i), "	", /extract)
  obspath = strsplit(tmp(0),'/',/extract)
  obsid(i) = obspath(2)
  links(i) = strcompress(obspath(0)+"/"+obspath(1)+"/"+obspath(2)+"/obsid_"+ $
             obsid(i)+"_Sky_summary.html", /remove_all)
  year(i) = fix(strmid(obspath(1),3,2))
  energy(i) = tmp(3)
  fwhm(i) = tmp(5)
  denergy(i) = tmp(7)
  error(i) = tmp(6)
  order(i) = 0
  cnts(i) = tmp(1)
  roi_counts(i) = tmp(8)
  acf(i) = tmp(9)
  acf_err(i) = tmp(10)
endfor
for j = 0, numpobs - 1 do begin
  tmp = strarr(10)
  tmp = strsplit(inparray(j), "	", /extract)
  obspath = strsplit(tmp(0),'/',/extract)
  obsid(i) = obspath(2)
  links(i) = strcompress(obspath(0)+"/"+obspath(1)+"/"+obspath(2)+"/obsid_"+ $
             obsid(i)+"_Sky_summary.html", /remove_all)
  year(i) = fix(strmid(obspath(1),3,2))
  energy(i) = tmp(3)
  fwhm(i) = tmp(5)
  denergy(i) = tmp(7)
  error(i) = tmp(6)
  order(i) = 1
  cnts(i) = tmp(1)
  roi_counts(i) = tmp(8)
  acf(i) = tmp(9)
  acf_err(i) = tmp(10)
  i = i + 1
endfor

;if (plottitle eq 'MEGm1') then begin
  ;print, energy(where(error gt 0 and error lt 1.0))
  ;print, denergy(where(error gt 0 and error lt 1.0))
;endif
;filter=error/fwhm
filter=error
filter=indgen(n_elements(year))+1
;b=where(error lt 0.3 and error/fwhm lt 0.15)
b=where(error/fwhm lt 0.15)
if (plottitle eq 'HEG_all') then begin
  b=where(error/fwhm lt 0.15 and abs(energy-1.01) gt 0.01 and fwhm*1000./energy lt 5.)
endif
if (plottitle eq 'MEG_all') then begin
  b=where(error/fwhm lt 0.15 and fwhm*1000./energy lt 5.)
endif
filter(b)=0
filt_val=0
bad = where(error lt 0.0001, nbad)
if (nbad ge 1) then filter(bad)=filt_val+1
cipsdir="/home/mta/Gratings/hak_1.4/hak_data"
if (strpos(plottitle,'LEG') gt -1) then begin
  xs=[.1,2.5]
  ys=[50,1000]
  res_opt = rdb_read(cipsdir+'/letgD1996-11-01res_optN0002.rdb', /SILENT)
  res_con = rdb_read(cipsdir+'/letgD1996-11-01res_conN0002.rdb', /SILENT)
endif
if (strpos(plottitle,'HEG') gt -1) then begin
  xs=[.6,8]
  ys=[50,3000]
  res_opt = rdb_read(cipsdir+'/hetghegD1996-11-01res_optN0002.rdb', /SILENT)
  res_con = rdb_read(cipsdir+'/hetghegD1996-11-01res_conN0002.rdb', /SILENT)
endif
if (strpos(plottitle,'MEG') gt -1) then begin
  xs=[.6,8]
  ys=[50,2000]
  res_opt = rdb_read(cipsdir+'/hetgmegD1996-11-01res_optN0002.rdb', /SILENT)
  res_con = rdb_read(cipsdir+'/hetgmegD1996-11-01res_conN0002.rdb', /SILENT)
endif
loadct, 39
white = 255
bgrd = 0
red = 230
yellow = 190
blue = 100
green = 150
purple = 50
orange = 215

usersym, [-.5, .5], [0, 0]
;denergy=denergy*energy
sel=where((year ge 99 or year le 04) and filter le filt_val and order eq 1,num)
plot, energy(sel), denergy(sel), psym = 1, $
      title = plottitle, $
      xtitle = 'keV', ytitle = 'E/dE', $
      ystyle = 1, xstyle = 1, background = 0, color = white, $
      ;/ylog, /xlog, xticks=2, xtickv=[0.1,1,5], xminor=4, $
      /ylog, /xlog, $
      yrange = ys, xrange = xs, $
      charsize=1, charthick=1, /nodata
xfit=xs(0)+(indgen(100)/100.0*(xs(1)-xs(0)))
if (num gt 0) then begin
  oplot, energy(sel), denergy(sel), psym = 1, color=green
  m = moment(energy(sel)*denergy(sel))
  oplot, xfit, m(0)/xfit, color=green
endif

sel=where((year ge 04 and year le 08) and filter le filt_val and order eq 1,num)
if (num gt 0) then begin
  oplot, energy(sel),denergy(sel), psym=1, color=blue
  m = moment(energy(sel)*denergy(sel))
  oplot, xfit, m(0)/xfit, color=blue
endif

sel=where((year ge 06 and year le 09) and filter le filt_val and order eq 1,num)
if (num gt 0) then begin
  oplot, energy(sel),denergy(sel), psym=1, color=yellow
  m = moment(energy(sel)*denergy(sel))
  oplot, xfit, m(0)/xfit, color=yellow
endif

sel=where((year ge 08 and year le 12) and filter le filt_val and order eq 1,num)
if (num gt 0) then begin
  oplot, energy(sel),denergy(sel), psym=1, color=orange
  m = moment(energy(sel)*denergy(sel))
  oplot, xfit, m(0)/xfit, color=orange
endif

sel=where((year ge 12 and year le 16) and filter le filt_val and order eq 1,num)
if (num gt 0) then begin
  oplot, energy(sel),denergy(sel), psym=1, color=orange
  m = moment(energy(sel)*denergy(sel))
  oplot, xfit, m(0)/xfit, color=orange
endif

sel=where(year eq 99 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=green
sel=where(year eq 00 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=green
sel=where(year eq 01 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=green
sel=where(year eq 02 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=green
sel=where(year eq 03 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=blue
sel=where(year eq 04 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=blue
sel=where(year eq 05 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=blue
sel=where(year eq 06 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=yellow
sel=where(year eq 07 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=yellow
sel=where(year eq 08 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=yellow
sel=where(year eq 09 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=orange
sel=where(year eq 10 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=orange
sel=where(year eq 11 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=orange

sel=where(year eq 12 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=red
sel=where(year eq 13 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=red
sel=where(year eq 14 and filter le filt_val and order eq 0,num)
if (num gt 0) then oplot, energy(sel),denergy(sel), psym=7, color=red


oplot, res_opt.energies, res_opt.respower, LINESTYLE=2, color=white
oplot, res_con.energies, res_con.respower, LINESTYLE=1, color=white

sel=where(filter le filt_val)
map=flipy4map(convert_coord(energy(sel),denergy(sel),/to_device),!D.Y_SIZE)
html_map, map, links(sel), strcompress("OBSID: "+string(obsid(sel))+" E="+ $
          string(energy(sel))+" keV FWHM="+string(fwhm(sel))+" eV Error= "+ $
          string(error(sel))+" eV E/dE="+ $
          string(denergy(sel))), $
          plottitle+"map",plottitle+"gif"
      
;print,energy/fwhm(sel) + error(sel)

openu, tunit,'xlst.html', /get_lun
for i = 0, n_elements(sel)-1 do begin
  printf, tunit, links(sel(i))
endfor
free_lun, tunit

; list for databases
openw, dunit, plottitle+'.rdb', /get_lun
printf, dunit, "OBSID ORDER CNTS ENERGY FWHM ERR EdE ROI_CNTS ACF ACF_ERR"
printf, dunit, "N N N N N N N N N N"
for i = 0, n_elements(sel)-1 do begin
  j = sel(i)
  if (energy(j) gt 0) then begin
    printf, dunit, obsid(j), order(j), cnts(j), energy(j), $
      fwhm(j), error(j), denergy(j), roi_counts(j), $
      acf(j), acf_err(j), $
      format='(I5," ",I1," ",I5,3(" ",F6.4)," ",F6.1," ",I5,2(" ",F6.4))'
  endif ; if (energy(j) gt 0) then begin
endfor ; for i = 0, n_elements(sel)-1 do begin
free_lun, dunit
end

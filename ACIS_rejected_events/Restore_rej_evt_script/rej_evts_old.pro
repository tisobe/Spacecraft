PRO REJ_EVTS, rejlist, PLOTX=plotx

outroot = "_rej.dat"

print, rejlist

; find ccd_id
head=headfits(rejlist, exten=1)
print, head(where(strpos(head, 'CCD_ID') ne -1))
a = head(where(strpos(head, 'CCD_ID') ne -1))
tmp_id = strsplit(a(0), /extract)
ccd = fix(tmp_id(2))

if (keyword_set(plotx)) then begin
  set_plot, 'X'
  window, 0, xsize=700, ysize=700
endif else begin
  set_plot, 'Z'
  device, set_resolution = [700, 700]
endelse
!P.MULTI = [0, 1, 5, 0, 0]

data = mrdfits(rejlist, 1, /fscale)

ccds = [0,1,2,3,4,5,6,7,8]
ccd_id = ["I0", "I1", "I2", "I3", "S0", "S1", "S2", "S3", "S4", "S5"]

;plot, data.expno, data.evtsent, psym=4, charsize=1.8, $
      ;xtitle = "Frame", ytitle="EVTSENT", $
      ;title=rejlist+"  CCD"+strcompress(ccd)+"  "+ccd_id(ccd)
;plot, data.expno, data.drop_amp, psym=4, charsize=1.8, $
      ;xtitle = "Frame", ytitle="DROP_AMP", $
      ;title=rejlist+"  CCD"+strcompress(ccd)+"  "+ccd_id(ccd)
;plot, data.expno, data.drop_pos, psym=4, charsize=1.8, $
      ;xtitle = "Frame", ytitle="DROP_POS", $
      ;title=rejlist+"  CCD"+strcompress(ccd)+"  "+ccd_id(ccd)
;plot, data.expno, data.drop_grd, psym=4, charsize=1.8, $
      ;xtitle = "Frame", ytitle="DROP_GRD", $
      ;title=rejlist+"  CCD"+strcompress(ccd)+"  "+ccd_id(ccd)
;plot, data.expno, data.evtsent/(data.evtsent+data.drop_amp+data.drop_pos+data.drop_grd), $
      ;psym=4, charsize=1.8, $
      ;xtitle = "Frame", ytitle="EVTSENT/EVT_TOT", $
      ;title=rejlist+"  CCD"+strcompress(ccd)+"  "+ccd_id(ccd)

time = moment(data.time)
sent = moment(data.evtsent)
amp = moment(data.drop_amp)
pos = moment(data.drop_pos)
grd = moment(data.drop_grd)

get_lun, ounit
openw, ounit, strcompress("CCD"+string(ccd)+outroot, /remove_all), /append
info = fstat(ounit)
if (info.size eq 0) then begin
  printf, ounit, "TIME EVTSENT SD DROP_POS SD DROP_GRD SD Navg CCD"
endif
printf, ounit, time(0),sent(0),sqrt(sent(1)), $
       amp(0),sqrt(amp(1)), $
       pos(0),sqrt(pos(1)), $
       grd(0),sqrt(grd(1)), $
       n_elements(data),ccd, format='(E16.9, 8(" ", F8.2), " ", I6," ", I1)'
free_lun, ounit
end

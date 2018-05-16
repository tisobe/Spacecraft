PRO REJ_EVTS, rejlist, PLOTX=plotx

outroot = "_rej.dat"

print, rejlist

if (keyword_set(plotx)) then begin
  set_plot, 'X'
  window, 0, xsize=700, ysize=700
endif else begin
  set_plot, 'Z'
  device, set_resolution = [700, 700]
endelse
!P.MULTI = [0, 1, 5, 0, 0]

data = mrdfits(rejlist, 1, /fscale)

head=headfits(rejlist, exten=1)
;print, head(where(strpos(head, 'OBS_ID') ne -1))
a = head(where(strpos(head, 'OBS_ID') ne -1))
;print, a
tmp_id = strsplit(a(0), /extract, /regex)
obs_id = long(strmid(tmp_id(2),1))
print, "Working obsid ", obs_id

ccds = [0,1,2,3,4,5,6,7,8,9]
ccd_id = ["I0", "I1", "I2", "I3", "S0", "S1", "S2", "S3", "S4", "S5", "S6"]

for i = 0, n_elements(ccds) - 1 do begin

  b = where(data.ccd_id eq ccds(i))
  if (n_elements(b) gt 1) then begin
    time = moment(data(b).time)
    sent = moment(data(b).evtsent)
    amp = moment(data(b).drop_amp)
    pos = moment(data(b).drop_pos)
    grd = moment(data(b).drop_grd)
    thr = moment(data(b).thr_pix)
    sum = max(data(b).berr_sum)
    
    get_lun, ounit
    openw, ounit, strcompress("CCD"+string(ccds(i))+outroot, /remove_all), /append
    info = fstat(ounit)
    if (info.size eq 0) then begin
      ;printf, ounit, "TIME EVTSENT SD DROP_POS SD DROP_GRD SD THR_PIX SD BERR_SUM SD Navg OBS_ID CCD"
    endif
    printf, ounit, time(0), $
           sent(0),sqrt(sent(1)), $
           amp(0),sqrt(amp(1)), $
           pos(0),sqrt(pos(1)), $
           grd(0),sqrt(grd(1)), $
           thr(0),sqrt(thr(1)), $
           sum,0, $
           n_elements(b),obs_id,ccds(i), $
           format='(E16.9, 12(" ", F8.2), " ", I6," ", I5, " ", I1)'
    free_lun, ounit
  endif
endfor
 
spawn, 'rm '+rejlist

end

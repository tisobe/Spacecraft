PRO REJ_EVTS_BIN, rejlist, PLOTX=plotx

; how many frames in a bin ?
binsize = 20

head=headfits(rejlist, exten=1)
print, head(where(strpos(head, 'CCD_ID') ne -1))
a = head(where(strpos(head, 'CCD_ID') ne -1))
;print, where(strpos(head, 'CCD_ID') ne -1) ; debug
tmp_id = strsplit(a(0), /extract)
;tmp_id = strsplit("Bob is 4 too", /extract) ; debug
ccd = fix(tmp_id(2))

if (keyword_set(plotx)) then begin
  set_plot, 'X'
  window, 0, xsize=700, ysize=600
endif else begin
  set_plot, 'Z'
  device, set_resolution = [700, 600]
endelse
!P.MULTI = [0, 1, 4, 0, 0]

data = mrdfits(rejlist, 1, /fscale)

ccds = [0,1,2,3,4,5,6,7,8]
ccd_id = ["I0", "I1", "I2", "I3", "S0", "S1", "S2", "S3", "S4", "S5"]

expno = fltarr(1)
evtsent = fltarr(1)
drop_amp = fltarr(1)
drop_pos = fltarr(1)
drop_grd = fltarr(1)
for i = fix(data(0).expno), fix(data(n_elements(data)-1).expno) do begin
  b = where(data.expno ge i and data.expno lt (i + binsize))
  exp = moment(data(b).expno)
  expno = [expno, exp[0]]
  evt = moment(data(b).evtsent)
  evtsent = [evtsent, evt[0]]
  amp = moment(data(b).drop_amp)
  drop_amp = [drop_amp, amp[0]]
  pos = moment(data(b).drop_pos)
  drop_pos = [drop_pos, pos[0]]
  grd = moment(data(b).drop_grd)
  drop_grd = [drop_grd, grd[0]]
  i = i + binsize - 1
endfor

; get rid of first dummy element
expno = expno[1:*]
evtsent = evtsent[1:*]
drop_amp = drop_amp[1:*]
drop_pos = drop_pos[1:*]
drop_grd = drop_grd[1:*]

plot, expno, evtsent, psym=4, charsize=1.8, $
      xtitle = "Frame", ytitle="EVTSENT", $
      title=rejlist+"  CCD"+strcompress(ccd)+"  "+ccd_id(ccd)
plot, expno, drop_amp, psym=4, charsize=1.8, $
      xtitle = "Frame", ytitle="DROP_AMP", $
      title=rejlist+"  CCD"+strcompress(ccd)+"  "+ccd_id(ccd)
plot, expno, drop_pos, psym=4, charsize=1.8, $
      xtitle = "Frame", ytitle="DROP_POS", $
      title=rejlist+"  CCD"+strcompress(ccd)+"  "+ccd_id(ccd)
plot, expno, drop_grd, psym=4, charsize=1.8, $
      xtitle = "Frame", ytitle="DROP_GRD", $
      title=rejlist+"  CCD"+strcompress(ccd)+"  "+ccd_id(ccd)
end

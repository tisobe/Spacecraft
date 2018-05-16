PRO DO_PLOTS, plottab, inst

; run standard src_mon plots

set_plot, 'Z'

; plots of all sources
; Total
if (inst eq 'all') then begin
psf_time_anal, plottab, 'tot_all'
src_mon_plots, plottab, 'tot_all'
; plots by dist
r = ['0', '30', '60', '120', '180', '240', '300', '420', '600']
for i = 1, n_elements(r) - 1 do begin
  b = where(plottab.dist gt float(r(i-1)) and plottab.dist le float(r(i)), size)
  if (size gt 0) then begin
    src_tmp = plottab(b)
    r1 = string(r(i-1))
    name = 'tot_r'+string(r(i-1))+'-'+string(r(i))
    src_mon_plots, src_tmp, name
  endif
endfor
endif

; Acis-I
if (inst eq 'acis-i') then begin
b = where(plottab.simz lt -200, size)
if (size gt 0) then begin
  acis_i_tab = plottab(b)
  psf_time_anal, acis_i_tab, 'ACIS-I'
  src_mon_plots, acis_i_tab, 'ai_all'
  ; plots by dist
  r = ['0', '30', '60', '120', '180', '240', '300', '420', '600']
  for i = 1, n_elements(r) - 1 do begin
    b = where(acis_i_tab.dist gt float(r(i-1)) and acis_i_tab.dist le float(r(i)), size)
    if (size gt 0) then begin
      acis_i_tmp = acis_i_tab(b)
      r1 = string(r(i-1))
      name = 'ai_r'+string(r(i-1))+'-'+string(r(i))
      src_mon_plots, acis_i_tmp, name
    endif
  endfor
endif
endif

if (inst eq 'acis-s') then begin
b = where(plottab.simz lt -150 and plottab.simz gt -200, size)
if (size gt 0) then begin
  acis_s_tab = plottab(b)
  psf_time_anal, acis_s_tab, 'as_all'
  src_mon_plots, acis_s_tab, 'as_all'
  ; plots by dist
  r = ['0', '30', '60', '120', '180', '240', '300', '420', '600']
  for i = 1, n_elements(r) - 1 do begin
    b = where(acis_s_tab.dist gt float(r(i-1)) and acis_s_tab.dist le float(r(i)), size)
    if (size gt 0) then begin
      acis_s_tmp = acis_s_tab(b)
      name = 'as_r'+string(r(i-1))+'-'+string(r(i))
      src_mon_plots, acis_s_tmp, name
    endif
  endfor
endif
endif

if (inst eq 'hrc-i') then begin
b = where(plottab.simz lt 200 and plottab.simz gt 100, size)
if (size gt 0) then begin
  hrc_i_tab = plottab(b)
  psf_time_anal, hrc_i_tab, 'hi_all'
  src_mon_plots, hrc_i_tab, 'hi_all'
  ; plots by dist
  ;r = ['0', '30', '60', '120', '180', '240', '300', '420', '600']
  r = ['0', '30', '60', '120', '180']
  for i = 1, n_elements(r) - 1 do begin
    b = where(hrc_i_tab.dist gt float(r(i-1)) and hrc_i_tab.dist le float(r(i)), size)
    if (size gt 0) then begin
      hrc_i_tmp = hrc_i_tab(b)
      name = 'hi_r'+string(r(i-1))+'-'+string(r(i))
      src_mon_plots, hrc_i_tmp, name
    endif
  endfor
endif
endif

if (inst eq 'hrc-s') then begin
b = where(plottab.simz gt 200, size)
if (size gt 0) then begin
  hrc_s_tab = plottab(b)
  psf_time_anal, hrc_s_tab, 'hs_all'
  src_mon_plots, hrc_s_tab, 'hs_all'
  ; plots by dist
  ;r = ['0', '30', '60', '120', '180', '240', '300', '420', '600']
  r = ['0', '30', '60', '120', '180', '240']
  for i = 1, n_elements(r) - 1 do begin
    b = where(hrc_s_tab.dist gt float(r(i-1)) and hrc_s_tab.dist le float(r(i)), size)
    if (size gt 0) then begin
      hrc_s_tmp = hrc_s_tab(b)
      name = 'hs_r'+string(r(i-1))+'-'+string(r(i))
      src_mon_plots, hrc_s_tmp, name
    endif
  endfor
endif
endif

;free_lun, ounit

  ; debug print,"xstart ", xstart
  ; debug print, "xsimx ", xsimx
  ; debug print, "xsimz ", xsimz
  ; debug print, "xdefoc ", xdefoc
  ; debug print, "xx ", xx
  ; debug print, "xy ", xy
  ; debug print, "xsnr ", xsnr
  ; debug print, "xrmaj ", xrmaj
  ; debug print, "xrmin ", xrmin
  ; debug print, "xrotang ", xrotang
  ; debug print, "xpsfratio ", xpsfratio

;print, plottab(uniq(plottab.simx, sort(plottab.simx))).simx
;print, plottab(uniq(plottab.simz, sort(plottab.simz))).simz

end

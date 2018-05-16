PRO SRC_MON_PLOTS, intab, label

; must have more than one observation to plot against time
b = uniq(intab.start, sort(intab.start))
plot_time = 0
if (n_elements(b) gt 1) then plot_time = 1

set_plot, 'Z'
if (n_elements(intab) gt 1) then begin
print, "Plotting ", n_elements(intab), " sources under ", label
  
; X, Y plot
plot, intab.x, intab.y, psym = 7, $
      xticks = 4, $
      xtitle = 'X POS ', ytitle = 'Y POS ', title = label, $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 2, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, label+'_xy.gif', tvrd()
 
; PSF plots
if (n_elements(b) gt 1) then begin
plot, sdom(intab.start), intab.psf, psym = 7, $
      xticks = 4, $
      xtitle = 'TIME (DOM) ', ytitle = 'PSF (arcsec)', title = label, $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 2, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, label+'_t_psf.gif', tvrd()
endif
 
plot, intab.dist, intab.psf, psym = 7, $
     xticks = 4, $
     xtitle = 'off axis distance (arcsec)', ytitle = 'PSF (arcsec)', title = label, $
     ystyle = 1, xstyle = 1, background = 255, color = 0, $
     charsize = 2, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, label+'_d_psf.gif', tvrd()
 
; Roundness plots
if (n_elements(b) gt 1) then begin
plot, sdom(intab.start), intab.rnd, psym = 7, $
      xticks = 4, $
      xtitle = 'TIME (DOM) ', ytitle = 'Roundness', title = label, $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 2, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, label+'_t_rnd.gif', tvrd()
endif
 
plot, intab.dist, intab.rnd, psym = 7, $
      xticks = 4, $
      xtitle = 'off axis distance (arcsec)', ytitle = 'Roundness', title = label, $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 2, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, label+'_d_rnd.gif', tvrd()
 
; EE_Radius plots
if (n_elements(b) gt 1) then begin
plot, sdom(intab.start), intab.ravg, psym = 7, $
      xticks = 4, $
      xtitle = 'TIME (DOM) ', ytitle = '80% EE_Radius', $
      title = label, $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 2, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, label+'_t_ravg.gif', tvrd()
endif

plot, intab.dist, intab.ravg, psym = 7, $
      xticks = 4, $
      xtitle = 'off axis distance ', ytitle = '90% EE_Radius', title = label, $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 2, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, label+'_d_ravg.gif', tvrd()
 
;set_plot,'ps'
;device,filename=label+'_d_ravg.ps',/encap
plot, intab.dist, intab.ravg, psym = 7, $
      ;xticks = 4, $
      xtitle = 'off-axis angle (arcsec)', $
      ytitle = '90% Radius (arcsec)', title = 'ACIS-I Encircled Energy', $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      ;charsize = 1.25,thick=2,xthick=2,ythick=2, charthick =2
      charsize = 1.25,thick=1,xthick=1,ythick=1, charthick =1
;xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
n=where(intab.ravg gt 2.4)
fit=poly_fit(intab(n).dist,intab(n).ravg,2)
openw,punit,'xafit'+label,/get_lun
printf,punit,fit
free_lun,punit
;oplot,fit(0)+fit(1)*intab(n).dist+fit(2)*intab(n).dist*intab(n).dist
write_gif,label+'_d_ravg1.gif',tvrd()
;device,/close
set_plot,'z'
 
; SNR plots
if (n_elements(b) gt 1) then begin
plot, sdom(intab.start), intab.snr, psym = 7, $
      xticks = 4, $
      xtitle = 'TIME (DOM) ', ytitle = 'SNR', title = label, $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 2, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, label+'_t_snr.gif', tvrd()
endif
 
plot, intab.dist, intab.snr, psym = 7, $
      xticks = 4, $
      xtitle = 'off axis distance ', ytitle = 'SNR', title = label, $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 2, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, label+'_d_snr.gif', tvrd()

; rotang/angd plots
plot, intab.rnd, intab.rotang/intab.angd, psym = 7, $
      xticks = 4, $
      xtitle = 'roundness ', ytitle = 'rotang/angd', title = label, $
      ystyle = 1, xstyle = 1, background = 255, color = 0, $
      charsize = 2, charthick =2
xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
write_gif, label+'_rnd_rot.gif', tvrd()
b = where(intab.rnd ge 1, wnum)
if (wnum ge 2) then begin
  rottab = intab(b)
  plot, rottab.angd, rottab.rotang, psym = 7, $
        xticks = 4, $
        xtitle = 'ANGD ', ytitle = 'ROTANG', title = label, $
        ystyle = 1, xstyle = 1, background = 255, color = 0, $
        charsize = 2, charthick =2
  xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
  write_gif, label+'_rot.gif', tvrd()
  
  b = uniq(rottab.start, sort(rottab.start))
  if (n_elements(b) gt 1) then begin
    plot, sdom(rottab.start), rottab.rotang/rottab.angd, psym = 7, $
          xticks = 4, $
          xtitle = 'TIME (DOM) ', ytitle = 'rotang/angd', title = label, $
          ystyle = 1, xstyle = 1, background = 255, color = 0, $
          charsize = 2, charthick =2
    xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
    write_gif, label+'_t_rot.gif', tvrd()
  endif; n_elements(b) gt 1
    
  plot, rottab.dist, rottab.rotang/rottab.angd, psym = 7, $
        xticks = 4, $
        xtitle = 'off axis distance ', ytitle = 'rotang/angd', title = label, $
        ystyle = 1, xstyle = 1, background = 255, color = 0, $
        charsize = 2, charthick =2
  xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
  write_gif, label+'_d_rot.gif', tvrd()
endif ; wnum ge 2

endif ; if (n_elements(intab) gt 1) then begin

if (n_elements(b) le 1) then begin
  print, " "
  print, "Need at least two observations to plot for ", label
  print, "  No plots generated"
  print, " "
endif

end

PRO fit_funct, X, A, F, pder
; read constant coefficients from file, use to fit deg0 coeff
get_lun, funit
openr, funit, './psf_coeff.out'
array = strarr(2)
readf, funit, array
free_lun, funit
coeff1 = float(array(0))
coeff2 = float(array(1))
print,"fit_funct in ",a(0),coeff1,coeff2 ;debug
F = A[0] + (coeff1*X) + (coeff2*X*X)

;If the procedure is called with four parameters, calculate the
;partial derivatives.
IF (N_PARAMS() GE 4) THEN BEGIN
  ;pder= [[replicate(0.0, N_ELEMENTS(X))]]
  pder = fltarr(n_elements(x), 1)
  pder(*,0)=coeff1+(2*coeff2)
ENDIF
END

PRO PSF_TIME_ANAL, intab, label

; show changes in psf over time
; get months
;mthfile='/home/brad/Tscpos/months'
;mthfile='../months' ; /data/mta4/www/DAILY/months
mthfile='/data/mta4/www/DAILY/mta_src/Scripts/house_keeping/years' ; /data/mta4/www/DAILY/months
;mthfile='./months.tmp'
nummth = filelen(mthfile)
get_lun, iunit
openr, iunit, mthfile
array = strarr(nummth)
readf, iunit, array
free_lun, iunit

a = {months, name: ' ', start: 0, stop: 0, coeff0: 0.0, coeff1: 0.0, coeff2: 0.0, num: 0}
mthtab = replicate({months}, nummth)
for i = 0, nummth-1 do begin
  line=strsplit(array(i), " ", /extract)
  mthtab(i).name = line(0)
  mthtab(i).start = line(1)
  mthtab(i).stop = line(2)
endfor

; arrays for time coefficient data to plot
ptime=fltarr(1)
pdeg0=fltarr(1)
pdeg1=fltarr(1)
pdeg2=fltarr(1)
perr0=fltarr(1)
perr1=fltarr(1)
perr2=fltarr(1)
fitdeg=3 ; degree + 1 of fit line

data=0 ; don't have anything to plot yet

b = sort(intab.start)
print, "started psf_time_anal on ", label  ;debug
if (n_elements(b) gt 1) then begin
  tstart = intab(b(0)).start
  tend = intab(b(n_elements(b)-1)).start
  print, "Data ", tstart, " to ", tend ; debug
  j = 0 ; mthtab indexer
   while (j lt nummth) do begin
    b = where(sdom(intab.start) ge mthtab(j).start and sdom(intab.start) lt mthtab(j).stop, num)
    mthtab(j).num = num
    print, "psf_anal days ", mthtab(j).start, " n_elements ", n_elements(b) ;debug
    if (mthtab(j).num ge 1) then begin
      ;if (n_elements(intab(b).dist) gt 1) then begin
      if (n_elements(intab(b).dist) gt 5) then begin
        data = 1
        fit = svdfit(intab(b).dist, intab(b).psf, fitdeg, variance=fiterr)
        fitline = fit(0)+(fit(1)*intab(b).dist)+(fit(2)*intab(b).dist*intab(b).dist)
        ptime=[ptime, (mthtab(j).start+mthtab(j).stop)/2]
        pdeg0=[pdeg0, fit(0)]
        pdeg1=[pdeg1, fit(1)]
        pdeg2=[pdeg2, fit(2)]
        perr0=[perr0, fiterr(0)]
        perr1=[perr1, fiterr(1)]
        perr2=[perr2, fiterr(2)]
        ;oldfit mthtab(j).coeff0 = fit(0)
        ;oldfit mthtab(j).coeff1 = fit(1)
        ;oldfit mthtab(j).coeff2 = fit(2)
        ;oldfit print, mthtab(j).start, " ", fit, " ", fiterr
        ;oldfit a = sort(intab(b).dist)
        ;oldfit plot, intab(b(a)).dist, fitline(a), $
             ;oldfit xticks = 4, $
             ;oldfit xtitle = 'off axis distance (arcsec)', ytitle = 'PSF (arcsec)', $
             ;oldfit title = label+' DOM '+strtrim(mthtab(j).start,2)+' to '+strtrim((mthtab(j).stop),2), $
             ;oldfit yrange=[0, max(intab(b).psf)+0.2], $
             ;oldfit ystyle = 1, xstyle = 1, background = 255, color = 0, $
             ;oldfit charsize = 2, charthick =2
        ;oldfit oplot, intab(b).dist, intab(b).psf, psym = 7, color=90
        ;oldfit xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
        ;oldfit write_gif, label+'_d_t'+strtrim(mthtab(j).name,2)+'_psf.gif', tvrd()
      endif
    endif
    j = j+1
  endwhile
  ; delete first, dummy element
  if (n_elements(pdeg0) gt 1) then begin
    pdeg0=pdeg0[1:*]
    pdeg1=pdeg1[1:*]
    pdeg2=pdeg2[1:*]
    perr0=perr0[1:*]
    perr1=perr1[1:*]
    perr2=perr2[1:*]
  endif

  ; fix coeff1 and coeff2
  if (n_elements(pdeg1) gt 1) then begin
    tmp1 = moment(pdeg1)
  endif else begin
    tmp1 = [pdeg1[0], 0]
  endelse
  if (n_elements(pdeg2) gt 1) then begin
    tmp2 = moment(pdeg2)
  endif else begin
    tmp2 = [pdeg2[0], 0]
  endelse
  b=where(finite(tmp1) eq 0,bnum)
  if (bnum gt 0) then tmp1(b)=0
  b=where(finite(tmp2) eq 0,bnum)
  if (bnum gt 0) then tmp2(b)=0
  b=where(abs(pdeg1-tmp1[0]) le 2*sqrt(tmp1[1]),bnum)
  if (bnum lt 1) then print,pdeg1, tmp1
  if (bnum gt 1) then pdeg1t = pdeg1(where(abs(pdeg1-tmp1[0]) le 2*sqrt(tmp1[1])))
  b=where(abs(pdeg2-tmp2[0]) le 2*sqrt(tmp2[1]),bnum)
  if (bnum gt 1) then pdeg2t = pdeg2(where(abs(pdeg2-tmp2[0]) le 2*sqrt(tmp2[1])))

  if (n_elements(pdeg1t) gt 1) then begin
    coeff1 = moment(pdeg1t)
  endif else begin
    ;coeff1 = [pdeg1t[0], 0]
    coeff1 = [0, 0]
  endelse
  if (n_elements(pdeg2t) gt 1) then begin
    coeff2 = moment(pdeg2t)
  endif else begin
    ;coeff2 = [pdeg2t[0], 0]
    coeff2 = [0, 0]
  endelse

  ; write to file, to be picked up by fitting function
  get_lun, tunit
  openw, tunit, './psf_coeff.out'
  coeff1(0)=2.07e-5  ; let's make these constant for everyone
  coeff2(0)=2.88e-5  ; acis-i and acis-s are not fitting for some reason
  printf, tunit, coeff1[0]
  printf, tunit, coeff2[0]
                          ; 5.dec.2003 bds
  free_lun, tunit
  ; refigure fit
  j = 0 ; mthtab indexer
  ptime=fltarr(1)
  pdeg0=fltarr(1)
  pdeg1=fltarr(1)
  pdeg2=fltarr(1)
  while (j lt nummth) do begin
    b = where(sdom(intab.start) ge mthtab(j).start and sdom(intab.start) lt mthtab(j).stop, num)
    mthtab(j).num = num
    print, "psf_anal days ", mthtab(j).start, " n_elements ", n_elements(b) ;debug
    if (mthtab(j).num ge 1) then begin
      if (n_elements(intab(b).dist) gt 1) then begin
        data = 1
        weights = replicate([1.0], n_elements(b))
        A_coeff = [0.5]
        A_test=A_coeff
        fitline=[0]
        fitline = curvefit(intab(b).dist, intab(b).psf, $
                  weights, A_coeff, function_name='fit_funct')
        print, "initial ",A_test(0)," fit ",A_coeff(0) ; debug
        ptime=[ptime, (mthtab(j).start+mthtab(j).stop)/2]
        pdeg0=[pdeg0, A_coeff(0)]
        print,pdeg0 ;debug
        pdeg1=[pdeg1, coeff1[0]]
        pdeg2=[pdeg2, coeff2[0]]
        ;perr0=[perr0, fiterr(0)]
        ;perr1=[perr1, fiterr(1)]
        ;perr2=[perr2, fiterr(2)]
        mthtab(j).coeff0 = A_coeff(0)
        mthtab(j).coeff1 = coeff1[0]
        mthtab(j).coeff2 = coeff2[0]
        print, mthtab(j).start, " ", fit, " ", fiterr
        a = sort(intab(b).dist)
        plot, intab(b(a)).dist, fitline(a), $
             xticks = 4, $
             xtitle = 'off axis distance (arcsec)', ytitle = 'PSF (arcsec)', $
             title = label+' DOM '+strtrim(mthtab(j).start,2)+' to '+strtrim((mthtab(j).stop),2), $
             xrange=[0,400], $
             yrange=[0, 6], $
             ;yrange=[0, max(intab(b).psf)+0.2], $
             ystyle = 1, xstyle = 1, background = 255, color = 0, $
             charsize = 2, charthick =2
        oplot, intab(b).dist, intab(b).psf, psym = 7, color=90
        xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
        write_gif, label+'_d_t'+strtrim(mthtab(j).name,2)+'_psf.gif', tvrd()
      endif
    endif
    j = j+1
  endwhile
endif

if (data eq 1) then begin
  tspan = max(ptime[1:*]) - min(ptime[1:*])
  ;xmin = min(ptime[1:*]) - tspan/10
  xmin = 0
  xmax = max(ptime[1:*]) + tspan/10
  print, "XMAX XMAX XMAX ",xmax
  plot, ptime[1:*], pdeg0[1:*], psym=7, $
       xticks = 4, $
       xtitle = 'DOM', ytitle = 'On-axis PSF (arcsec)', $
       title = 'Focus Trend for '+label, $
       xrange=[xmin,xmax], min_value=0.0001, $
       ;yrange=[0.5, 0.80], $
       ;ystyle = 1, xstyle = 1, background = 255, color = 0, $
       ystyle = 1, xstyle = 1, background = 0, color = 255, $
       charsize = 2, charthick =2
  ;errplot, ptime[1:*], pdeg0[1:*]-sqrt(perr0[1:*]), pdeg0[1:*]+sqrt(perr0[1:*])
  ;xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
  xyouts, 1.0, 0.0, systime(), alignment = 1, color = 255, /normal
  write_gif, label+'_d_t_psf_0.gif', tvrd()
  print, "pdeg0 again ",pdeg0 ;debug
  plot, ptime[1:*], pdeg1[1:*], psym=7, $
       xticks = 4, $
       xtitle = 'DOM', ytitle = 'degree 1 coefficient', $
       title = label, $
       xrange=[xmin,xmax], $
       ;ystyle = 1, xstyle = 1, background = 255, color = 0, $
       ystyle = 1, xstyle = 1, background = 0, color = 255, $
       charsize = 2, charthick =2
  ;errplot, ptime[1:*], pdeg1[1:*]-sqrt(perr1[1:*]), pdeg1[1:*]+sqrt(perr1[1:*])
  ;xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
  xyouts, 1.0, 0.0, systime(), alignment = 1, color = 255, /normal
  write_gif, label+'_d_t_psf_1.gif', tvrd()
  plot, ptime[1:*], pdeg2[1:*], psym=7, $
       xticks = 4, $
       xtitle = 'DOM', ytitle = 'degree 2 coefficient', $
       title = label, $
       xrange=[xmin,xmax], $
       ;ystyle = 1, xstyle = 1, background = 255, color = 0, $
       ystyle = 1, xstyle = 1, background = 0, color = 255, $
       charsize = 2, charthick =2
  ;errplot, ptime[1:*], pdeg2[1:*]-sqrt(perr2[1:*]), pdeg2[1:*]+sqrt(perr2[1:*])
  ;xyouts, 1.0, 0.0, systime(), alignment = 1, color = 0, /normal
  xyouts, 1.0, 0.0, systime(), alignment = 1, color = 255, /normal
  write_gif, label+'_d_t_psf_2.gif', tvrd()

  ; make web page
  get_lun, hunit
  openw, hunit, label+'_psf_time.html'
  printf, hunit, "<html>"
  printf, hunit, "<title>MTA "+label+" SRC2 Monitoring Page</title>"
  printf, hunit, '<body TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#FF0000" VLINK="#FFFF22" ALINK="#7500FF">'

  printf, hunit, "<center>"
  printf, hunit, "<H1>MTA "+label+" SRC2 Monitoring<BR></H1>"
  printf, hunit, "<H2>PSF vs. Time</H2>"
  printf, hunit, "</center>"
 
  printf, hunit, "<H4>A degree 2 polynomial is fit to detected sources' "
  printf, hunit, "PSF vs. DOM each month."
  printf, hunit, "The polynominal is then refit, keeping the first "
  printf, hunit, "and second degree coefficients fixed while fitting "
  printf, hunit, "the constant as a focus quality metric."
  printf, hunit, "Below are the coefficients determined for each year.
  printf, hunit, "Also shown are monthly plots of PSF vs. Off-axis source "
  printf, hunit, "centroid distance."
  printf, hunit, "</H4><br>"

  printf, hunit, "<center><table border=0>"
  printf, hunit, "<tr><td><table cellpadding=2 border=1>"
  printf, hunit, "<tr><th>Year</th><th>Coeff2</th><th>Coeff1</th><th>Coeff0</th><th>N</th></tr>"
;
;--- limit only to  up to this year
;

  nummth = uint(strmid(systime(0), 20,23)) -1999



  print, "pdeg0 again2 ",pdeg0 ;debug
  for i = 0, nummth-1 do begin
    printf, hunit, "<tr><td>"+mthtab(i).name+"</td><td>", mthtab(i).coeff2, "</td><td>", mthtab(i).coeff1, "</td><td>", mthtab(i).coeff0, "</td><td>", mthtab(i).num, "</td></tr>"
  endfor
  printf, hunit, "</table></td>"

  printf, hunit, '<td><table border=0>'
  printf, hunit, '<tr><td><a HREF="'+label+'_d_t_psf_0.gif"><img SRC="'+label+'_d_t_psf_0.gif" height=250 width=400></a></td></tr>'
   printf, hunit, '<tr><td><a HREF="./'+label+'_d_psf.gif"><img SRC="'+label+'_d_psf.gif" height=250 width=400></a></td></tr>'
  ; printf, hunit, '<tr><td><a HREF="'+label+'_d_t_psf_1.gif"><img SRC="'+label+'_d_t_psf_1.gif" height=145 width=300></a></td></tr>'
  ; printf, hunit, '<tr><td><a HREF="'+label+'_d_t_psf_2.gif"><img SRC="'+label+'_d_t_psf_2.gif" height=145 width=300></a></td></tr>'
  printf, hunit, '</td></tr></table></table><br>'

  ; print monthly graphs in two columns
  printf, hunit, "<table border=0>"
  newrow = 1
  for i = 0, nummth-1 do begin
    if (newrow eq 1) then begin
      printf, hunit, '<tr><td><a HREF="'+label+'_d_t'+strtrim(mthtab(i).name,2)+'_psf.gif"><img SRC="'+label+'_d_t'+strtrim(mthtab(i).name,2)+'_psf.gif" height=290 width=410></a></td>'
      newrow = 0
    endif else begin
      printf, hunit, '<td><a HREF="'+label+'_d_t'+strtrim(mthtab(i).name,2)+'_psf.gif"><img SRC="'+label+'_d_t'+strtrim(mthtab(i).name,2)+'_psf.gif" height=290 width=410></a></td></tr>'
      newrow = 1
    endelse
  endfor

  printf, hunit, "</table></body></html>"
    
  free_lun, hunit, /force
endif
  
end

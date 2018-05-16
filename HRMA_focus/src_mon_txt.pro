PRO SRC_MON_TXT, startpar, endpar, TREND = trend, INFILE=infile
;  -can supply startpar and endpar in format yyyy:doy
;    to run subset of data
;  -keyword trend runs trending analysis as well
; list level2 src fits files to be in used in file src_mon.lst

; this version reads data from src_mon.txt instead of *src2.fits
;  src_mon.txt formated 3 lines/source

set_plot, 'Z'

; start here
if (NOT keyword_set(infile)) then infile = 'src_mon.txt'
  
numsrc = filelen(infile)
get_lun, iunit
openr, iunit, infile
array = strarr(numsrc)
readf, iunit, array
free_lun, iunit

a = {tab, obsid: 0, start: 0.0, stop: 0.0, simx: 0.0, simz: 0.0, $
         x: 0.0, y: 0.0, snr: 0.0, ravg: 0.0, rnd: 0.0, $
         rotang: 0.0, psf: 0.0, dist: 0.0, angd: 0.0}
srctab = replicate({tab}, (numsrc/3)-1)

j = 0L  ; srctab indexer
for i = 3L, numsrc-1, 3 do begin
;print, "readline ",i
  line = fltarr(5)
  line = strsplit(array(i), " ", /extract)
  srctab(j).obsid = (line(0))
  srctab(j).start = float(line(1))
  srctab(j).stop  = float(line(2))
  srctab(j).simx  = float(line(3))
  srctab(j).simz  = float(line(4))
  line = fltarr(5)
  line = strsplit(array(i+1), " ", /extract)
  srctab(j).x     = float(line(0))
  srctab(j).y     = float(line(1))
  srctab(j).snr   = float(line(2))
  srctab(j).ravg  = float(line(3))
  srctab(j).rnd   = float(line(4))
  line = fltarr(5)
  line = strsplit(array(i+2), " ", /extract)
  srctab(j).rotang = float(line(0))
  srctab(j).psf    = float(line(1))
  srctab(j).dist   = float(line(2))
  srctab(j).angd   = float(line(3))
  ; convert distance from pixels to arcsec
  if (srctab(j).simz lt 0) then begin
    srctab(j).dist = srctab(j).dist * 0.492
    srctab(j).psf = srctab(j).psf * 0.492
  endif
  if (srctab(j).simz gt 0) then begin
    srctab(j).dist = srctab(j).dist * 0.13175
    srctab(j).psf = srctab(j).psf * 0.13175
  endif

  j = j + 1
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; send sub-sources to testme, for closer scrutiny if necessary
;  write your own testme.pro
;testme, srctab 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; add snr filter
srctab = srctab(where(srctab.snr gt 15))
;srctab = srctab(where(srctab.rnd gt 1.6))

; plots of all sources
do_plots, srctab, 'all'
do_plots, srctab, 'acis-i'
do_plots, srctab, 'acis-s'
do_plots, srctab, 'hrc-i'
do_plots, srctab, 'hrc-s'

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

;print, srctab(uniq(srctab.simx, sort(srctab.simx))).simx
;print, srctab(uniq(srctab.simz, sort(srctab.simz))).simz

end

PRO SRC_MON, startpar, endpar, TREND = trend, INFILE=infile
;  -can supply startpar and endpar in format yyyy:doy
;    to run subset of data
;  -keyword trend runs trending analysis as well
; list level2 src fits files to be in used in file src_mon.lst
; writes output to src_mon.tab for inclusion in src_mon.txt
;  then use src_mon_txt.pro for analysis

;set_plot, 'Z'
listfile = 'src_mon.lst'
; set up ftools
;fpath = '/proj/cm/DS.ots/ftools.v4.2.SunOS5.6/SunOS_5.6_sparc/bin'
;fpath = '/proj/cm/DS.ots/ftools.v5.0.1.SunOS5.8/SunOS_5.8_sparc/bin'
; change to dm tools
fpath = '/home/ascds/DS.release/bin/dmlist'
;fpath = '/proj/cm/DS.ots/ftools.v5.2.SunOS5.8/SunOS_5.8_sparc/bin'
; also need to setenv PFILES and mkdir param ...
;  (for now just set manually ie. source ~/.ascrc
;setenv, "PFILES=./param;/proj/cm/DS.ots/ftools.v4.2.SunOS5.6/SunOS_5.6_sparc/bin"
;setenv, "PFILES=./param;/proj/cm/DS.ots/ftools.v5.0.1.SunOS5.8/SunOS_5.8_sparc/syspfiles"
setenv, "PFILES=./param"
;setenv, "FTOOLS=/proj/DS.ots/ftools.v5.0.1.SunOS5.6/SunOS_5.6_sparc"
spawn, "mkdir param", err

get_lun, ounit
outfile = 'src_mon.out'
openw, ounit, outfile
print, " "
print, " See ", outfile, " for processing stats "
print, " "

;  filtering parameters
snr_lim = 6   ; signal to noise ratio threshold
;rmaj_lim = 15 ; source ellipse major axis threshold (pixels)
rmaj_hrc = 500 ; source ellipse major axis threshold (pixels)
rmaj_acis = 15 ; source ellipse major axis threshold (pixels)
defoc_lim = 0.01 ; defocus
printf, ounit, " "
printf, ounit, "I'll apply these filters ..."
printf, ounit, "Defoc threshold ", defoc_lim
printf, ounit, "SNR threshold ", snr_lim
printf, ounit, "RMAJ threshold for ACIS", rmaj_acis
printf, ounit, "RMAJ threshold for HRC", rmaj_hrc
printf, ounit, " "

xcol = 1
ycol = 2
snrcol = 3
rmajcol = 4
rmincol = 0
rotcol = 5
psfcol = 6

pi = 2 * asin(1)
;print, "pi = ", pi ;debug
 
; ************************** read data *************************
numobs = filelen(listfile)

get_lun, iunit
openr, iunit, listfile

files = strarr(numobs)
readf, iunit, files
free_lun, iunit

a = {tab, obsid: 0, start: 0.0, stop: 0.0, simx: 0.0, simz: 0.0, $
         x: 0.0, y: 0.0, snr: 0.0, ravg: 0.0, rnd: 0.0, $
         rotang: 0.0, psf: 0.0, dist: 0.0, angd: 0.0}
srctmp = replicate({tab}, numobs*500)

; get data
k = 0  ; srctmp index
total_src = 0L
for i = 0, numobs-1 do begin
  ; dump fits data
  printf, ounit, " "
  printf, ounit, "Reading ", files(i) ; debug
  ;command = fpath+'/fdump '+files(i)+' xtmpsrcdata wrap=yes pagewidth=256 prhead=yes columns="X,Y,SNR,R,ROTANG,PSFRATIO" rows=- clobber=yes'
  ;command = fpath+' "'+files(i)+'[cols X,Y,SNR,R,ROTANG,PSFRATIO]" data >! xtmpsrcdata'
  command = fpath+' "'+files(i)+'[cols X,Y,SNR,R,ROTANG,PSFRATIO]" header,data >! xtmpsrcdata'
  spawn, command, err
  printf, ounit, err

  ; read fits data
  numsrc = filelen('xtmpsrcdata')
  print, "numsrc ", numsrc
  get_lun, iunit
  ;array = dtrarr(numsrc)
  array = mrdfits(files(i),1,headstr)
  ;testif (n_elements(arrary) lt 2) then print, "skipping ", files(i), n_elements(array)
  ;testif (n_elements(arrary) gt 1) then begin
    free_lun, iunit
  ;  spawn, '/usr/bin/rm xtmpsrcdata', err
  
    ; read header, extract some stuff
    for j = 0, n_elements(headstr)-1 do begin
  print,i
      line = strsplit((strcompress(headstr(j),/remove_all)), '=', /extract)
      case (line(0)) of 
        'OBS_ID': begin
                    obsid = strsplit(line(1), "'", /extract)
                    printf, ounit, "OBS_ID ", obsid(0), " line ", j ; debug
                    end
        'TSTART': begin
                    time = strsplit(line(1), '/', /extract)
                    printf, ounit, "TSTART ", time(0), " line ", j ; debug
                    end
        'TSTOP': begin
                    tstop = strsplit(line(1), '/', /extract)
                    printf, ounit, "TSTOP ", tstop(0), " line ", j ; debug
                    end
        'SIM_X': begin
                    sim_x = strsplit(line(1), '/', /extract)
                    printf, ounit, "SIM_X ", sim_x(0), " line ", j ; debug
                    end
        'SIM_Z': begin
                    sim_z = strsplit(line(1), '/', /extract)
                    printf, ounit, "SIM_Z ", sim_z(0), " line ", j ; debug
                    end
        'DEFOCUS': begin
                    defoc = strsplit(line(1), '/', /extract)
                    printf, ounit, "DEFOCUS ", defoc(0), " line ", j ; debug
                    end
        'ROLL_NOM': begin
                    roll = strsplit(line(1), '/', /extract)
                    printf, ounit, "ROLL ", roll(0), " line ", j ; debug
                    end
        'END'   : begin
                    header = j       ; find end of header
                    printf, ounit, "END ", " line ", j
                    end
        else: next=1
      endcase
    endfor
    ; figure offsets
    xobsid = float(obsid(0))
    xstart = float(time(0))
    xstop = float(tstop(0))
    xsimx = float(sim_x(0))
    xsimz = float(sim_z(0))
    xdefoc = float(defoc(0))
    xroll = float(roll(0)) * pi / 180 ; convert to rad
    ; filter out defocussed observations
    skip = 0 
    if (abs(xdefoc) gt defoc_lim) then begin
      skip = 1
      numsrc = 0
      printf, ounit, "Defoc - dropped"
    endif

    case (1) of 
      (xsimz lt -210): begin ; acis-I
         zoff = (-233.6) - xsimz
         ;xref = 4137.2
         ;yref = zoff*0.024 + 4045.4 ; 0.024 mm/ pixel
         xref = 4096.5
         ;yref = zoff/0.024 + 4096.5
         yref = 4096.5
         scale = 0.492 ; arcsec/pix
         rmaj_lim=rmaj_acis
      end
      (xsimz lt -150 and xsimz gt -210): begin ; acis-S
         zoff = (-190.1) - xsimz
         ;xref = 4137.7
         ;yref = zoff*0.024 + 2233.8 ; 0.024 mm/ pixel
         xref = 4096.5
         ;yref = zoff/0.024 + 4096.5
         yref = 4096.5
         scale = 0.492 ; arcsec/pix
         rmaj_lim=rmaj_acis
      end
      (xsimz lt 200 and xsimz gt 100): begin ; hrc-I
         zoff = (126.99) - xsimz
         xref = 16384.5
         ;yref = zoff/0.006429 + 16384.5 ; 0.006429 mm/ pixel
         yref = 16384.5 ; 0.006429 mm/ pixel
         scale = 0.13175 ; arcsec/pix
         rmaj_lim=rmaj_hrc
      end
      (xsimz gt 200): begin ; hrc-S
         zoff = (250.1) - xsimz
         xref = 32768.5
         ;yref = zoff/0.006429 + 32768.5 ; 0.006429 mm/ pixel
         yref = 32768.5 ; 0.006429 mm/ pixel
         scale = 0.13175 ; arcsec/pix
         rmaj_lim=rmaj_hrc
      end
      else: begin 
        printf, ounit, "Not placed sim_z = ", xsimz
      end
    endcase
    printf, ounit, "Aimpoint (", xref, ",", yref, ")"
  
    printf, ounit, " "
    
    ; OK, forget all the previous section, use sky coords for now
    scale = 1
  
    ; read data table
    filt_cnt = 0
    pass_cnt = 0
    ; collect values
    if (n_elements(array) gt 5) then begin
      xx = array.x
      xy = array.y
      xsnr = array.snr
      xrmaj = array.r(0)
      xrmin = array.r(1)
      xravg = ((xrmaj + xrmin) / 2) * scale
      xrotang = array.rotang * 0.01745 ; convert to rads
      xpsfratio = array.psfratio
      xpsf = xravg/xpsfratio
      xrnd = xrmaj/xrmin
    endif
;
;--- the following line added 4/25/16 (ti)
;
    if (n_elements(array) le 5) then continue
  
    for j = 0, n_elements(array)-1  do begin
      total_src = total_src + 1
      ; get rid of INDEF
  ;    line = array(j)
  ;    while (((m = strpos(line, 'INDEF'))) ne -1) do $
  ;      strput, line, '99999', m
  ;    line1 = strsplit(line, ' ', /extract)
  ;    line = array(j+1)
  ;    while (((m = strpos(line, 'INDEF'))) ne -1) do $
  ;      strput, line, '99999', m
  ;    line2 = strsplit(line, ' ', /extract)
  
      ; filter sources (add parameters)
      filt_cnt = filt_cnt + 1
      skip = 0
      if (xsnr(j) lt snr_lim) then begin
        ;print, "snr ", xsnr, " vs. threshold ", snr_lim ; debug
        skip = 1
      endif
      if (xrmaj(j) gt rmaj_lim) then begin
        ;print, "xrmaj ", xrmaj, " vs. threshold ", rmaj_lim ; debug
        skip = 1
      endif
    
      if (skip eq 0) then begin 
        pass_cnt = pass_cnt + 1
        ; do some computations
  
        xdist=fltarr(n_elements(array))
        xangd=fltarr(n_elements(array))
        xdist(j) = scale * (sqrt((xx(j) - xref)^2 + (xy(j) - yref)^2))
        xangd(j) = atan((xy(j) - yref)/(xx(j) - xref))
        while (xangd(j) lt 0) do begin
          xangd(j) = xangd(j) + pi
        endwhile
        ;print, xy, xx, atan((xy-yref)/(xx - xref)), xangd ;debug
        ;xangd = atan((xx - xref)/(xy - yref)) + (pi/2)
        srctmp(k) = {tab, obsid: xobsid, start: xstart, stop: xstop, $
                        simx: xsimx, simz: xsimz, $
                        x: xx(j), y: xy(j), snr: xsnr(j), $
                        ravg: xravg(j), rnd: xrnd(j), $
                        rotang: xrotang(j), psf: xpsf(j), $
                        dist: xdist(j), angd: xangd(j)}
        k = k + 1
      endif
    endfor
    printf, ounit, " "
    printf, ounit, filt_cnt, " sources read ", pass_cnt, " pass filters"
;test  endif
  free_lun, iunit
endfor
printf, ounit, total_src, " total sources read ", k, " pass filters"
if (k ge 1) then begin
  srctab = srctmp(0:k-1)

  ; print output table (source list)
  srcfile = 'src_mon.tab'
  get_lun, srcunit
  openw, srcunit, srcfile
  ; apparentlt IDL does not write long lines, so make three
  printf, srcunit, "obsid start stop simx simz "
  printf, srcunit, "x y snr ravg rnd "
  printf, srcunit, "rotang psf dist angd"
  for i=0, n_elements(srctab)-1 do begin
    printf, srcunit, srctab(i).obsid, " ", srctab(i).start, " ", $
                     srctab(i).stop, " ", srctab(i).simx, " ", srctab(i).simz
    printf, srcunit, srctab(i).x, " ", srctab(i).y, " ", $
                     srctab(i).snr, " ", srctab(i).ravg, " ", $
                     srctab(i).rnd
    printf, srcunit, srctab(i).rotang, " ", $
                     srctab(i).psf, " ", srctab(i).dist, " ", srctab(i).angd
  endfor
  free_lun, srcunit
endif ; if (n_elements(srctmp) gt 0) then begin

end

PRO ede, label

; figure num lines input
xnum = strarr(1)
spawn, 'wc -l hegm1_'+label+'.txt', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'hegm1_'+label+'.txt'

marray = strarr(numlns)
readf, inunit, marray
free_lun, inunit

;filt_plot, array, 'HEGm1_'+label+''
;write_gif, 'hegm1_'+label+'.gif', tvrd()

; figure num lines input
xnum = strarr(1)
spawn, 'wc -l hegp1_'+label+'.txt', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'hegp1_'+label+'.txt'

parray = strarr(numlns)
readf, inunit, parray
free_lun, inunit

filt_plot, marray, parray, 'HEG_'+label+''
write_gif, 'heg_'+label+'.gif', tvrd()

; figure num lines input
xnum = strarr(1)
spawn, 'wc -l megm1_'+label+'.txt', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'megm1_'+label+'.txt'

marray = strarr(numlns)
readf, inunit, marray
free_lun, inunit

;filt_plot, array, 'MEGm1_'+label+''
;write_gif, 'megm1_'+label+'.gif', tvrd()

; figure num lines input
xnum = strarr(1)
spawn, 'wc -l megp1_'+label+'.txt', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'megp1_'+label+'.txt'

parray = strarr(numlns)
readf, inunit, parray
free_lun, inunit

;filt_plot, array, 'MEGp1_'+label+''
;write_gif, 'megp1_'+label+'.gif', tvrd()
filt_plot, marray,parray, 'MEG_'+label+''
write_gif, 'meg_'+label+'.gif', tvrd()

; figure num lines input
xnum = strarr(1)
spawn, 'wc -l legm1_'+label+'.txt', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'legm1_'+label+'.txt'

marray = strarr(numlns)
readf, inunit, marray
free_lun, inunit

;filt_plot, array, 'LEGm1_'+label+''
;write_gif, 'legm1_'+label+'.gif', tvrd()

; figure num lines input
xnum = strarr(1)
spawn, 'wc -l legp1_'+label+'.txt', xnum
xxnum = fltarr(2)
xxnum = strsplit(xnum(0),' ', /extract)
numlns = float(xxnum(0))

get_lun, inunit
openr, inunit, 'legp1_'+label+'.txt'

parray = strarr(numlns)
readf, inunit, parray
free_lun, inunit

;filt_plot, array, 'LEGp1_'+label+''
;write_gif, 'legp1_'+label+'.gif', tvrd()
filt_plot, marray, parray, 'LEG_'+label+''
write_gif, 'leg_'+label+'.gif', tvrd()

end

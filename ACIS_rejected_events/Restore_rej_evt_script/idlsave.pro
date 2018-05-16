; IDL Version 5.3 (sunos sparc)
; Journal File for mta@colossus
; Working directory: /data/mta/www/mta_acis_sci_run/Events_rej
; Date: Wed Aug 22 13:10:09 2001
 
head1=headfits('Data/acisf114621450N001_0_exr0.fits', exten=1)
print, head1(where(strpos(h1, 'CCD_ID') ne -1))
;CCD_ID  =                    6 / CCD ID: 0-9                                    
print, head1(where(strpos(head1, 'CCD_ID') ne -1))
;CCD_ID  =                    6 / CCD ID: 0-9                                    

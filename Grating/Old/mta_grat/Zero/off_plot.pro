PRO OFF_PLOT, indata

name = strlowcase(indata(0).inst)+'_'+strlowcase(indata(0).grat)

plot, indata.xoff, indata.xchip, psym = 2, $
      title='off_'+name+'_xchip',$
      xtitle='offset (arcmin)', ytitle='chip coor', $
      ystyle=1, xstyle=1, background=255, color=0
write_gif, 'off_'+name+'_xchip.gif', tvrd()

plot, indata.yoff, indata.ychip, psym = 2, $
      title='off_'+name+'_ychip',$
      xtitle='offset (arcmin)', ytitle='chip coor', $
      ystyle=1, xstyle=1, background=255, color=0
write_gif, 'off_'+name+'_ychip.gif', tvrd()

end

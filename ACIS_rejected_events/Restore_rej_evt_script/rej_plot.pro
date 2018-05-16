PRO REJ_PLOT, PLOTX=plotx

; set up plots
npanes = 6
top_marg=2
bot_marg=4
lft_marg=11
rgt_marg=14
; set ymargins for equal sized windows
top = reverse(top_marg - (findgen(npanes)*(top_marg+bot_marg)/npanes))
bot = bot_marg - (findgen(npanes)*(top_marg+bot_marg)/npanes)
top = [top(npanes-1), top[0:npanes-2]]
bot = [bot(npanes-1), bot[0:npanes-2]]

!p.multi=[0, 1, npanes, 0, 0]
 
if (keyword_set(plotx)) then begin
  set_plot, 'X'
  window, 0, xsize=700, ysize=700
endif else begin
  set_plot, 'Z'
  device, set_resolution = [700, 700]
endelse

loadct, 39
white = 255
bgrd = 0
  
;ccd_id = [0,1,2,3,4,5,6,7,8,9]
ccd_id = [0,1,2,3,4,5,6,7,8,9]

for i = 0, n_elements(ccd_id) - 1 do begin
  rdfloat, strcompress("CCD"+string(ccd_id(i))+"_rej.dat", /remove_all), $
                    time, sent, sent_sd, amp, amp_sd, $
                    pos, pos_sd, grd, grd_sd, thr, thr_sd, sum, sum_sd, $
                    Navg, obs, ccd, $
                    skipline=1

  xmin = cxtime(min(time))
  xmax = cxtime(max(time))
  xmin = xmin - 0.05*(xmax-xmin)
  ;xmin = -1
  xmax = max([xmax + 0.05*(xmax-xmin), 200])

  ; make decent x axis labels
  t_mark = intarr(1)
  for j = 100, xmax, 100 do begin
    t_mark = [t_mark, j]
  endfor
  while (n_elements(t_mark) gt 10) do begin
    t_mark = (t_mark[0:fix(n_elements(t_mark)/2)])*2
  endwhile
  
  ; first, filter out outliers
  m = moment(sent)
  b = where(sent le m(0)+2.5*sqrt(m(1)) and obs lt 50000)
  if (n_elements(b) le 1) then b = where(obs lt 50000)
  plot, cxtime(time(b)), sent(b), psym = 1, $
        ;xtitle = 'time (MET)', $
        title = "CCD "+string(ccd_id(i)), $
        ytitle = 'EVTSENT', $
        ystyle = 1, xstyle = 1, $
        yrange = [0, 80], $
        xrange = [xmin, xmax], $
        xmargin= [lft_marg, rgt_marg], $
        ymargin= [bot(!p.multi(0)), top(!p.multi(0))], $
        charsize = 1.8, charthick =1, color = white, background = bgrd, $
        xtickformat='no_axis_labels', xminor=10, $
        xtickv=t_mark, xticks=n_elements(t_mark)-1
   
  m = moment(amp)
  b = where(amp le m(0)+2.5*sqrt(m(1)) and obs lt 50000)
  if (n_elements(b) le 1) then b = where(obs lt 50000)
  plot, cxtime(time(b)), amp(b), psym = 1, $
        ;xtitle = 'time (MET)', $
        ytitle = 'DROP_AMP', $
        ystyle = 1, xstyle = 1, $
        xrange = [xmin, xmax], $
        xmargin= [lft_marg, rgt_marg], $
        ymargin= [bot(!p.multi(0)), top(!p.multi(0))], $
        charsize = 1.8, charthick =1, color = white, background = bgrd, $
        xtickformat='no_axis_labels', xminor=10, $
        xtickv=t_mark, xticks=n_elements(t_mark)-1
  
  m = moment(pos)
  b = where(pos le m(0)+2.5*sqrt(m(1)) and obs lt 50000)
  if (n_elements(b) le 1) then b = where(obs lt 50000)
  plot, cxtime(time(b)), pos(b), psym = 1, $
        ;xtitle = 'time (MET)', $
        ytitle = 'DROP_POS', $
        ystyle = 1, xstyle = 1, $
        xrange = [xmin, xmax], $
        xmargin= [lft_marg, rgt_marg], $
        ymargin= [bot(!p.multi(0)), top(!p.multi(0))], $
        charsize = 1.8, charthick =1, color = white, background = bgrd, $
        xtickformat='no_axis_labels', xminor=10, $
        xtickv=t_mark, xticks=n_elements(t_mark)-1
  
  m = moment(grd)
  b = where(grd le m(0)+2.5*sqrt(m(1)) and obs lt 50000)
  if (n_elements(b) le 1) then b = where(obs lt 50000)
  plot, cxtime(time(b)), grd(b), psym = 1, $
        ;xtitle = 'time (MET)', $
        ytitle = 'DROP_GRD', $
        ystyle = 1, xstyle = 1, $
        xrange = [xmin, xmax], $
        xmargin= [lft_marg, rgt_marg], $
        ymargin= [bot(!p.multi(0)), top(!p.multi(0))], $
        charsize = 1.8, charthick =1, color = white, background = bgrd, $
        xtickformat='no_axis_labels', xminor=10, $
        xtickv=t_mark, xticks=n_elements(t_mark)-1
  
  m = moment(thr)
  b = where(thr le m(0)+2.5*sqrt(m(1)) and obs lt 50000)
  if (n_elements(b) le 1) then b = where(obs lt 50000)
  plot, cxtime(time(b)), thr(b), psym = 1, $
        ;xtitle = 'time (MET)', $
        ytitle = 'THR_PIX', $
        ystyle = 1, xstyle = 1, $
        xrange = [xmin, xmax], $
        xmargin= [lft_marg, rgt_marg], $
        ymargin= [bot(!p.multi(0)), top(!p.multi(0))], $
        charsize = 1.8, charthick =1, color = white, background = bgrd, $
        xtickformat='no_axis_labels', xminor=10, $
        xtickv=t_mark, xticks=n_elements(t_mark)-1
  
  m = moment(sum)
  b = where(sum le m(0)+2.5*sqrt(m(1)) and obs lt 50000)
  if (n_elements(b) le 1) then b = where(obs lt 50000)
  plot, cxtime(time(b)), sum(b), psym = 1, $
        xtitle = 'time (MET)', $
        ytitle = 'BERR_SUM', $
        ystyle = 1, xstyle = 1, $
        xrange = [xmin, xmax], $
        xmargin= [lft_marg, rgt_marg], $
        ymargin= [bot(!p.multi(0)), top(!p.multi(0))], $
        charsize = 1.8, charthick =1, color = white, background = bgrd, $
        xminor=10, $
        xtickv=t_mark, xticks=n_elements(t_mark)-1
  
  xyouts, 1.0, 0.0, systime(), alignment = 1, color = 255, /normal
  write_gif, strcompress("CCD"+(string(ccd_id(i)))+"_rej_obs.gif", /remove_all), tvrd()
   
  ; first, filter out outliers
  m = moment(sent)
  b = where(sent le m(0)+2.5*sqrt(m(1)) and obs gt 50000)
  if (n_elements(b) le 1) then b = where(obs gt 50000)
  plot, cxtime(time(b)), sent(b), psym = 1, $
        ;xtitle = 'time (MET)', $
        title = "CCD "+string(ccd_id(i)), $
        ytitle = 'EVTSENT', $
        ystyle = 1, xstyle = 1, $
        xrange = [xmin, xmax], $
        xmargin= [lft_marg, rgt_marg], $
        ymargin= [bot(!p.multi(0)), top(!p.multi(0))], $
        charsize = 1.8, charthick =1, color = white, background = bgrd, $
        xtickformat='no_axis_labels', xminor=10, $
        xtickv=t_mark, xticks=n_elements(t_mark)-1
   
  m = moment(amp)
  b = where(amp le m(0)+2.5*sqrt(m(1)) and obs gt 50000)
  if (n_elements(b) le 1) then b = where(obs gt 50000)
  plot, cxtime(time(b)), amp(b), psym = 1, $
        ;xtitle = 'time (MET)', $
        ytitle = 'DROP_AMP', $
        ystyle = 1, xstyle = 1, $
        xrange = [xmin, xmax], $
        xmargin= [lft_marg, rgt_marg], $
        ymargin= [bot(!p.multi(0)), top(!p.multi(0))], $
        charsize = 1.8, charthick =1, color = white, background = bgrd, $
        xtickformat='no_axis_labels', xminor=10, $
        xtickv=t_mark, xticks=n_elements(t_mark)-1
  
  m = moment(pos)
  b = where(pos le m(0)+2.5*sqrt(m(1)) and obs gt 50000)
  if (n_elements(b) le 1) then b = where(obs gt 50000)
  plot, cxtime(time(b)), pos(b), psym = 1, $
        ;xtitle = 'time (MET)', $
        ytitle = 'DROP_POS', $
        ystyle = 1, xstyle = 1, $
        xrange = [xmin, xmax], $
        xmargin= [lft_marg, rgt_marg], $
        ymargin= [bot(!p.multi(0)), top(!p.multi(0))], $
        charsize = 1.8, charthick =1, color = white, background = bgrd, $
        xtickformat='no_axis_labels', xminor=10, $
        xtickv=t_mark, xticks=n_elements(t_mark)-1
  
  m = moment(grd)
  b = where(grd le m(0)+2.5*sqrt(m(1)) and obs gt 50000)
  if (n_elements(b) le 1) then b = where(obs gt 50000)
  plot, cxtime(time(b)), grd(b), psym = 1, $
        ;xtitle = 'time (MET)', $
        ytitle = 'DROP_GRD', $
        ystyle = 1, xstyle = 1, $
        xrange = [xmin, xmax], $
        xmargin= [lft_marg, rgt_marg], $
        ymargin= [bot(!p.multi(0)), top(!p.multi(0))], $
        charsize = 1.8, charthick =1, color = white, background = bgrd, $
        xtickformat='no_axis_labels', xminor=10, $
        xtickv=t_mark, xticks=n_elements(t_mark)-1
  
  m = moment(thr)
  b = where(thr le m(0)+2.5*sqrt(m(1)) and obs gt 50000)
  if (n_elements(b) le 1) then b = where(obs gt 50000)
  plot, cxtime(time(b)), thr(b), psym = 1, $
        ;xtitle = 'time (MET)', $
        ytitle = 'THR_PIX', $
        ystyle = 1, xstyle = 1, $
        xrange = [xmin, xmax], $
        xmargin= [lft_marg, rgt_marg], $
        ymargin= [bot(!p.multi(0)), top(!p.multi(0))], $
        charsize = 1.8, charthick =1, color = white, background = bgrd, $
        xtickformat='no_axis_labels', xminor=10, $
        xtickv=t_mark, xticks=n_elements(t_mark)-1
  
  m = moment(sum)
  b = where(sum le m(0)+2.5*sqrt(m(1)) and obs gt 50000)
  if (n_elements(b) le 1) then b = where(obs gt 50000)
  plot, cxtime(time(b)), sum(b), psym = 1, $
        xtitle = 'time (MET)', $
        ytitle = 'BERR_SUM', $
        ystyle = 1, xstyle = 1, $
        xrange = [xmin, xmax], $
        xmargin= [lft_marg, rgt_marg], $
        ymargin= [bot(!p.multi(0)), top(!p.multi(0))], $
        charsize = 1.8, charthick =1, color = white, background = bgrd, $
        xminor=10, $
        xtickv=t_mark, xticks=n_elements(t_mark)-1
  
  xyouts, 1.0, 0.0, systime(), alignment = 1, color = 255, /normal
  write_gif, strcompress("CCD"+(string(ccd_id(i)))+"_rej_cti.gif", /remove_all), tvrd()
   
endfor
end

; define fls=file_search('../')
; define out_dir = 'folder_path/'

.r findlocalmaxima
.r wtmm
fls = sort_fls(fls)
window, xs=1024,ys=1024
run_algorithms_edges_tvscl, fls, out_dir, pa_total
clean_pa_total, pa_total, 13
separate_pa_total, pa_total, detection_info
find_pa_heights, pa_total, detection_info
restore, 'all_h0.sav'
mreadfits_corimp, fls, in
combine_pa_heights2,in,heights,image_no,pos_angles

; pngs = file_search(outdir+'/*png')
; plot_pa_heights_independent, pngs, in, image_no, heights, pos_angles, temp  <-- not necessary just outputs (large) array of imaged detections along pos_angles.
; .r hist_equal
; .r make_movie
; make_movie, temp, 'out_dir'


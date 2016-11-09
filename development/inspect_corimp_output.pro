;Created	2012-05-23	to look specifically at the output of CORIMP and see how it compares to manual interpretation of the detected CMEs.


pro inspect_corimp_output

fls=file_search('~/postdoc/automation/work_on_solarwind/20100227-0305/det_stack*')

pa_total = combine_det_stacks(fls)

clean_pa_total, pa_total, pa_mask

pa_total *= pa_mask

delvarx, pa_mask

det_fls=file_Search('~/postdoc/automation/work_on_solarwind/20100227-0305/dets_*')





end

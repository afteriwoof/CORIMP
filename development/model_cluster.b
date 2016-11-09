; Batch file to look at model CMEs from completely automated detection to output of kinematics via clustering methods.

fls = file_search('~/Postdoc/Automation/Test/multicme_model/*fits*')

; Model is too clean to use the new codes, so use old ones of just outermost front
;run_automated_new_model, fls, '../multicme_model_cluster/detections_dublin/new'
run_automated_mode, fls, '../multicme_model_cluster/detections_dublin'





; Created	2013-01-30	to export the IDL structure of CME info to an XML file.

; Last edited	2013-02-05	to update the entries as per emails with Ryan.
;		2013-02-06	to include out_dir for where to save output xml file.

; INPUTS:	fl_in		- the file the restore, containing the CME kinematics info.

pro ce_xml, fl_in, out_dir

restore, fl_in ; restores cme_kins structure

; Create IDL structure for a CME event
event = struct4event('ce')

; Populate the structure with required values
event.required.OBS_Observatory = 'SOHO'
event.required.OBS_Instrument = 'LASCO'
event.required.OBS_ChannelID = 'C2 orange filter, C3 clear filter'
event.required.OBS_MeanWavel = '600'
event.required.OBS_WavelUnit = 'nm'
event.required.FRM_Name = 'CORIMP'
event.required.FRM_Identifier = 'jbyrne'
event.required.FRM_Institute = 'IfA'
event.required.FRM_HumanFlag = 'F'
event.required.FRM_ParamSet = '0'
event.required.FRM_DateRun = anytim(sys2ut(),/ccsds)
event.required.FRM_Contact = 'jbyrne at ifa dot hawaii dot edu'
event.required.FRM_URL = 'http://solar.physics.montana.edu/sol_phys/fft/fft-modules/cme-detection-module'
event.required.Event_StartTime = cme_kins.Event_StartTime
event.required.Event_EndTime = cme_kins.Event_EndTime
event.required.Event_CoordSys = 'UTC-HRC-TOPO'
event.required.Event_CoordUnit = '0'
event.required.Event_Coord1 = cme_kins.CME_CPA
event.required.Event_Coord2 = '2.2'
event.required.Event_C1Error = '0'
event.required.Event_C2Error = '0'
event.required.BoundBox_C1LL = cme_kins.CME_PosAng1
event.required.BoundBox_C2LL = '2.2'
event.required.BoundBox_C1UR = cme_kins.CME_PosAng2
event.required.BoundBox_C2UR = '25'

event.description = 'Beta version CORIMP CME detections'
event.reference_names[0] = 'Publication'
event.reference_names[1] = 'Publication'
event.reference_links[0] = 'http://adsabs.harvard.edu/abs/2012ApJ...752..144M'
event.reference_links[1] = 'http://adsabs.harvard.edu/abs/2012ApJ...752..145B'
event.reference_types[0] = 'html'
event.reference_types[1] = 'html'

event.required.CME_RadialLinVel = cme_kins.CME_RadialLinVel
event.required.CME_RadialLinVelUncert = '0' 
event.required.CME_RadialLinVelMax = cme_kins.CME_RadialLinVelMax
event.required.CME_RadialLinVelMin = cme_kins.CME_RadialLinVelMin
event.required.CME_RadialLinVelStddev = cme_kins.CME_RadialLinVelStddev
event.required.CME_RadialLinVelUnit = cme_kins.CME_RadialLinVelUnit
event.required.CME_AngularWidth = cme_kins.CME_AngularWidth
event.required.CME_AngularWidthUnit = cme_kins.CME_AngularWidthUnit
event.optional.CME_Accel = cme_kins.CME_Accel
event.optional.CME_AccelUnit = cme_kins.CME_AccelUnit

; Now export the IDL structure to an XML file
export_event, event, /write, outdir=out_dir

end

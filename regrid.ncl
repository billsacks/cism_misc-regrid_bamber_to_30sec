; Bill Sacks
; 9-5-12

; This script regrids the curvilinear bamber data to a regular, 30"
; regional output grid. It uses ESMF's bilinear interpolation,
; available starting in ncl version 6.1.0.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "~/ncl/reverse_dimensions.ncl"

begin
;******************** USER DEFINED VARIABLES***********************

  input_file_name="bamber_5km_converted.nc"

  ; included as an attribute in the output
  input_title="Bamber 5 km"

  ; all of the input variables to regrid
  ; Note: the input variables should all be on the same grid
  input_var_names=(/"pct_gic","pct_icesheet","usrf","landmask_float"/)
  ; which of the input variables should be masked by the landmask?
  input_do_mask  =(True      ,True          ,True/)

  ; input data are curvilinear, so lat & lon are specified by 2-d
  ; arrays, as given here:
  lat_var_name="lat"
  lon_var_name="lon"

  ; this variable provides the mask of input points: 0 where things
  ; are masked out (i.e., ocean), 1 elsewhere
  input_mask_name="landmask"

  ; is the input a regional file? (as opposed to a global file)
  input_is_regional = True

  source_large_file = False

  template_file_name="template_out.nc"

  template_var_name="ice_shelf"

  ; is the template a regional file? (as opposed to a global file)
  template_is_regional = True

  dest_large_file = True

  wgt_large_file = True

  output_file_name="bamber_30sec.nc"

  interp_method = "bilinear"

  ; set the following to true if the necessary files have already been
  ; generated
  skip_src_grid = True
  skip_dst_grid = True
  skip_wgt_grid = False

;*****************END OF USER DEFINIED VARIABLES*******************

;************************************************
; Error checking
;************************************************

if (dimsizes(input_var_names) .ne. dimsizes(input_do_mask)) then
  print("mismatch between sizes of input_var_names and input_do_mask")
  exit
end if

;************************************************
; Get template longitudes and latitudes
;************************************************

  template_file = addfile(template_file_name, "r")
  template_var = template_file->$template_var_name$
  dsizes = dimsizes(template_var)
  rank = dimsizes(dsizes)  ; number of dimensions
  
  template_lon_name = template_var!(rank-1)
  template_lat_name = template_var!(rank-2)
  template_lon = template_var&$template_lon_name$
  template_lat = template_var&$template_lat_name$
  
;************************************************
; Read in input file (not individual variables, yet)
;************************************************

  input_file = addfile(input_file_name, "r")
  lat2d = input_file->$lat_var_name$
  lon2d = input_file->$lon_var_name$
  input_mask = input_file->$input_mask_name$

;************************************************
; Set up output file
;************************************************

  output_file = addfile(output_file_name, "c")
  if (isfilevar(input_file, "time")) then
    filedimdef(output_file,"time",-1,True)  ; make 'time' the unlimited dimension
  end if

;************************************************
; Set regridding options
;************************************************

  Opt = True

  Opt@SrcGridLat = lat2d
  Opt@SrcGridLon = lon2d
  Opt@SrcRegional = input_is_regional
  Opt@SrcLargeFile = source_large_file
; according to the documentation, DstGridType shouldn't be required,
; but it seems to be
  Opt@DstGridType = "rectilinear"
  Opt@DstGridLat = template_lat
  Opt@DstGridLon = template_lon
  Opt@DstRegional = template_is_regional
  Opt@DstLargeFile = dest_large_file
  Opt@LargeFile = wgt_large_file

  Opt@SrcMask2D = input_mask

  Opt@InterpMethod = interp_method

  Opt@SrcFileName = "source_grid_file.nc"
  Opt@DstFileName = "destination_grid_file.nc"
  Opt@WgtFileName = "weights_file.nc"
  Opt@SkipSrcGrid = skip_src_grid
  Opt@SkipDstGrid = skip_dst_grid
  Opt@SkipWgtGrid = skip_wgt_grid

  Opt@SrcInputFileName=input_file_name
  Opt@SrcTitle=input_title
  Opt@CopyVarCoords = True
  Opt@ForceOverwrite = True
  Opt@Debug = True

;************************************************
; Main Loop:
; Loop through variables in input file,
; outputting the interpolated version to the output file
;************************************************

  numvars = dimsizes(input_var_names)
  do n = 0, numvars-1
    var_name=input_var_names(n)
    var = input_file->$var_name$

    var_regrid = ESMF_regrid(var,Opt)
    output_file->$var_name$ = var_regrid

    ; after the first variable, we can skip some steps in regridding
    ; the other variables; this is done via the following options:
    Opt@SkipSrcGrid = True
    Opt@SkipDstGrid = True
    Opt@SkipWgtGen = True

;************************************************
; Clean up: delete variables to prepare for next iteration
; (we need to do this because ncl doesn't handle
; changes in dimensionality of variables well)
;************************************************
    delete(var)
    delete(var_regrid)

  end do
end
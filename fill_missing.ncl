; Bill Sacks
; 9-10-12

; This script fills (extrapolates) missing data values as a precursor
; to bilinear interpolation. This prevents the spreading out of
; missing values that would happen if we tried to do interpolation on
; a map that included missing values; however, it means that some
; regridding values include extrapolated values.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;******************** USER DEFINED VARIABLES***********************

  ; some variables in this this file will be overwritten (i.e., it is
  ; opened for both input & output)
  file_name = "bamber_5km_converted_filled.nc"
  
  ; We fill gic & icesheet with nearest neighbor, but usrf with 0 (it
  ; seems reasonable to assume that usrf approaches 0 at the coast,
  ; but this is not necessarily the case for pct_gic and pct_icesheet)
  vars_to_fill_with_nearest_neighbor=(/"pct_gic","pct_icesheet"/)
  vars_to_fill_with_zero=(/"usrf"/)

  ; input data are curvilinear, so lat & lon are specified by 2-d
  ; arrays, as given here:
  lat_var_name="lat"
  lon_var_name="lon"

  ; option for nearest neighbor filling:
  ; mopt=0: use quick approximation to distance
  ; mopt=1: use more accurate (but slower) great circle distance
  ; formula
  mopt=1

;*****************END OF USER DEFINIED VARIABLES*******************

  fl = addfile(file_name, "w")
  lat2d = fl->$lat_var_name$
  lon2d = fl->$lon_var_name$
  lat1d = ndtooned(lat2d)
  lon1d = ndtooned(lon2d)

  print("Filling using nearest neighbor:")
  numvars = dimsizes(vars_to_fill_with_nearest_neighbor)
  do n = 0, numvars-1
    var_name=vars_to_fill_with_nearest_neighbor(n)
    print(var_name + "")
    var = fl->$var_name$
    var1d = ndtooned(var)

    Opt=True
    Opt@mopt = mopt
    var_fill = triple2grid2d(lon1d, lat1d, var1d, lon2d, lat2d, Opt)

    ; where var had missing values, use var_fill instead
    var = where(ismissing(var), var_fill, var)
    
    fl->$var_name$ = var
  end do

  print("Filling with zeros:")
  numvars = dimsizes(vars_to_fill_with_zero)
  do n = 0, numvars-1
    var_name=vars_to_fill_with_zero(n)
    print(var_name + "")
    var = fl->$var_name$
    var = where(ismissing(var), 0., var)

    fl->$var_name$ = var
  end do

end

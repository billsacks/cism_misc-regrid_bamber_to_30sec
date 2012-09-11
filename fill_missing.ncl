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
  
  vars_to_fill=(/"pct_gic","pct_icesheet","usrf"/)

  ; Is longitude cyclic? (generally true for global data, false otherwise)
  cyclic = False

  ; guess_type=0 means use 0.0 as initial guess; guess_type=1 means
  ; use zonal averages as initial guess. 1 is recommended. 1 gives
  ; some questionable values far from the coast, but I think that's okay.
  guess_type = 1

  ; max number of iterations used by relaxation
  nscan = 1500

  ; tolerance for ending relaxation before nscan limit (we scale this
  ; by the standard deviation of the variable)
  eps = 1.e-3

  ; relaxation constant
  relc = 0.6

;*****************END OF USER DEFINIED VARIABLES*******************

  fl = addfile(file_name, "w")

  numvars = dimsizes(vars_to_fill)
  do n = 0, numvars-1
    var_name=vars_to_fill(n)
    print(var_name + "")
    var = fl->$var_name$

    eps_scaled = eps * stddev(var)
    poisson_grid_fill(var, cyclic, guess_type, nscan, eps_scaled, relc, 0)
    fl->$var_name$ = var
  end do


end

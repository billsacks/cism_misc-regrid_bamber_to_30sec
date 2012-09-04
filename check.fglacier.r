# This script checks all of the existing mksrf_glacier files for there
# values below -79 N, to see how they treat the Ross ice shelf


dir <- '/glade/proj3/cseg/inputdata'

files <- c('lnd/clm2/rawdata/mksrf_glacier.060929.nc',
           'lnd/clm2/rawdata/mksrf_glacier.10min.c110719.nc',
### the following aren't currently used, but I list them anyway
           'lnd/clm2/rawdata/mksrf_glacier.050425.nc',
           'lnd/clm2/rawdata/mksrf_glacier_1870.060929.nc',
           'lnd/clm2/rawdata/mksrf_glacier.nc',
           'lnd/clm2/rawdata/mksrf_glacier_potveg.060929.nc')
           
for (fl in files) {
  print(fl)
  dat <- read.ncdf(paste(dir,'/',fl,sep=''), var.list=c('LATIXY','PCT_GLACIER','LANDMASK'))
  w <- which(dat$LATIXY$data <= -79)
  print(length(w)/length(dat$PCT_GLACIER$data))  # This should be about 0.061
  print(summary(dat$PCT_GLACIER$data[w]))        # If all goes well, should print all 100's for this summary
  print(summary(dat$LANDMASK$data[w]))           # If all goes well, should print all 1's for this summary
  cat('\n')
}

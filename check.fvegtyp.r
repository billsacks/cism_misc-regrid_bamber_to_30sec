# This script checks all of the fvegtyp files to make sure that they
# have data <= -79 -- if not, there could be problems when removing
# the Ross ice shelf correction code

dir <- '/glade/proj3/cseg/inputdata'

# For directories with multiple years, I'm just using one of the years
files <-
  c('lnd/clm2/rawdata/mksrf_crop_20pft/mksrf_20pft_0.5x0.5_rc2000_simyr1990s.c110321.nc',
### The following is 1x1: don't want this
###    'lnd/clm2/rawdata/pftdyn.testing.testyr1000-1004/mksrf_pft_1x1_tropicAtl_testyr1000_c090722.nc',
    'lnd/clm2/rawdata/pftdyn.testing.testyr1000-1004/mksrf_pft_10x15_testyr1000_c100614.nc',
    'lnd/clm2/rawdata/pftlandusedyn.0.5x0.5.simyr1850-2005.c090630/mksrf_landuse_rc1850_c090630.nc',
    'lnd/clm2/rawdata/pftlandusedyn.0.5x0.5.lastm.simyr0850-1850.c100522/mksrf_landuse_lastm0850_c100519.nc',
    'lnd/clm2/rawdata/pftlandusedyn.0.5x0.5.image.simyr2005-2100.c100121/mksrf_landuse_image2006_c100317.nc',
    'lnd/clm2/rawdata/pftlandusedyn.0.5x0.5.minicam.simyr2005-2100.c100121/mksrf_landuse_minicam2006_c100317.nc',
    'lnd/clm2/rawdata/pftlandusedyn.0.5x0.5.aim.simyr2005-2100.c100318/mksrf_landuse_aim2006_c100318.nc',
    'lnd/clm2/rawdata/pftlandusedyn.0.5x0.5.message.simyr2005-2100.c100121/mksrf_landuse_message2006_c100121.nc',
    'lnd/clm2/rawdata/pftlandusedyn.0.5x0.5.aim.ngwh.simyr2005-2100.c110602/mksrf_landuse_aim_2006_c110602.nc',
    'lnd/clm2/rawdata/pftlandusedyn.0.5x0.5.message.ngwh.simyr2005-2100.c110602/mksrf_landuse_message_2006_c110602.nc',
    'lnd/clm2/rawdata/pftlanduse.3minx3min.simyr2000.c110913/mksrf_landuse_rc2000_c110913.nc')

for (fl in files) {
  print(fl)
  dat <- read.ncdf(paste(dir,'/',fl,sep=''), var.list=c('LATIXY','PCT_PFT','LANDMASK'))
  w <- which(dat$LATIXY$data <= -79)
  sum.pct.pft <- apply(dat$PCT_PFT$data,c(1,2),sum)
  print(length(w)/length(sum.pct.pft))  # This should be about 0.061
  print(summary(sum.pct.pft[w]))        # If all goes well, should print all 100's for this summary
  print(summary(dat$LANDMASK$data[w]))  # If all goes well, should print all 1's for this summary
  cat('\n')
}

# Setup ----
library(ncdf4)
library(dplyr)

# Set working directory
setwd('Desktop/un_datathon_2023')

# Define datapath
datapath <- 'DATA/S5P/'

# Load nc datasets ----
nclat <- c()
nclon <- c()
ncno2 <- c()
ncno2prec <- c()
ctr <- 1
for (nc_fname in list.files(datapath)) {
  print(nc_fname)
  ncin <- nc_open(paste0(datapath, nc_fname))
  lon <- ncvar_get(ncin,"PRODUCT/longitude")
  lat <- ncvar_get(ncin,"PRODUCT/latitude")
  no2 <- ncvar_get(ncin,"PRODUCT/nitrogendioxide_tropospheric_column")
  no2prec <- ncvar_get(ncin,"PRODUCT/nitrogendioxide_tropospheric_column_precision")
  nclon <- c(nclon, unlist(lon))
  nclat <- c(nclat, unlist(lat))
  ncno2 <- c(ncno2, unlist(no2))
  ncno2prec <- c(ncno2prec, unlist(no2prec))
}

# Subset points ----
# Get points within bounding box of Brazil
# lat = [-35, 5], lon = [-75, -35]
bbox_bool <- between(nclat, -35, 5) & between(nclon, -75, -35)
sum(bbox_bool) # 596531 points in bounding box

nclon <- nclon[bbox_bool]
nclat <- nclat[bbox_bool]
ncno2 <- ncno2[bbox_bool]
ncno2prec <- ncno2prec[bbox_bool]

all(is.na(no2) == is.na(no2prec)) # NO2 is NA iff NO2 precision is NA
# Only keep points with non-NA NO2 readings
na_bool <- !is.na(ncno2)
nclon <- nclon[na_bool]
nclat <- nclat[na_bool]
ncno2 <- ncno2[na_bool]
ncno2prec <- ncno2prec[na_bool]

length(ncno2) # 5632650 points
# Check that lengths are all the same 
length(unique(c(length(nclon), length(nclat), length(ncno2), length(ncno2prec)))) == 1

# Plotting ----
# Plot all points - takes some time to run
# plot(nclon, nclat,
#      col = rgb(red = 0, green = 0, blue = 1, alpha = 0.2),
#      pch=19, cex=0.2,
#      xlab='longitude',
#      ylab='latitude')

# Plot sample of points
set.seed(42)
smp <- sample(1:length(nclon), 10000, replace=F)

plot(nclon[smp], nclat[smp],
     col = rgb(red = 0, green = 0, blue = 1, alpha = 0.2),
     pch=19, cex=0.2,
     xlab='longitude',
     ylab='latitude')

# Save dataframe ---- 
# mols per m^2
# multiply by 46 to get grams per m^2
no2_df <- data.frame('latitude' = nclat,
                     'longitude' = nclon,
                     'NO2gm' = ncno2*46,
                     'NO2mol' = ncno2,
                     'NO2mol_prec' = ncno2prec)

write.csv(no2_df, paste0('DATA/S5P_no2.csv'), row.names=TRUE)

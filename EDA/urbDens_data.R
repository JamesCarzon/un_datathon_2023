# Setup ----
library(ncdf4)
library(dplyr)
library(reshape2)
library(melt)
library(ggplot2)

# Set working directory
setwd('/Users/mayashen/Desktop/un_datathon_2023')

# Define datapath
datapath <- 'DATA/gpw-v4-population-density-rev11_totpop_2pt5_min_nc/'

# Load nc dataset ----
nc_fname <- 'gpw_v4_population_density_rev11_2pt5_min.nc'
ncin <- nc_open(paste0(datapath, nc_fname))
names(ncin$var)

lon <- ncvar_get(ncin,"longitude")
lat <- ncvar_get(ncin,"latitude")
popdens <- ncvar_get(ncin,"Population Density, v4.11 (2000, 2005, 2010, 2015, 2020): 2.5 arc-minutes")
dim(lon)
dim(lat)
dim(popdens)

# Investigate 5 slices ----
for (i in 1:5) {
  print(sum(!(is.na(popdens[,,i]))))
  print(unique(popdens[,,i][!is.na(popdens[,,i])])[1:10])
}

# Check that fifth slice is the most recent (2020)...?
for (i in 1:5) {
  popdensyr <- popdens[,,i]
  # popdensyr[is.na(popdensyr)] <- 0
  # Get points within bounding box of Brazil
  # lat = [-35, 5], lon = [-75, -35]
  lon_bbox_bool <- between(lon, -75, -35)
  lat_bbox_bool <- between(lat, -35, 5)
  
  lon_bbox <- lon[lon_bbox_bool]
  lat_bbox <- lat[lat_bbox_bool]
  popdensyr_bbox <- popdensyr[lon_bbox_bool, lat_bbox_bool]
  
  popdensyr_bbox_df <- melt(popdensyr_bbox)
  popdensyr_bbox_df$latitude <- lat_bbox[popdensyr_bbox_df$Var2]
  popdensyr_bbox_df$longitude <- lon_bbox[popdensyr_bbox_df$Var1]
  popdensyr_bbox_df$popdens <- popdensyr_bbox_df$value
  popdensyr_bbox_df <- popdensyr_bbox_df[, c('latitude', 'longitude', 'popdens')]
  
  popdensyr_bbox_df <- popdensyr_bbox_df[!is.na(popdensyr_bbox_df$popdens),]
  nrow(popdensyr_bbox_df)
  
  print(max(popdensyr_bbox_df$popdens))
  
  ggplot(data=popdensyr_bbox_df, aes(x=longitude, y=latitude, col=log(popdens))) +
    geom_point(size=0.2, alpha=0.5)
  ggsave(paste0('DATA/popdens_plots/', i, '_plot.png'),
         width=7.25,
         height=6.25,
         units='in',
         dpi=300)
}

# Get fifth slice ----
i <- 5
popdensyr <- popdens[,,i]

# Subset points 
# Get points within bounding box of Brazil
# lat = [-35, 5], lon = [-75, -35]
lon_bbox_bool <- between(lon, -75, -35)
lat_bbox_bool <- between(lat, -35, 5)

lon_bbox <- lon[lon_bbox_bool]
lat_bbox <- lat[lat_bbox_bool]
popdensyr_bbox <- popdensyr[lon_bbox_bool, lat_bbox_bool]

# Melt matrix into dataframe
popdensyr_bbox_df <- melt(popdensyr_bbox)
# Rename columns
popdensyr_bbox_df$latitude <- lat_bbox[popdensyr_bbox_df$Var2]
popdensyr_bbox_df$longitude <- lon_bbox[popdensyr_bbox_df$Var1]
popdensyr_bbox_df$popdens <- popdensyr_bbox_df$value
popdensyr_bbox_df <- popdensyr_bbox_df[, c('latitude', 'longitude', 'popdens')]

# Remove points with NA urban density values
popdensyr_bbox_df <- popdensyr_bbox_df[!is.na(popdensyr_bbox_df$popdens),]
nrow(popdensyr_bbox_df) # 676778 points

# Plot population density (log scale)
ggplot(data=popdensyr_bbox_df, aes(x=longitude, y=latitude, col=log(popdens))) +
  geom_point(size=0.2, alpha=0.5)

# Save dataframe ----
write.csv(popdensyr_bbox_df, paste0('DATA/urbDens.csv'), row.names=TRUE)

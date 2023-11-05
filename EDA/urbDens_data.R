# Setup ----
library(ncdf4)
library(dplyr)
library(melt)
library(ggplot2)

# Set working directory
setwd('/Users/mayashen/Desktop/un_datathon_2023')

# Load data ----
# Data downloaded from: https://search.earthdata.nasa.gov/search?fi=TROPOMI&fst0=Atmosphere&fsm0=Atmospheric%20Chemistry&fs10=Nitrogen%20Compounds
# Temporal Start:, Temporal End: TO DO: Ask James what date/time range we searched over
# TO DO: Add names of swathes we took 

# Define paths
datapath <- 'DATA/gpw-v4-population-density-rev11_totpop_2pt5_min_nc/'
savepath <- 'DATA/'

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
for (slice in 1:5) {
  print(sum(!(is.na(popdens[,,slice]))))
  print(unique(popdens[,,slice][!is.na(popdens[,,slice])])[1:10])
}

# Check that fifth slice is the most recent (2020)...?
for (slice in 1:5) {
  popdensyr <- popdens[,,slice]
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
  ggsave(paste0('DATA/popdens_plots/', slice, '_plot.png'),
         width=7.25,
         height=6.25,
         units='in',
         dpi=300)
}

# Get fifth slice ----
slice <- 5
popdensyr <- popdens[,,slice]

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

# Plot population density grouped according to web plots
# !! Warning: Takes a while to run !!
# https://sedac.ciesin.columbia.edu/data/set/gpw-v4-population-density-rev11/maps
t0 <- Sys.time()
pb <- txtProgressBar(min = 0,      # Minimum value of the progress bar
                     max = nrow(popdensyr_bbox_df), # Maximum value of the progress bar
                     style = 3,    # Progress bar style (also available style = 1 and style = 2)
                     width = 100,   # Progress bar width. Defaults to getOption("width")
                     char = "=")   # Character used to create the bar
cat_popdens <- c()
for (i in 1:nrow(popdensyr_bbox_df)) {
  setTxtProgressBar(pb, i)
  val <- popdensyr_bbox_df$popdens[i]
  if (val < 1) {
    cat_popdens <- c(cat_popdens, '<1')
  } else if ((val >= 1) & (val < 5)) {
    cat_popdens <- c(cat_popdens, '1-5')
  } else if ((val >= 5) & (val < 25)) {
    cat_popdens <- c(cat_popdens, '5-25')
  } else if ((val >= 25) & (val < 250)) {
    cat_popdens <- c(cat_popdens, '25-250')
  } else if ((val >= 250) & (val < 1000)) {
    cat_popdens <- c(cat_popdens, '250-1,000')
  } else if (val >= 1000) {
    cat_popdens <- c(cat_popdens, '>1,000')
  }
}
close(pb)
t1 <- Sys.time()
print(t1-t0)

popdensyr_bbox_df$popdens_cat <- factor(cat_popdens, levels=c('<1', '1-5', '5-25', '25-250', 
                                                              '250-1,000', '>1,000'))
# Optionally: Set own colors
library(RColorBrewer) 
palette <- brewer.pal(6,"YlOrRd")

ggplot(data=popdensyr_bbox_df, aes(x=longitude, y=latitude, col=popdens_cat)) +
  geom_point(size=0.2, alpha=0.5) +
  scale_color_manual(values = c('<1' = palette[1], 
                                '1-5' = palette[2], 
                                '5-25' = palette[3], 
                                '25-250' = palette[4], 
                                '250-1,000' = palette[5], 
                                '>1,000' = palette[6])) 
ggsave(paste0('DATA/popdens_plots/', slice, '_catplot.png'),
       width=7.25,
       height=6.25,
       units='in',
       dpi=300)

# Save dataframe ----
write.csv(popdensyr_bbox_df, paste0(savepath, 'urbDens.csv'), row.names=TRUE)

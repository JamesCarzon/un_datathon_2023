#'##########################################################################
## Code for processing urban density data from NASA's Socioeconomic Data and 
## Applications Center (SEDAC) for Brazil
## mayashen@cmu.edu - Nov 2023
## NOTES
#'##########################################################################

# SECTION 0: LOAD LIBRARIES, SET DIRECTORY, ETC ----
## Load libraries ----
library(ncdf4)
library(dplyr)
library(reshape)
library(purrr)
library(ggplot2)

## Set working directory ----
setwd('/Users/mayashen/Desktop/un_datathon_2023')
 
## Optional: Set own colors/palette ----
library(RColorBrewer) 
palette <- brewer.pal(6,"YlOrRd")

# SECTION 1: LOAD DATA ----
# Data downloaded from: https://sedac.ciesin.columbia.edu/data/set/gpw-v4-population-density-rev11/data-download

## Define load/save data paths ----
load_datapath <- 'DATA/gpw-v4-population-density-rev11_totpop_2pt5_min_nc/'
save_datapath <- 'DATA/'

## Load nc dataset ----
nc_fname <- 'gpw_v4_population_density_rev11_2pt5_min.nc'
ncin <- nc_open(paste0(load_datapath, nc_fname))
names(ncin$var)

lon <- ncvar_get(ncin,"longitude")
lat <- ncvar_get(ncin,"latitude")
popdens <- ncvar_get(ncin,"Population Density, v4.11 (2000, 2005, 2010, 2015, 2020): 2.5 arc-minutes")
dim(lon)
dim(lat)
dim(popdens)

# SECTION 2: DATA INVESTIGATION ----
## Investigate 5 slices ----
for (slice in 1:5) {
  print(sum(!(is.na(popdens[,,slice]))))
  print(unique(popdens[,,slice][!is.na(popdens[,,slice])])[1:10])
}

# Check that fifth slice is the most recent ----
# We want the most recent (2020) slice
t0 <- Sys.time()
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
  popdensyr_bbox_df$latitude <- lat_bbox[popdensyr_bbox_df$X2]
  popdensyr_bbox_df$longitude <- lon_bbox[popdensyr_bbox_df$X1]
  popdensyr_bbox_df$popdens <- popdensyr_bbox_df$value
  popdensyr_bbox_df <- popdensyr_bbox_df[, c('latitude', 'longitude', 'popdens')]
  
  popdensyr_bbox_df <- popdensyr_bbox_df[!is.na(popdensyr_bbox_df$popdens),]
  nrow(popdensyr_bbox_df)
  
  print(max(popdensyr_bbox_df$popdens))
  
  ggplot(data=popdensyr_bbox_df, aes(x=longitude, y=latitude, col=log(popdens))) +
    geom_point(size=0.2, alpha=0.5)
  ggsave(paste0('DATA/popdens_plots/cont_', slice, '_plot.png'),
         width=7.25,
         height=6.25,
         units='in',
         dpi=300)
  
  cat_popdens_mx <- matrix(NA, nrow=length(popdensyr_bbox_df$popdens), ncol=6)
  cat_lb <- c(-Inf, 1, 5, 25, 250, 1000)
  cat_ub <- c(1, 5, 25, 250, 1000, Inf)
  for (cat_i in 1:6) {
    cat_popdens_i <- between(popdensyr_bbox_df$popdens, cat_lb[cat_i], cat_ub[cat_i])
    cat_popdens_mx[, cat_i] <- cat_popdens_i
  }
  # No population density values at the boundaries
  unique(rowSums(cat_popdens_mx))
  
  cat_popdens_df <- melt(cat_popdens_mx)
  cat_popdens_df <- cat_popdens_df[cat_popdens_df$value,]
  
  popdens_cat_mapfn <- function(cat_i) {
    if (cat_i == 1) {
      return('<1')
    } else if (cat_i == 2) {
      return('1-5')
    } else if (cat_i == 3) {
      return('5-25')
    } else if (cat_i == 4) {
      return('25-250')
    } else if (cat_i == 5) {
      return('250-1,000')
    } else {
      return('>1,000')
    }
  }
  cat_popdens <- unlist(map(cat_popdens_df$X2, popdens_cat_mapfn))
  cat_popdens_order <- sort(cat_popdens_df$X1, index.return=T)$ix
  cat_popdens <- cat_popdens[cat_popdens_order]
  popdensyr_bbox_df$popdens_cat <- factor(cat_popdens, levels=c('<1', '1-5', '5-25', '25-250', 
                                                                '250-1,000', '>1,000'))
  
  ggplot(data=popdensyr_bbox_df, aes(x=longitude, y=latitude, col=popdens_cat)) +
    geom_point(size=0.2, alpha=0.5) +
    scale_color_manual(values = c('<1' = palette[1], 
                                  '1-5' = palette[2], 
                                  '5-25' = palette[3], 
                                  '25-250' = palette[4], 
                                  '250-1,000' = palette[5], 
                                  '>1,000' = palette[6])) 
  ggsave(paste0('DATA/popdens_plots/cat_', slice, '_plot.png'),
         width=7.25,
         height=6.25,
         units='in',
         dpi=300)
}
t1 <- Sys.time()
print(t1-t0)

## Get fifth slice ----
slice <- 5
popdensyr <- popdens[,,slice]

# SECTION 3: BOUNDING BOX ----
## Get points within bounding box of Brazil ----
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

## Remove NA urban density points ----
popdensyr_bbox_df <- popdensyr_bbox_df[!is.na(popdensyr_bbox_df$popdens),]
nrow(popdensyr_bbox_df) # 676778 points

# SECTION 4: PLOTTING ----

## Define save figure path ----
save_figpath <- 'DATA/urbdens_plots/'
  
## Plot population density (log scale) ----
ggplot(data=popdensyr_bbox_df, aes(x=longitude, y=latitude, col=log(popdens))) +
  geom_point(size=0.2, alpha=0.5)
# ggsave(paste0(save_figpath, slice, '_logplot.png'),
#        width=7.25,
#        height=6.25,
#        units='in',
#        dpi=300)

## Plot population density grouped according to web plots ----
# https://sedac.ciesin.columbia.edu/data/set/gpw-v4-population-density-rev11/maps

cat_popdens_mx <- matrix(NA, nrow=length(popdensyr_bbox_df$popdens), ncol=6)
cat_lb <- c(-Inf, 1, 5, 25, 250, 1000)
cat_ub <- c(1, 5, 25, 250, 1000, Inf)
for (cat_i in 1:6) {
  cat_popdens_i <- between(popdensyr_bbox_df$popdens, cat_lb[cat_i], cat_ub[cat_i])
  cat_popdens_mx[, cat_i] <- cat_popdens_i
}
# No population density values at the boundaries
unique(rowSums(cat_popdens_mx))

cat_popdens_df <- melt(cat_popdens_mx)
cat_popdens_df <- cat_popdens_df[cat_popdens_df$value,]

popdens_cat_mapfn <- function(cat_i) {
  if (cat_i == 1) {
    return('<1')
  } else if (cat_i == 2) {
    return('1-5')
  } else if (cat_i == 3) {
    return('5-25')
  } else if (cat_i == 4) {
    return('25-250')
  } else if (cat_i == 5) {
    return('250-1,000')
  } else {
    return('>1,000')
  }
}
cat_popdens <- unlist(map(cat_popdens_df$X2, popdens_cat_mapfn))

popdensyr_bbox_df$popdens_cat <- factor(cat_popdens, levels=c('<1', '1-5', '5-25', '25-250', 
                                                              '250-1,000', '>1,000'))

ggplot(data=popdensyr_bbox_df, aes(x=longitude, y=latitude, col=popdens_cat)) +
  geom_point(size=0.2, alpha=0.5) +
  scale_color_manual(values = c('<1' = palette[1], 
                                '1-5' = palette[2], 
                                '5-25' = palette[3], 
                                '25-250' = palette[4], 
                                '250-1,000' = palette[5], 
                                '>1,000' = palette[6])) 
# ggsave(paste0(save_figpath, slice, '_catplot.png'),
#        width=7.25,
#        height=6.25,
#        units='in',
#        dpi=300)

# SECTION 4: SAVE BRAZIL URBAN DENSITY DATA ----
write.csv(popdensyr_bbox_df, paste0(save_datapath, 'urbDens_data.csv'), row.names=TRUE)

# popdensyr_bbox_df <- read.csv(paste0(save_datapath, 'urbDens_data.csv'), row.names=1)

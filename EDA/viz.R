# Setup ----
# Load libraries
library(ggplot2)
library(dplyr)

# Set working directory
setwd('/Users/mayashen/Desktop/un_datathon_2023')
getwd()

# Optionally: Set own colors
library(RColorBrewer) 
palette <- brewer.pal(6,"YlOrRd")

# Load datasets ---- 

# Define datapath
datapath <- 'DATA/' 
savepath <- 'VIZ/'

# Load NO2 dataset
no2_data <- read.csv(paste0(datapath, 'no2_data.csv'), row.names=1)

# Load urban density dataset
urbDens_data <- read.csv(paste0(datapath, 'urbDens_data.csv'), row.names=1)
urbDens_data$popdens_cat <- factor(urbDens_data$popdens_cat, levels=c('<1', '1-5', '5-25', '25-250', 
                                                              '250-1,000', '>1,000'))
# Load powerplant dataset
pPlant_data <- read.csv(paste0(datapath, 'powerplants_SA.csv'), row.names=1)
# important features: latitude, longitude, capacity_mw, primary_fuel

# Load combined/regridded dataset: NO2, regridded urban density, powerplant features

# Subset points ----
# Small bounding box: 
# Left, bottom: -24, -47.5
# Right, top: -19, -42.5
# lat: [-24, -19], lon: [-47.5, -42.5]

no2_data <- no2_data[between(no2_data$latitude, -24, -19) & between(no2_data$longitude, -47.5, -42.5),]
urbDens_data <- urbDens_data[between(urbDens_data$latitude, -24, -19) & between(urbDens_data$longitude, -47.5, -42.5),]

# NO2 Visualizations ----
no2_data <- no2_data[no2_data$NO2mol > 0,]

ggplot() +
  geom_point(data=no2_data, aes(x=longitude, y=latitude, col=log(1+NO2gm)), size=0.8, alpha=1) +
  xlab('Longitude') +
  ylab('Latitude') +
  labs(color='NO2 (log(1+gm))') +
  theme_bw()
ggsave(paste0(savepath, 'no2.png'),
       width=7.25,
       height=6.25,
       units='in',
       dpi=300)

# Overlay factories on top of NO2
ggplot() +
  geom_point(data=no2_data, aes(x=longitude, y=latitude, col=log(1+NO2gm)), size=0.8, alpha=1) +
  geom_point(data=pPlant_data[between(pPlant_data$latitude, -24, -19) & between(pPlant_data$longitude, -47.5, -42.5) &
                                pPlant_data$primary_fuel %in% c('Gas', 'Oil', 'Coal'),],
             aes(x=longitude, y=latitude), col='green', shape = 21) +
  xlab('Longitude') +
  ylab('Latitude') +
  labs(color='NO2 (log(1+gm))') +
  theme_bw()
ggsave(paste0(savepath, 'no2_factories.png'),
       width=7.25,
       height=6.25,
       units='in',
       dpi=300)

# Overlay factories on top of urban density
ggplot() +
  geom_point(data=urbDens_data, aes(x=longitude, y=latitude, col=log(1+popdens)), size=1, alpha=1) +
  geom_point(data=pPlant_data[between(pPlant_data$latitude, -24, -19) & between(pPlant_data$longitude, -47.5, -42.5) &
                                pPlant_data$primary_fuel %in% c('Gas', 'Oil', 'Coal'),],
             aes(x=longitude, y=latitude), col='red', shape = 21)

ggplot() +
  geom_point(data=urbDens_data, aes(x=longitude, y=latitude, col=popdens_cat), size=0.6, alpha=1) +
  scale_color_manual(values = c('<1' = palette[1], 
                                '1-5' = palette[2], 
                                '5-25' = palette[3], 
                                '25-250' = palette[4], 
                                '250-1,000' = palette[5], 
                                '>1,000' = palette[6]),
                     'name'='Persons per km^2') +
  geom_point(data=pPlant_data[between(pPlant_data$latitude, -24, -19) & between(pPlant_data$longitude, -47.5, -42.5) &
                                pPlant_data$primary_fuel %in% c('Gas', 'Oil', 'Coal'),],
             aes(x=longitude, y=latitude), col='green', shape = 21) +
  xlab('Longitude') +
  ylab('Latitude') +
  theme_bw()
ggsave(paste0(savepath, 'popdens_cat_factories.png'),
       width=7.25,
       height=6.25,
       units='in',
       dpi=300)

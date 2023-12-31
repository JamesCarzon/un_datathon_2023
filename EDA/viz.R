#'##########################################################################
## Visualize NO2, urban density, and factory data
## mayashen@cmu.edu - Nov 2023
## NOTES
#'##########################################################################


# SECTION 0: LOAD LIBRARIES, SET DIRECTORY, ETC ----
## Load libraries ----
library(ggplot2)
library(dplyr)

## Set working directory ----
setwd('/Users/mayashen/Desktop/un_datathon_2023')
getwd()

## Optional: Set own colors/palette ----
library(RColorBrewer) 
palette <- brewer.pal(6,"YlOrRd")

# SECTION 1: LOAD DATA ----
## Define data load path ----
load_datapath <- 'DATA/'
## Define figure save path ----
save_figpath <- 'VIZ/'

## Load NO2 dataset ----
no2_data <- read.csv(paste0(load_datapath, 'no2_data.csv'), row.names=1)

## Load urban density dataset ----
urbDens_data <- read.csv(paste0(load_datapath, 'urbdens_data.csv'), row.names=1)
urbDens_data$popdens_cat <- factor(urbDens_data$popdens_cat, levels=c('<1', '1-5', '5-25', '25-250', 
                                                              '250-1,000', '>1,000'))
## Load powerplant dataset ----
# Only contains South American power plants (see powerplant_brazil_eda.Rmd)
pPlant_data <- read.csv(paste0(load_datapath, 'powerplants_SA.csv'), row.names=1)
# important features: latitude, longitude, capacity_mw, primary_fuel

# SECTION 2: SMALL BOUNDING BOX ----
# New smaller bounding box, includes Rio de Janeiro and São Paulo
# Small bounding box coordinates: 
# Left, bottom: -24, -47.5
# Right, top: -19, -42.5
# lat: [-24, -19], lon: [-47.5, -42.5]

## Get points within small bounding box ----
no2_data <- no2_data[between(no2_data$latitude, -24, -19) & between(no2_data$longitude, -47.5, -42.5),]
urbDens_data <- urbDens_data[between(urbDens_data$latitude, -24, -19) & between(urbDens_data$longitude, -47.5, -42.5),]

# SECTION 3: VISUALIZATIONS ----
no2_data <- no2_data[no2_data$NO2mol > 0,]
## Log NO2 ----
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

## Overlay factories on top of log NO2 ----
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

## Overlay factories on top of log urban density ----
ggplot() +
  geom_point(data=urbDens_data, aes(x=longitude, y=latitude, col=log(1+popdens)), size=1, alpha=1) +
  geom_point(data=pPlant_data[between(pPlant_data$latitude, -24, -19) & between(pPlant_data$longitude, -47.5, -42.5) &
                                pPlant_data$primary_fuel %in% c('Gas', 'Oil', 'Coal'),],
             aes(x=longitude, y=latitude), col='green', shape = 21) +
  xlab('Longitude') +
  ylab('Latitude') +
  theme_bw()

## Binned urban density ----
ggplot() +
  geom_point(data=urbDens_data, aes(x=longitude, y=latitude, col=popdens_cat), size=0.6, alpha=1) +
  scale_color_manual(values = c('<1' = palette[1], 
                                '1-5' = palette[2], 
                                '5-25' = palette[3], 
                                '25-250' = palette[4], 
                                '250-1,000' = palette[5], 
                                '>1,000' = palette[6]),
                     'name'='Persons per km^2') +
  xlab('Longitude') +
  ylab('Latitude') +
  theme_bw()
ggsave(paste0(savepath, 'popdens_cat.png'),
       width=7.25,
       height=6.25,
       units='in',
       dpi=300)

## Overlay factories on top of binned urban density ----
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

# SECTION 4: VISUALIZE RESULT DIFFERENCES ----

## Load result differences ----
pred_diffs <- read.csv(paste0(load_datapathf, 'fact_pred_diff.csv'), row.names=1)

## Plot if NO2 stayed the same, decreased, or increased ----
# Not sure this is the best way to visualize but it's hard to see what's happening if just plotting values...
for (i in 1:10) {
  pred_diffs_cat <- c() 
  for (val in pred_diffs[, i]) {
    if (val == 0) {
      pred_diffs_cat <- c(pred_diffs_cat, 'same')
    } else if (val < 0) {
      pred_diffs_cat <- c(pred_diffs_cat, 'decreased')
    } else {
      pred_diffs_cat <- c(pred_diffs_cat, 'increased')
    }
  }
  pred_diffs_cat <- factor(pred_diffs_cat, levels=c('decreased', 'same', 'increased'))
  # pred NO2 without factory - pred NO2 with factory 
  ggplot() +
    geom_point(data=pred_diffs, aes(x=longitude, y=latitude, col=pred_diffs_cat), size=1, alpha=1) +
    scale_color_manual(values = c('decreased' = 'blue', 
                                  'same' = 'gray', 
                                  'increased' = 'red'),
                       'name'='Predicted NO2') +
    xlab('Longitude') +
    ylab('Latitude') +
    theme_bw() +
    labs(title=paste0('Factory ', i, ' Removal'))
  ggsave(paste0(savepath, 'effect/factory', i, '.png'),
         width=7.25,
         height=6.25,
         units='in',
         dpi=300)
}

library(geosphere)
library(dplyr)
dat <- read.csv("DATA/global_power_plant_database_v_1_3/global_power_plant_database.csv")
dat <- dat[dat$country_long %in% c("Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Ecuador", "Guyana", "Paraguay", "Peru", "Suriname", "Uruguay", "Venezuela"),]
factory_coord <- as.data.frame(dat[,c("gppd_idnr", "latitude", "longitude")])

pt_interest <- c(1,1) # 

# returns a dataframe with factories within dist_in_m meters of the point of interest (lat, long)
num_factory_within_dist <- function(pt_interest, factory_coord, dist_in_m) {
  res <- get_dist_to_factory(pt_interest, factory_coord)
  filtered <- res %>% filter(dist_to_pt < dist_in_m)
  return(filtered)
}

# returns a dataframe with the distance to the point of interest (lat, long) for each factory
get_dist_to_factory <- function(pt_interest, factory_coord) {
  res <- sapply(1:nrow(factory_coord), function(i) distm(factory_coord[i,c(2,3)], pt_interest, fun = distHaversine))
  factory_coord$dist_to_pt <- res
  return(factory_coord)
}

# returns a dataframe with factories within 6509000 meters of the point of interest
res <- num_factory_within_dist(pt_interest, factory_coord, 6509000)
library(geodist)
library(dplyr)
no2 <-  read.csv("DATA/no2_data.csv")
dat <- read.csv("DATA/global_power_plant_database_v_1_3/global_power_plant_database.csv")
dat <- dat[dat$country_long %in% c("Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Ecuador", "Guyana", "Paraguay", "Peru", "Suriname", "Uruguay", "Venezuela"),]
factory_coord <- as.data.frame(dat[,c("gppd_idnr", "longitude", "latitude","primary_fuel")])
write.csv(dat, "DATA/powerplants_SA.csv")

# returns a dataframe with factories within dist_in_m meters of the point of interest (lat, long)
num_factory_within_dist <- function(pt_interest, factory_coord, dist_in_m) {
  res <- get_dist_to_factory(pt_interest, factory_coord)
  filtered <- res %>% filter(dist_to_pt < dist_in_m)
  return(filtered)
}

# returns a dataframe with the distance to the point of interest (lat, long) for each factory
get_dist_to_factory <- function(pt_interest, factory_coord) {
  res <- sapply(1:nrow(factory_coord), function(i) geodist(factory_coord[i,c("longitude","latitude")], pt_interest))
  factory_coord$dist_to_pt <- res
  return(factory_coord)
}

dist_to_closest_factory_type <- function(pt_interest, factory_coord, primary_fuel, return_id = FALSE) {
  print(pt_interest)
  df <- factory_coord[factory_coord$primary_fuel %in% primary_fuel,]
  res <- get_dist_to_factory(pt_interest, df)
  row <- res[which.min(res$dist_to_pt),]
    if (return_id) {
        return(row$gppd_idnr)
    } else {
        return(row)
    }
}

# returns a dataframe with factories within 6509000 meters of the point of interest
#res <- num_factory_within_dist(pt_interest, factory_coord, 6509000)


no2_coord <- as.data.frame(no2[,c("longitude", "latitude")])
print("Computing closest CoalOilGas factory")
rownames(factory_coord) <- factory_coord$gppd_idnr
# no2$closest_GoalOilGas_idt <- sapply(1:nrow(no2), function(i) dist_to_closest_factory_type(no2_coord[i,c("longitude","latitude")], factory_coord, c("Oil", "Gas", "Coal"), return_id = TRUE))
no2_test <- sapply(1:5, function(i) dist_to_closest_factory_type(no2_coord[i,c("longitude","latitude")], factory_coord, c("Oil", "Gas", "Coal"), return_id = TRUE))
#dist_matrix <- geodist(no2_coord, factory_coord[,c("longitude", "latitude")])
save(no2_test, file = "DATA/S5P_no2_with_closest_GoalOilGas_id.RData")
#save(dist_matrix, file = "DATA/S5P_no2_powerplants_dist_matrix.RData")

# Create distance matrix for X_test lat/lon data ----
X_test <- read.csv('DATA/X_test.csv', row.names=1)
test_coord <- as.data.frame(X_test[,c("longitude", "latitude")])
rownames(factory_coord) <- factory_coord$gppd_idnr
t0 <- Sys.time()
dist_matrix <- geodist(test_coord, factory_coord[,c("longitude", "latitude")])
t1 <- Sys.time()
colnames(dist_matrix) <- factory_coord$gppd_idnr
write.csv(dist_matrix, paste0('DATA/X_test_distmx.csv'))



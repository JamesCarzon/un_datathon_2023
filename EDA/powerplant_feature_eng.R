# load dist_matrix
load("DATA/S5P_no2_powerplants_dist_matrix.RData")
no2 <- read.csv("DATA/S5P_no2.csv")
small <- head(dist_matrix)

min_dist <- apply(dist_matrix, 1, min)
min_dist_idx <- apply(dist_matrix, 1, which.min)
min_dist_type <- sapply(min_dist_idx, function(i) dat[i,"primary_fuel"])

bad_powerplants <- which(dat$primary_fuel %in% c("Gas", "Oil", "Coal"))
dist_matrix_bad <- dist_matrix[,bad_powerplants] 

min_dist_bad <- apply(dist_matrix_bad, 1, min)
min_dist_idx_bad <- apply(dist_matrix_bad, 1, which.min)
min_dist_idx_bad <- bad_powerplants[min_dist_idx_bad]
min_dist_type_bad <-  dat[min_dist_idx_bad ,"primary_fuel"]

closest_factory <- data.frame(
    "no2_latitude" = no2[,"latitude"],
    "no2_longitude" = no2[,"longitude"],
    "min_dist"=min_dist, 
    "min_dist_idx"=min_dist_idx, 
    "min_dist_type" = min_dist_type,
    "min_dist_bad"=min_dist_bad, 
    "min_dist_idx_bad"=min_dist_idx_bad, 
    "min_dist_type_bad" = min_dist_type_bad
    )


write.csv(closest_factory, file="DATA/powerplants_feature.csv")

no2 <- read.csv("DATA/S5P_no2.csv")
closest_factory$no2_latitude <- no2[,"latitude"]
closest_factory$no2_longitude <- no2[,"longitude"]
closest_factory <- read.csv("DATA/powerplants_feature.csv")

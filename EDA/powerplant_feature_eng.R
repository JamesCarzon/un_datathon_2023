# load dist_matrix
load("DATA/S5P_no2_powerplants_dist_matrix.RData")
small <- head(dist_matrix)

min_dist <- apply(dist_matrix, 1, min)
min_dist_idx <- apply(dist_matrix, 1, which.min)
min_dist_type <- sapply(min_dist_idx, function(i) dat[i,"primary_fuel"])

closest_factory <- dataframe("min_dist"=min_dist, "min_dist_idx"=min_dist_idx, "min_dist_type" = min_dist_type)

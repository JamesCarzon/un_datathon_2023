


library(tidyverse)
library(fuzzyjoin)

elevation_res5 <- read_csv("../DATA/elevation_res5.csv")
regridded <- read_csv("../DATA/regridded_data.csv")

temp_ele <- elevation_res5 %>% 
  arrange(x, y) %>% 
  filter(y > -24 & y < -19 & x < -42.5 & x > -47.5) %>% 
  filter(!is.na(elevation)) %>% 
  rename(longitude = x, latitude = y)

temp_no2 <- regridded %>% 
  arrange(longitude, latitude) %>% 
  filter(latitude > -24 & latitude < -19 & longitude < -42.5 & longitude > -47.5)

temp_fuzzy <- fuzzyjoin::geo_left_join(temp_no2, temp_ele, 
                                       by = c("longitude", "latitude"), max_dist = 1, unit = "km")

temp_fuzzy2 <- temp_fuzzy %>% 
  group_by(latitude.x, longitude.x) %>% 
  mutate(avg_ele = mean(elevation)) %>% 
  select(-elevation, -latitude.y, -longitude.y) %>% 
  distinct()





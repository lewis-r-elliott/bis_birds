pacman::p_load(rgdal, rgeos, raster, sp, tidyverse)

# read in birds data

birds <- raster("C:/Users/lre203/OneDrive - University of Exeter/20160301_BH/20160301_Survey/20170713_Data/Exposure Assessment/birds_richness_compressed.TIF")
plot(birds)

# what projection

birds@crs # wgs84 (same as our BlueHealth data)

# changing birds data to points data

# birds_points <- rasterToPoints(birds) # would take fucking ages

# read in bis

load("C:/Users/lre203/OneDrive - University of Exeter/20160301_BH/20160301_Survey/20170713_Data/Final Datasets/20200302_bis.RData")

# overlay home locations onto birds data

points(bis$home_longitude, bis$home_latitude)

# get data.frames of just home coordinates and visit coordinates

bis %>%
  select(id, home_longitude, home_latitude) %>%
  filter(across(everything(), ~!is.na(.))) -> bis_home_locations
bis %>%
  select(id, v_visit_lon, v_visit_lat) %>%
  filter(across(everything(), ~!is.na(.))) -> bis_visit_locations

# make these into spatial points data frames

SpatialPointsDataFrame(bis_home_locations[,2:3],
                       proj4string = birds@crs,
                       data = bis_home_locations) -> bis_home_locations_spdf

SpatialPointsDataFrame(bis_visit_locations[,2:3],
                       proj4string = birds@crs,
                       data = bis_visit_locations) -> bis_visit_locations_spdf

bis_home_locations_spdf
bis_visit_locations_spdf

# extracting average birds species richness levels in 300m and 1000m buffers
# to be consistent with other exposure data in BIS

raster::extract(birds, # the raster dataset
                bis_home_locations_spdf, # the spatial points data frame with home locations
                buffer=300, # 300m buffer around the point
                fun=mean, # extract the mean value of birds species from the pixels which the buffer intersects
                df=TRUE) %>% # return a data.frame
  bind_cols(bis_home_locations$id) %>%
  select(home_bird_richness_300=birds_richness_compressed, id=`...3`) -> bis_home_locations_birds_300

raster::extract(birds,
                bis_home_locations_spdf, 
                buffer=1000, # 1000m buffer around the point
                fun=mean, 
                df=TRUE) %>% 
  bind_cols(bis_home_locations$id) %>%
  select(home_bird_richness_1000=birds_richness_compressed, id=`...3`) -> bis_home_locations_birds_1000

# and for visit locations

raster::extract(birds, 
                bis_visit_locations_spdf, # the spatial points data frame with visit locations
                buffer=300, 
                fun=mean, 
                df=TRUE) %>% 
  bind_cols(bis_visit_locations$id) %>%
  select(v_bird_richness_300=birds_richness_compressed, id=`...3`) -> bis_visit_locations_birds_300

raster::extract(birds,
                bis_visit_locations_spdf, 
                buffer=1000, # 1000m buffer around the point
                fun=mean, 
                df=TRUE) %>% 
  bind_cols(bis_visit_locations$id) %>%
  select(v_bird_richness_1000=birds_richness_compressed, id=`...3`) -> bis_visit_locations_birds_1000

# binding to the original bis dataset

bis %>%
  left_join(bis_home_locations_birds_300, by="id") %>%
  left_join(bis_home_locations_birds_1000, by="id") %>%
  left_join(bis_visit_locations_birds_300, by="id") %>%
  left_join(bis_visit_locations_birds_1000, by="id") -> bis

# summaries

bis %>%
  select(home_bird_richness_300:v_bird_richness_1000) %>%
  map(~summary(.))

# histograms

bis %>%
  pivot_longer(cols = home_bird_richness_300:v_bird_richness_1000,
               names_to = "bird",
               values_to = "richness") %>%
  mutate(bird2 = fct_recode(bird,
                            "Home location (300m buffer)"="home_bird_richness_300",
                            "Home location (1000m buffer)"="home_bird_richness_1000",
                            "Visit location (300m buffer)"="v_bird_richness_300",
                            "Visit location (1000m buffer)"="v_bird_richness_1000")) %>%
  ggplot(aes(x=richness)) +
  geom_histogram() +
  facet_wrap(~bird2) +
  scale_x_continuous(name="Richness (i.e. average number of bird species in the buffer)") +
  scale_y_continuous(name="Frequency")

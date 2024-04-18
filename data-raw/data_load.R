library(rstudioapi)
library(dplyr)
library(tidyverse)
library(lubridate)
library(stringr)
library(refinr)
library(tidyr)
library(ggmap)
library(geosphere)
library(chron)
library(flextable)

register_google("AIzaSyDvWH75eilZiz-o-YpxSydcFETTCBy977c")

# Set working directory
setwd(dirname(getActiveDocumentContext()$path))

activities <- read.csv("finalized_analysisData.csv")
locations <- read.csv("Hometown_and_coords.csv")

activities_updated <- activities %>%
  mutate(
    time_of_day = str_extract(Date, "\\d{1,2}:\\d{2} [APap][Mm]"),
    day = str_extract(Date, "[A-Za-z]+ \\d{1,2}, \\d{4}")
  )

activities_updated$type <- str_split(activities_updated$Activity.Type, " – ", simplify = TRUE)[, 2]
activities_updated$mileage <- parse_number(activities_updated$Mileage)
activities_updated$ID <- as.factor(activities_updated$ID)
activities_updated$type <- as.factor(activities_updated$type)

activities_updated <- activities_updated[-c(2,3,5,8)]

#lat_lon <- geocode(activities_updated$Location)

#hometown_lat_lon <- geocode(locations$Hometown)
hometown_lat_lon$ID <- locations$ID
hometown_lat_lon$hometown <- locations$Hometown

activities_updated$longitude <- lat_lon$lon

activities_updated$latitude <- lat_lon$lat

types <- data.frame(athleteType=c("WorldTour", "WorldTour", "WorldTour", "WorldTour", "WorldTour", "Retired", "WorldTour", "WorldTour", "WorldTour", "WorldTour", "Gravel", "WorldTour", "WorldTour", "WorldTour",
                                  "WorldTour", "WorldTour", "WorldTour", "WorldTour", "WorldTour", "WorldTour", "WorldTour", "WorldTour", "WorldTour", "WorldTour", "WorldTour", "WorldTour",
                                  "WorldTour", "Gravel", "Gravel", "Gravel", "Gravel", "Gravel", "Gravel", "Gravel", "Gravel", "Crit", "Crit", "Crit", "Crit", "Crit"))

replaceID <- data.frame(replaceID = c(1:40))

replaceID$ID <- hometown_lat_lon$ID

types$ID <- hometown_lat_lon$ID

types$replaceID <- replaceID$replaceID

activities_updated <- merge(activities_updated, hometown_lat_lon, by="ID")

activities_updated <- merge(activities_updated, types, by="ID")

activities_updated <- merge(activities_updated, replaceID, by='ID')

activities_updated <- activities_updated[-1]

activities_updated_sum <- activities_updated %>%
  group_by(replaceID) %>%
  summarise(total_mileage = sum(mileage))

activities_updated_sum <- merge(activities_updated_sum, types, by="replaceID")

ggplot(activities_updated_sum, aes(x = reorder(replaceID, total_mileage), y = total_mileage, fill=athleteType)) +
  geom_bar(stat = "identity") +
  labs(x = "Athlete ID", y = "Total Mileage", title = "Sum of Off-Season Mileage by Athlete ID",fill="Type of Athlete")+
  theme(plot.title = element_text(hjust=0.5,size=18,face="bold"),
        axis.title = element_text(face="bold", size=14),
        axis.text = element_text(face="bold", size=12),
        legend.text = element_text(face="bold",size=12),
        legend.title = element_text(face="bold",size=14),
        legend.position = c(.07,.9))

activityDist <- data.frame(activities_updated$longitude)

activityDist$latitude <- activities_updated$latitude

hometownDist <- data.frame(activities_updated$lon)
hometownDist$lat <- activities_updated$lat

activities_updated$distance <- distHaversine(activityDist, hometownDist)/1000

activities_distanceVis <- activities_updated %>% drop_na(distance)

activities_updated_dist <- activities_distanceVis %>%
  group_by(replaceID) %>%
  summarise(avgDist = mean(distance))

activities_updated_dist <- merge(activities_updated_dist, types, by="replaceID")

ggplot(activities_updated_dist, aes(x = reorder(replaceID, avgDist), y = log(avgDist), fill=athleteType)) +
  geom_bar(stat = "identity") +
  labs(x = "Athlete ID", y = "Log-Transformed Average Distance", title = "Average Distance Away from Home Ridden by Athlete",fill="Type of Athlete") +
  theme(plot.title = element_text(hjust=0.5,size=18,face="bold"),
        axis.title = element_text(face="bold", size=14),
        axis.text = element_text(face="bold", size=12),
        legend.text = element_text(face="bold",size=12),
        legend.title = element_text(face="bold",size=14),
        legend.position = c(.07,.9))

# Other questions to map out, want to map longest distance between hometown and ride, create model with elevation/mileage/time versus best result
## use ggmap for mapping out points
map <- get_map(location = 'Luxembourg', zoom=5)

amerMap <- get_map(location = 'america', zoom=4)
ggmap(map) +
  geom_density_2d_filled(data=activities_distanceVis,
                  aes(x=longitude,y=latitude), alpha=0.4)

ggmap(amerMap) +
  geom_density_2d(data=activities_distanceVis,
                  aes(x=longitude,y=latitude))

activities_updated$replaceID <- as.factor(activities_updated$replaceID)

activities_updated <- activities_updated %>%
  mutate(typesUpdated = case_when(
    grepl("Virtual", type) ~ "Virtual",
    grepl("Ride", type) ~ "Ride",
    grepl("Race", type) ~ "Ride",
    grepl("Run", type) ~ "Run",
    grepl("Walk", type) ~ "Run",
    grepl("Hike", type) ~ "Run",
    TRUE ~ "Other"
  ))


activities_updated <- activities_updated %>%
  mutate(athlete = case_when(
    grepl("Gravel", athleteType) ~ "Other",
    grepl("Crit", athleteType) ~ "Other",
    grepl("Retired", athleteType) ~ "Other",
    TRUE ~ athleteType
  ))

activities_updated$typesUpdated <- as.factor(activities_updated$typesUpdated)
activities_updated$athlete <- as.factor(activities_updated$athlete)

activities_updated_typecount <- activities_updated %>%
  group_by(replaceID) %>%
  summarise(diffTypes = n_distinct(type))

activities_updated_typecount <- merge(activities_updated_typecount, types, by="replaceID")

#ggplot(activities_updated_typecount, aes(x = replaceID, y = diffTypes, fill=athleteType)) +
 # geom_bar(stat = "identity") +
  #labs(x = "ID", y = "Amount of Distinct Activities", title = "Count of Different Activity Types by Athlete")

activities_types <- as.data.frame(activities_updated$replaceID)
activities_types$typesUpdated <- activities_updated$typesUpdated

ggplot(activities_updated, aes(x = fct_infreq(replaceID), y = typesUpdated, fill = typesUpdated)) +
  geom_bar(stat = "identity") +
  facet_wrap(vars(athlete), scales = "free_x") +
  labs(title="Activity Types Throughout Rider Activities",x = "Athlete", y="Types of Activity",fill="Type of Activity") +
  theme(axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title = element_text(face="bold", size=14),
        axis.text = element_text(face="bold",size=12),
        plot.caption = element_text(hjust=0, face="bold"),
        plot.title = element_text(size=18,hjust=0.5, face="bold"),
        legend.text = element_text(face="bold",size=12),
        legend.title = element_text(face="bold",size=14),
        legend.position = c(.95,.85))+
  scale_fill_manual(values=wes_palette("Darjeeling1", 4))

#, caption="Stacked Histogram of Types of Activities Completed by Each Athlete"

binary_indicator <- activities_updated %>%
  group_by(replaceID, type, athlete) %>%
  summarise(has_done_activity = as.integer(n() > 0)) %>%
  ungroup()

# Pivot the data to have one row per athlete, with columns indicating whether they have done each activity type
binary_indicator_pivot <- binary_indicator %>%
  pivot_wider(names_from = type, values_from = has_done_activity, values_fill = list(has_done_activity = 0))

summarytable <- binary_indicator_pivot %>%
  group_by(athlete) %>%
  summarise(
    Walk = sum(Hike,Walk),
    Virtual = sum(`Virtual Run`,`Virtual Ride`),
    Ride = sum(Ride, Race, `Gravel Ride`,`Mountain Bike Ride`),
    Run = sum(Run, `Trail Run`),
    Other = sum(`Backcountry Ski`, `Alpine Ski`, `Nordic Ski`, `E-Mountain Bike Ride`, `E-Bike Ride`,Swim,`Stand Up Paddling`,Workout)
  ) %>%
  ungroup()

chisq.test(summarytable[2:6],c(1,2))

ft <- flextable(activities_updated[c(293:302),c(1:3,5:13)])

ft <- theme_vanilla(ft)

ft <- bold(ft, part="header")

ft <- width(ft, j=3, 2)
ft <- width(ft, j=4, 2)
ft <- width(ft, j=11, 2)


ftchi <- flextable(summarytable)

ftchi <- theme_vanilla(ftchi)

ftchi <- bold(ftchi, part="header")


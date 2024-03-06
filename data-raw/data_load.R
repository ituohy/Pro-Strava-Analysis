library(rstudioapi)
library(dplyr)
library(tidyverse)
library(lubridate)
library(stringr)
library(refinr)

# Set working directory
setwd(dirname(getActiveDocumentContext()$path))

activities <- read.csv("finalized_analysisData.csv")

activities_updated <- activities %>%
  mutate(
    time_of_day = str_extract(Date, "\\d{1,2}:\\d{2} [APap][Mm]"),
    day = str_extract(Date, "[A-Za-z]+ \\d{1,2}, \\d{4}"),
    name = str_split(Activity.Type, pattern = " – ")[[1]][1],
    activity = str_split(Activity.Type, pattern = " – ")[[1]][2]
  )

activities_updated <- activities_updated[-c(2,5,8)]

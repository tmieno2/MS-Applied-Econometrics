
library(here)
library(data.table)
library(tidyverse)
setwd(here("LectureNotes/A3_ResearchDemonstration"))

data <- readRDS("final_data_CO.rds")

ggplot(data = data) +
  geom_histogram(aes(x = pumpingAF))
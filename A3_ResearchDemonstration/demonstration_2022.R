
library(here)
library(data.table)
library(tidyverse)
setwd(here("LectureNotes/A3_ResearchDemonstration"))

data <- readRDS("final_data_CO.rds") %>%
  dplyr::select(site_no, year, pumpingAF, pc, precip, et, gpm, REA, tier)

ggplot(data = data) +
  geom_boxplot(aes(y = pumpingAF, x = factor(year)))

ggplot(data = data) +
  geom_boxplot(aes(y = et, x = factor(year)))

ggplot(data = data) +
  geom_boxplot(aes(y = precip, x = factor(year)))

ggplot(data = data) +
  geom_histogram(aes(x = gpm))

ggplot(data = data) +
  geom_point(aes(y = pumpingAF, x = gpm)) +
  geom_smooth(aes(y = pumpingAF, x = gpm)) +
  facet_wrap(year ~ ., nrow = 3)

ggplot(data = data) +
  geom_point(aes(y = pc, x = precip)) +
  geom_smooth(aes(y = pc, x = precip))


ggplot(data = data) +
  geom_point(aes(y = precip, x = et)) +
  geom_smooth(aes(y = precip, x = et))

ggplot(data = data) +
  geom_boxplot(aes(y = pc, x = factor(REA)))

dplyr::select(data, pumpingAF, pc, precip, et, gpm) %>%
  cor()

library(fixest)

feols(pumpingAF ~ pc + et + gpm, data = data)

feols(pumpingAF ~ pc + precip + et + gpm, data = data)

feols(pumpingAF ~ pc + precip + et + gpm, data = data)

feols(pumpingAF ~ pc + precip + et + gpm | site_no, data = data)

feols(pumpingAF ~ pc + precip + et + gpm, data = data)
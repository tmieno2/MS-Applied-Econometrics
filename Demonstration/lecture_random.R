setwd("/Users/tmieno2/Dropbox/TeachingUNL/DataScience/Assignments/Assignment_1")

KS_wells


ir_data <- readRDS("data_CO_as1.rds")

sat_data <- read_csv("all_sat_CO_as1.csv") 

library(readstata13)

daymet_data <- read.dta13("daymet_raw_as1.dta") %>% 
  tibble()

daymet <- readRDS("dyamet_raw.rds") %>% 
	mutate(
		base_date  = as.Date(paste0(year,"-01-01")),
		date = base_date + yday - 1
	)	

monthly_prcp_data <- daymet %>% 
	mutate(month = month(date)) %>% 
	filter(month %in% c(5, 6, 7, 8, 9)) %>% 
	rename(prcp = prcp..mm.day.) %>% 
	group_by(year, month, wdid)	%>% 
	summarize(sum_prcp = sum(prcp))

monthhly_prcp_wide <- pivot_wider(
	monthly_prcp_data, 
	names_from = month,
	values_from = sum_prcp,
	names_prefix = "mp_"
) 

data_with_prcp <- left_join(ir_data, monthhly_prcp_wide, by = c("year", "wdid")) %>% 
	relocate(wdid, pumpingAF, mp_5, mp_9)

mean_pumping <- ir_data %>% 
	group_by(year) %>% 
	summarize(mean_ir = mean(pumpingAF))

ggplot() +
	geom_line(data = mean_pumping, aes(y = mean_ir, x = year))

ggplot(data = ir_data) +
	geom_boxplot(aes(y = pumpingAF, x = factor(year)))

ir_data$REAname

library(modelsummary)

summary(ir_data)

cor(select(ir_data, pumpingAF, PCC, WellCap))

ggplot(data = ir_data) +
	geom_point(aes(y = pumpingAF, x = PCC)) +
	geom_smooth(aes(y = pumpingAF, x = PCC), method = "lm")

ggplot(data = ir_data) +
	geom_point(aes(y = WellCap, x = PCC)) +
	geom_smooth(aes(y = WellCap, x = PCC), method = "lm")

ggplot(data = ir_data) +
	geom_point(aes(y = pumpingAF, x = WellCap)) +
	geom_smooth(aes(y = pumpingAF, x = WellCap), method = "lm") +
	facet_grid(year ~ .)

ggplot(data = ir_data) +
	geom_density(aes(x = pumpingAF, fill = REAname), alpha = 0.5) +
	facet_grid(year ~ .)

meansat <- sat_data %>% 
	group_by(year) %>% 
	summarize(sat_thickness = mean(sat_thickness))

ggplot(data = meansat) +
	geom_line(aes(y = sat_thickness, x = year))





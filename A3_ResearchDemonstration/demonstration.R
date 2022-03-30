data <- readRDS("final_data_CO.rds")






library(stargazer)

model_1 <- felm(pumpingAF ~ pc, data = final_data)

model_2 <- felm(pumpingAF ~ pc + precip, data = final_data)

model_3 <- felm(pumpingAF ~ pc + precip + gpm, data = final_data)

model_3 <- felm(pumpingAF ~ pc + precip + gpm, data = final_data)

model_4 <- felm(pumpingAF ~ pc + precip + gpm + sat_thickness, data = final_data)

stargazer(list(model_2, model_3, model_4), type = "text")


model_fe <- felm(pumpingAF ~ pc + precip + gpm + sat_thickness | wdid | 0 | 0, data = final_data)

model_fe_yfe <- felm(pumpingAF ~ pc + precip + gpm + sat_thickness | wdid + year | 0 | 0, data = final_data)

stargazer(list(model_fe, model_fe_yfe), type = "text")


model_fe_yfe_2 <- felm(pumpingAF ~ pc + precip + gpm + sat_thickness | wdid_tier_hp + year | 0 | 0, data = final_data)

stargazer(list(model_fe, model_fe_yfe, model_fe_yfe_2), type = "text")
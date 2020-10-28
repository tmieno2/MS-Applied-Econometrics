#' ---
#' title: "CO regression analysis"
#' author: "Taro Mieno"
#' output:
#'   html_document:
#'     number_sections: yes
#'     theme: flatly
#'     highlight: zenburn
#'     toc_float: yes
#'     toc: yes
#'     toc_depth: 3
#' geometry: margin=1in
#' ---

#+ setup, include=FALSE
# knitr::opts_chunk(
#   echo = TRUE,
#   cache = FALSE,
#   comment = NA,
#   message = FALSE,
#   warning = FALSE,
#   tidy = FALSE,
#   cache.lazy = FALSE,
#   #--- figure ---#
#   dpi=400,
#   fig.width=7.5,
#   fig.height=5,
#   out.width="750px",
#   out.height="500px"
# )

library(data.table)
library(magrittr)
library(ggplot2)
library(dplyr)
library(stringr)
library(stargazer)
library(sf)
library(lfe)
library(mgcv)
library(lfe)
library(ggthemes)
library(kableExtra)
library(grid)

# /*=================================================*/
#' # Preparation
# /*=================================================*/
reg_data_CO <- readRDS("./Data/final_data_CO.rds") %>%
  setnames("pumpingAF", "water_use")

# === how many wells changed their hp in the middle ===#
tot_num_wells <- reg_data_CO[, wdid] %>%
  unique() %>%
  length()

hp_changes_num <- reg_data_CO[, .(hp_dev = pump_hp - mean(pump_hp)), by = wdid] %>%
  .[hp_dev != 0, wdid] %>%
  unique() %>%
  length()

# /*=================================================*/
#' # Summary statistics
# /*=================================================*/
mean_ir_CO <- reg_data_CO[, mean(water_use)] %>% round(digits = 2)
mean_gpm_CO <- reg_data_CO[, mean(gpm)] %>%
  round(digits = 2) %>%
  round(digits = 2)
min_gpm_CO <- reg_data_CO[, min(gpm)] %>%
  round(digits = 2) %>%
  round(digits = 2)
max_gpm_CO <- reg_data_CO[, max(gpm)] %>%
  round(digits = 2) %>%
  round(digits = 2)
mean_etw_CO <- reg_data_CO[, mean(etw)] %>%
  round(digits = 2) %>%
  round(digits = 2)
mean_precip_CO <- reg_data_CO[, mean(precip)] %>%
  round(digits = 2) %>%
  round(digits = 2)

# ===================================
# Price variation
# ===================================
# reg_data_CO[, .(p_change = (pc - mean(pc))/pc), by = wdid_tier_hp] %>%
#   .[, p_change] %>% hist

# /*=================================================*/
#' # Analysis
# /*=================================================*/
# /*----------------------------------*/
#' ## FE estimation (well-price tier)
# /*----------------------------------*/
fe_ls_CO <- list()

fe_ls_CO[["only_gpm"]] <- felm(water_use ~
pc + I(pc^2) + gpm + precip + et + gdd | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_CO)

fe_ls_CO[["both"]] <- felm(water_use ~
pc + I(pc^2) + gpm + sat_thickness + precip + et + gdd | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_CO)

fe_ls_CO[["non"]] <- felm(water_use ~
pc + I(pc^2) + precip + et + gdd | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_CO)

fe_ls_CO[["only_sat"]] <- felm(water_use ~
pc + I(pc^2) + sat_thickness + precip + et + gdd | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_CO)

stargazer(fe_ls_CO, type = "text")

# /*----------------------------------*/
#' ## FE estimation (well FE)
# /*----------------------------------*/
fe_ls_CO_bias <- list()

fe_ls_CO_bias[["only_gpm"]] <- felm(water_use ~
pc + I(pc^2) + gpm + precip + et + gdd | wdid + year_REA | 0 | wdid, data = reg_data_CO)

fe_ls_CO_bias[["both"]] <- felm(water_use ~
pc + I(pc^2) + gpm + sat_thickness + precip + et + gdd | wdid + year_REA | 0 | wdid, data = reg_data_CO)

fe_ls_CO_bias[["non"]] <- felm(water_use ~
pc + I(pc^2) + precip + et + gdd | wdid + year_REA | 0 | wdid, data = reg_data_CO)

fe_ls_CO_bias[["only_sat"]] <- felm(water_use ~
pc + I(pc^2) + sat_thickness + precip + et + gdd | wdid + year_REA | 0 | wdid, data = reg_data_CO)

stargazer(fe_ls_CO_bias, type = "text")

# /*----------------------------------*/
#' ## Price elasticity at the mean
# /*----------------------------------*/

mean_y <- reg_data_CO[, mean(water_use)]
mean_pc <- reg_data_CO[, mean(pc)]

reg_type_ls <- c("both", "only_sat", "non", "only_gpm")

get_eta_ls <- function(reg_ls, reg_type_ls) {
  temp <- vector("list", length = length(reg_type_ls))
  names(temp) <- reg_type_ls

  for (i in reg_type_ls) {
    beta_1 <- reg_ls[[i]]$coef["pc", ]
    beta_2 <- reg_ls[[i]]$coef["I(pc^2)", ]

    beta_1_se <- reg_ls[[i]]$clustervcv["pc", "pc"] %>% sqrt()
    beta_2_se <- reg_ls[[i]]$clustervcv["I(pc^2)", "I(pc^2)"] %>% sqrt()

    elasticity_CO_temp <- ((beta_1 + 2 * beta_2 * mean_pc) / mean_y * mean_pc) %>%
      round(digits = 2) %>%
      format(nsmall = 2)

    elasticity_CO_temp_se <- ((beta_1_se + 2 * beta_2_se) / mean_y * mean_pc) %>%
      round(digits = 2) %>%
      format(nsmall = 2) %>%
      paste("(", ., ")", sep = "")

    eta_vec <- c(elasticity_CO_temp, elasticity_CO_temp_se)

    temp[[i]] <- eta_vec
  }

  return(temp)
}

eta_CO <- get_eta_ls(fe_ls_CO, reg_type_ls)


# /*----------------------------------*/
#' ## Correlation coefficient (demeaned data)
# /*----------------------------------*/
cor_wy_pc_CO <- reg_data_CO[, cor(w_pc, w_gpm, use = "pairwise.complete.obs")] %>%
  round(digits = 2)
cor_wy_etw_CO <- reg_data_CO[, cor(w_gpm, w_etw, use = "pairwise.complete.obs")] %>%
  round(digits = 2)
cor_wy_sat_CO <- reg_data_CO[, cor(w_sat, w_gpm, use = "pairwise.complete.obs")] %>%
  round(digits = 2)

# cor_wy_pc_CO <- reg_data_CO[,cor(pc,gpm,use='pairwise.complete.obs')]
# cor_wy_etw_CO <- reg_data_CO[,cor(gpm,etw,use='pairwise.complete.obs')]
# cor_wy_sat_CO <- reg_data_CO[,cor(sat,gpm,use='pairwise.complete.obs')]
#
# /*----------------------------------*/
#' ## How influential is well yield?
# /*----------------------------------*/
#--- 10% change in gpm from the median ---#
delta_gpm_10p_CO <- reg_data_CO[, median(gpm)] * 0.1

#--- change in water use ---#
delta_wu_CO <- fe_ls_CO[["both"]]$coef["gpm", "water_use"] * delta_gpm_10p_CO

#--- well yield elasticity of water demand ---#
well_yield_elasticity_CO <- (delta_wu_CO / delta_gpm_10p_CO * 10) %>%
  round(digits = 2)

# /*=================================================*/
#' # Policy Analysis
# /*=================================================*/
#--- mean pumping ---#
avg_pump <- reg_data_CO[, mean(water_use)]

#--- mean water use ---#
avg_pc <- reg_data_CO[, mean(pc)]

#--- tax ($/acre-inch)---#
water_tax <- 2
water_tax_len <- length(water_tax)

policy_tab_CO <- matrix(0, 2, 5)

beta_1_only_sat <- fe_ls_CO[["only_sat"]]$coef["pc", ]
beta_2_only_sat <- fe_ls_CO[["only_sat"]]$coef["I(pc^2)", ]

beta_1_both <- fe_ls_CO[["both"]]$coef["pc", ]
beta_2_both <- fe_ls_CO[["both"]]$coef["I(pc^2)", ]

# i <- 1
for (i in 1:water_tax_len) {
  temp_water_tax <- water_tax[i]
  pc_after_tax <- avg_pc + temp_water_tax

  #--- without gpm ---#
  delta_ir_wthg <- beta_1_only_sat * temp_water_tax + beta_2_only_sat * (pc_after_tax^2 - avg_pc^2)
  revenue_wthg <- (avg_pump + delta_ir_wthg) * temp_water_tax

  #--- with gpm ---#
  delta_ir_wg <- beta_1_both * temp_water_tax + beta_2_both * (pc_after_tax^2 - avg_pc^2)
  revenue_wg <- (avg_pump + delta_ir_wg) * temp_water_tax

  policy_tab_CO[i + 1, 2] <- paste(
    round(delta_ir_wthg, digits = 2), "(",
    round(delta_ir_wthg / avg_pump * 100, digits = 2), "\\%)"
  )

  pc_CO_biased <- round(delta_ir_wthg / avg_pump * 100, digits = 2)

  policy_tab_CO[i + 1, 3] <- revenue_wthg %>% round(digits = 2)
  policy_tab_CO[i + 1, 4] <- paste(
    round(delta_ir_wg, digits = 2), "(",
    round(delta_ir_wg / avg_pump * 100, digits = 2), "\\%)"
  )
  policy_tab_CO[i + 1, 5] <- revenue_wg %>% round(digits = 2)

  pc_CO_unbiased <- round(delta_ir_wg / avg_pump * 100, digits = 2)
}

policy_tab_CO[, 1] <- c("", "Colorado")
policy_tab_CO[1, ] <- c("State", "Groundwater Use", "Revenue", "Groundwater Use", "Revenue")

# saveRDS(policy_tab,'./Presentations/policy_tab.rds')

# /*=================================================*/
#' # Well yield simulation
# /*=================================================*/
# KS_wy_data <- fread('~/Dropbox/CollaborativeResearch/GW_externality/Data/Kansas/PDIV_YearLevel.csv') %>%
#   setnames(names(.),tolower(names(.))) %>%
#   .[source_g==1,] %>% # get rid of surface water use
#   setkey(wr_id) %>%
#   .[!is.na(af_used) & !is.na(hours_pump) & hours_pump!=0 & af_used!=0,] %>%
#   .[,gpm:=af_used*325851/hours_pump/60,wua_year] %>%
#   .[,.(gpm,wua_year,pdiv_id)] %>%
#   .[,num_obs:=.N,by=pdiv_id] %>%
#   .[num_obs>10,] %>%
#   .[,.(gpm=mean(gpm)),by=wua_year] %>%
#   setorder(wua_year)

KS_wy_data <- readRDS("~/Dropbox/GroundwaterWithMani/WellYieldThreshold/Data/Acres_reg_input_2_updated.rds") %>%
  setnames(names(.), tolower(names(.))) %>%
  setnames(c("wua_year", "group_2"), c("year", "id")) %>%
  .[gpm_avg < 1500, ] %>%
  .[, .(year, id, gpm_avg)] %>%
  .[, num_obs := .N, by = id] %>%
  .[, .(gpm = mean(gpm_avg), num_obs = .N), by = year] %>%
  setorder(year) %>%
  .[year >= 1993, ]

KS_wy_93 <- KS_wy_data[year == 1993, gpm]
KS_wy_05 <- KS_wy_data[year == 2015, gpm]
wy_delta <- KS_wy_93 - KS_wy_05

delta_wu_wy_CO <- fe_ls_CO[["both"]]$coef["gpm", "water_use"] * wy_delta

# /*=================================================*/
#' # Analysis with good dwt data
# /*=================================================*/
reg_data_CO[, sat_dwt := -dwt]
reg_data_usgs <- reg_data_CO[!is.na(dwt), ]

# /*----------------------------------*/
#' ## FE estimation (well-price tier)
# /*----------------------------------*/
fe_ls_CO_rob <- list()

fe_ls_CO_rob[["both"]] <- felm(water_use ~
pc + I(pc^2) + gpm + sat_dwt + precip + et + gdd | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_usgs)

fe_ls_CO_rob[["only_gpm"]] <- felm(water_use ~
pc + I(pc^2) + gpm + precip + et + gdd | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_usgs)

fe_ls_CO_rob[["non"]] <- felm(water_use ~
pc + I(pc^2) + precip + et + gdd | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_usgs)

fe_ls_CO_rob[["only_sat"]] <- felm(water_use ~
pc + I(pc^2) + sat_dwt + precip + et + gdd | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_usgs)

stargazer(fe_ls_CO_rob, type = "text")

# fe_ls_CO_rob <- list()

# fe_ls_CO_rob[['both']] <- felm(water_use ~
#   pc + I(pc^2) + gpm + sat_thickness + precip + et + gdd|wdid_tier_hp+year_REA|0|wdid, data = reg_data_usgs)

# fe_ls_CO_rob[['only_gpm']] <- felm(water_use ~
#   pc + I(pc^2) + gpm + precip + et + gdd|wdid_tier_hp+year_REA|0|wdid, data = reg_data_usgs)

# fe_ls_CO_rob[['non']] <- felm(water_use ~
#   pc + I(pc^2) + precip + et + gdd|wdid_tier_hp+year_REA|0|wdid, data = reg_data_usgs)

# fe_ls_CO_rob[['only_sat']] <- felm(water_use ~
#   pc + I(pc^2) + sat_thickness + precip + et + gdd|wdid_tier_hp+year_REA|0|wdid, data = reg_data_usgs)

# stargazer(fe_ls_CO_rob,type='text')

# /*----------------------------------*/
#' ## Price elasticity at the mean
# /*----------------------------------*/

eta_CO_rob <- get_eta_ls(fe_ls_CO_rob, reg_type_ls)

#--- 10% change in pc: no gpm ---#
mean_y <- reg_data_CO[, mean(water_use)]
mean_pc <- reg_data_CO[, mean(pc)]

beta_1 <- fe_ls_CO_rob[["only_sat"]]$coef["pc", ]
beta_2 <- fe_ls_CO_rob[["only_sat"]]$coef["I(pc^2)", ]

beta_1_se <- fe_ls_CO_rob[["only_sat"]]$clustervcv["pc", "pc"] %>% sqrt()
beta_2_se <- fe_ls_CO_rob[["only_sat"]]$clustervcv["I(pc^2)", "I(pc^2)"] %>% sqrt()

elasticity_CO_only_sat_rob <- ((beta_1 + 2 * beta_2 * mean_pc) / mean_y * mean_pc) %>% round(digits = 2)
elasticity_CO_only_sat_se_rob <- ((beta_1_se + 2 * beta_2 * beta_2_se) / mean_y * mean_pc) %>% round(digits = 2)

#--- 10% change in pc: with gpm ---#
beta_1 <- fe_ls_CO_rob[["both"]]$coef["pc", ]
beta_2 <- fe_ls_CO_rob[["both"]]$coef["I(pc^2)", ]

beta_1_se <- fe_ls_CO_rob[["both"]]$clustervcv["pc", "pc"] %>% sqrt()
beta_2_se <- fe_ls_CO_rob[["both"]]$clustervcv["I(pc^2)", "I(pc^2)"] %>% sqrt()

elasticity_CO_both_rob <- ((beta_1 + 2 * beta_2 * mean_pc) / mean_y * mean_pc) %>% round(digits = 2)
elasticity_CO_both_se_rob <- ((beta_1_se + 2 * beta_2 * beta_2_se) / mean_y * mean_pc) %>% round(digits = 2)


# ===================================
#  Analysis with GDD
# ===================================
# fe_ls_CO_gdd <- list()

# fe_ls_CO_gdd[['only_gpm']] <- felm(water_use ~
#   pc + I(pc^2) + gpm + precip + et + gdd|wdid_tier_hp + year_REA| 0| wdid, data = reg_data_CO)

# fe_ls_CO_gdd[['both']] <- felm(water_use ~
#   pc + I(pc^2) + gpm + sat_thickness + precip + et + gdd|wdid_tier_hp+year_REA|0|wdid, data = reg_data_CO)

# fe_ls_CO_gdd[['non']] <- felm(water_use ~
#   pc + I(pc^2) + precip + et + gdd|wdid_tier_hp+year_REA|0|wdid, data = reg_data_CO)

# fe_ls_CO_gdd[['only_sat']] <- felm(water_use ~
#   pc + I(pc^2) + sat_thickness + precip + et + gdd|wdid_tier_hp+year_REA|0|wdid, data = reg_data_CO)

# stargazer(fe_ls_CO_gdd,type='text')

# /*=================================================*/
#' # Analysis: specification nonlinear PC
# /*=================================================*/

#--------------------------
# Linear
#--------------------------
fe_ls_CO_lin <- list()

fe_ls_CO_lin[["both"]] <- felm(water_use ~
pc + gpm + sat_thickness + precip + et | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_CO)

fe_ls_CO_lin[["only_gpm"]] <- felm(water_use ~
pc + gpm + precip + et | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_CO)

fe_ls_CO_lin[["none"]] <- felm(water_use ~
pc + precip + et | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_CO)

fe_ls_CO_lin[["only_sat"]] <- felm(water_use ~
pc + sat_thickness + precip + et | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_CO)

stargazer(fe_ls_CO_lin, type = "text")

# #--------------------------
# # Log(pc)
# #--------------------------
# fe_ls_CO_log <- list()

# fe_ls_CO_log[['both']] <- felm(water_use ~
#   log(pc) +gpm+sat_thickness+precip+et|wdid_tier_hp+year_REA|0|wdid, data = reg_data_CO)

# fe_ls_CO_log[['only_gpm']] <- felm(water_use ~
#   log(pc) +gpm+precip+et|wdid_tier_hp+year_REA|0|wdid, data = reg_data_CO)

# fe_ls_CO_log[['none']] <- felm(water_use ~
#   log(pc) +precip+et|wdid_tier_hp+year_REA|0|wdid, data = reg_data_CO)

# fe_ls_CO_log[['only_sat']] <- felm(water_use ~
#   log(pc) +sat_thickness+precip+et|wdid_tier_hp+year_REA|0|wdid, data = reg_data_CO)

# stargazer(fe_ls_CO_log,type='text')

# #++++++++++++++++
# # Elasticity estimates
# #++++++++++++++++
# mean_y <- reg_data_CO[,mean(water_use)]

# eta_only_sat_log <- fe_ls_CO_log[['only_sat']]$coef['log(pc)',]/mean_y
# eta_both_log <- fe_ls_CO_log[['both']]$coef['log(pc)',]/mean_y

#--------------------------
# Non-parametric
#--------------------------
data_nonpar <- reg_data_CO[, .(water_use, pc, gpm, sat_thickness, precip, et, wdid_tier_hp, year_REA, wdid)] %>%
  na.omit()

library(mgcv)

#--- pc fully non-parametric ---#
# reg_np_1 <- gam(water_use ~ s(pc, k = 6) + gpm + sat_thickness+precip+et + factor(wdid_tier_hp)+factor(year_REA), data = data_nonpar)
# saveRDS(reg_np_1, "./Data/np_reg_pc")

reg_np_1 <- readRDS("./Data/np_reg_pc")

# plot_data <- plot(reg_np_1)
#
# saveRDS(plot_data, "./Data/plot_data.rds")
#
#--- pc quadratic ---#
# reg_np_sq <- gam(water_use ~ pc + I(pc^2) + gpm + sat_thickness+precip+et + factor(wdid_tier_hp)+factor(year_REA), data = data_nonpar)
# saveRDS(reg_np_sq, "./Data/sq_reg_pc")

reg_np_sq <- readRDS("./Data/sq_reg_pc")

#--- test the improvement ---#
test_improve <- anova(reg_np_1, reg_np_sq, test = "Chisq")

#--------------------------
# Visualization
#--------------------------
plot_data <- readRDS("./Data/plot_data.rds")

data_plot <- data.table(
  pc = plot_data[[1]]$x,
  se = plot_data[[1]]$se,
  yhat = plot_data[[1]]$fit[, 1] + reg_data_CO[, mean(water_use)]
) %>%
  .[, yhat_up := yhat + 1.96 * se] %>%
  .[, yhat_down := yhat - 1.96 * se]

data_sq <- copy(data_plot) %>%
  .[, yhat := fe_ls_CO[["both"]]$coef["pc", ] * pc + fe_ls_CO[["both"]]$coef["I(pc^2)", ] * pc^2 + 317]

data_lin <- copy(data_plot) %>%
  .[, yhat := fe_ls_CO_lin[["both"]]$coef["pc", ] * pc + 265]

# g_nonpar <- ggplot(data = data_plot[pc < 6, ]) +
#   geom_ribbon(aes(ymin = yhat_down, ymax = yhat_up, x = pc), fill = "red", alpha = 0.3) +
#   geom_line(aes(y = yhat, x = pc)) +
#   ylab("Irrigation (acre-feet)") +
#   xlab("Pumping cost ($/acre-inch)")

g_nonpar_comp <- ggplot(data = data_plot[pc < 6, ]) +
  geom_line(aes(y = yhat, x = pc)) +
  ylab("Irrigation (acre-feet)") +
  xlab("Pumping cost ($/acre-inch)") +
  geom_line(data = data_sq[pc < 6], aes(y = yhat, x = pc), color = "blue") +
  geom_line(data = data_lin[pc < 6], aes(y = yhat, x = pc), color = "red")

g_pc_hist <- ggplot(data = reg_data_CO) +
  geom_histogram(aes(x = pc), color = "blue", fill = "white") +
  xlab("Pumping cost ($/acre-inch)")

ggsave(g_nonpar_comp, file = "./Figures/plot_non_par.pdf", height = 4, width = 6)
ggsave(g_pc_hist, file = "./Figures/hist_pc.pdf", height = 4, width = 6)


# /*=================================================*/
#' # Robustness check (irrigation technology)
# /*=================================================*/
# /*----------------------------------*/
#' ## FE estimation (well-price tier)
# /*----------------------------------*/
fe_ls_CO_tech <- list()

fe_ls_CO_tech[["only_gpm"]] <- felm(water_use ~
pc + I(pc^2) + gpm + precip + et + gdd | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_CO[year <= 2013, ])

fe_ls_CO_tech[["both"]] <- felm(water_use ~
pc + I(pc^2) + gpm + sat_thickness + precip + et + gdd | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_CO[year <= 2013, ])

fe_ls_CO_tech[["non"]] <- felm(water_use ~
pc + I(pc^2) + precip + et + gdd | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_CO[year <= 2013, ])

fe_ls_CO_tech[["only_sat"]] <- felm(water_use ~
pc + I(pc^2) + sat_thickness + precip + et + gdd | wdid_tier_hp + year_REA | 0 | wdid, data = reg_data_CO[year <= 2013, ])

stargazer(fe_ls_CO_tech, type = "text")

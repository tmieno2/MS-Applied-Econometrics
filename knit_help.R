library(knitr)
library(rmarkdown)
library(here)
library(xaringanBuilder)

# /*===========================================================
#' # Introduction
# /*===========================================================
rmarkdown::render(here("LectureNotes/Introduction/Introduction_x.rmd"))
build_pdf(here("LectureNotes/Introduction/Introduction_x.html"))

# /*===========================================================
#' # Univariate Regression
# /*===========================================================
rmarkdown::render(here("LectureNotes/1_UnivariateRegression/univariate_regression_x.rmd"))
build_pdf(here("LectureNotes/1_UnivariateRegression/univariate_regression_x.html"))

# /*===========================================================
#' # Multivariate Regression
# /*===========================================================
rmarkdown::render(here("LectureNotes/2_MultivariateRegression/multivariate_regression_x.rmd"))
build_pdf(here("LectureNotes/2_MultivariateRegression/multivariate_regression_x.html"))

# /*===========================================================
#' # MC
# /*===========================================================
rmarkdown::render(here("LectureNotes/3_MonteCarloSimulation/MC_x.rmd"))
build_pdf(here("LectureNotes/3_MonteCarloSimulation/MC_x.html"))
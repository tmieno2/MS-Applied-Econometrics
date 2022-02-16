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
#' # 3. MC
# /*===========================================================
rmarkdown::render(here("LectureNotes/3_MonteCarloSimulation/MC_x.rmd"))
build_pdf(here("LectureNotes/3_MonteCarloSimulation/MC_x.html"))

# /*===========================================================
#' # 4. Omitted Variable/Multicollinearity
# /*===========================================================
rmarkdown::render(here("LectureNotes/4_OmittedVariableMulticollinear/OmittedMulticollinear_x.rmd"))
build_pdf(here("LectureNotes/4_OmittedVariableMulticollinear/OmittedMulticollinear_x.html"))

# /*===========================================================
#' # 5. Hypothesis Testing
# /*===========================================================
rmarkdown::render(here("LectureNotes/5_Testing/testing_x.rmd"))
build_pdf(here("LectureNotes/5_Testing/testing_x.html"))

# /*===========================================================
#' # 6. Hypothesis Testing
# /*===========================================================
rmarkdown::render(here("LectureNotes/6_StandardErrorEstimation/se_estimation_x.rmd"))
build_pdf(here("LectureNotes/6_StandardErrorEstimation/se_estimation_x.html"))
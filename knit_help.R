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
#' # 6. Standard Error Estimation
# /*===========================================================
rmarkdown::render(here("LectureNotes/6_StandardErrorEstimation/se_estimation_x.rmd"))
build_pdf(here("LectureNotes/6_StandardErrorEstimation/se_estimation_x.html"))

# /*===========================================================
#' # 7. Econometric Model
# /*===========================================================
rmarkdown::render(here("LectureNotes/7_EconometricModel/modeling_x.rmd"))
build_pdf(here("LectureNotes/7_EconometricModel/modeling_x.html"))

# /*===========================================================
#' # 8. Asymptotics
# /*===========================================================
rmarkdown::render(here("LectureNotes/8_Asymptotics/asymptotics_x.rmd"))
build_pdf(here("LectureNotes/8_Asymptotics/asymptotics_x.html"))

# /*===========================================================
#' # 9. Endogeneity
# /*===========================================================
rmarkdown::render(here("LectureNotes/9_Endogeneity/endogeneity_x.rmd"))
build_pdf(here("LectureNotes/9_Endogeneity/endogeneity_x.html"))

# /*===========================================================
#' # 10. Identification
# /*===========================================================
rmarkdown::render(here("LectureNotes/10_Identification/identification_x.rmd"))
build_pdf(here("LectureNotes/10_Identification/identification_x.html"))

# /*===========================================================
#' # 11. Panel Data
# /*===========================================================
rmarkdown::render(here("LectureNotes/11_Panel/panel_x.rmd"))
build_pdf(here("LectureNotes/11_Panel/panel_x.html"))


# /*===========================================================
#' # A1 Summary Questions
# /*===========================================================
rmarkdown::render(here("LectureNotes/A1_SummaryQuestions/questions_x.rmd"))

build_pdf(here("LectureNotes/A1_SummaryQuestions/questions_x.html"))

# /*===========================================================
#' # A2 Paper Expectation
# /*===========================================================
rmarkdown::render(here("LectureNotes/A2_PaperExpectation/paper_expectation_x.rmd"))

build_pdf(here("LectureNotes/A2_PaperExpectation/paper_expectation_x.html"))
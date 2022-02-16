rm(list = ls())

clusters <- 30
obs_per_cluster <- 3

corr_x <- 0.7
mean_x <- 10
sd_x <- 2

mean_ep <- 0
sd_ep <- 7
corr_ep <- 0.7
beta0 <- 0
beta1 <- 2

x_reps <- 1
reps <- 1000

# set.seed(5000)


m <- obs_per_cluster
C <- clusters
N <- C * m
is.installed <- function(mypkg) is.element(mypkg, installed.packages()[, 1])
installed_value <- as.numeric(is.installed("survey"))
if (installed_value == 0) {
  install.packages("survey", dependencies = T)
}

installed_value <- as.numeric(is.installed("Hmisc"))
if (installed_value == 0) {
  install.packages("Hmisc", dependencies = T)
}

installed_value <- as.numeric(is.installed("sandwich"))
if (installed_value == 0) {
  install.packages("sandwich", dependencies = T)
}

library(survey)
library(Hmisc)
library(sandwich)
begin_time <- proc.time()
# setwd("C:/Users/manuraghav/Documents/de/Research/Complex Survey/Second Article")

current_date <- gsub("/", "-", format(Sys.Date(), "%m/%d/%Y"))
current_time <- gsub(":", "-", format(Sys.time(), "%I:%M %p"))
sink_file_name <- paste("cluster paper R sink file, ", "date=", current_date, ", time=", current_time, ".txt", sep = "", collapse = NULL)
sink(sink_file_name, split = T)



# set.seed(5000)

m <- obs_per_cluster
C <- clusters
N <- C * m

cat("\n", "\n", "\n", "\n", "\n", "\n", "\n", "\n")
cat(format(Sys.Date(), "%A, %B %d, %Y"))
cat("\n")
cat("Barreto and Raghav (2013) \n")
cat("R Script File")
cat("\n", "\n")
cat("Number of Independent Draws of X:", x_reps, "\n")
cat("Number of Repetitions for Each Draw of X:", reps, "\n", "\n")
cat("\n")
Sys.sleep(4)


for (Outer_i in 1:x_reps) {
  n <- 0
  cat("\n")
  cat("Draw", Outer_i, "of X \n")
  x <- matrix(0, N, 1)
  corr_mat_X <- diag(m)
  for (i in 1:m) {
    for (j in 1:m) {
      if (i != j) {
        corr_mat_X[i, j] <- corr_x
      }
    }
  }

  for (k in 1:C) {
    Corr_chol <- chol(corr_mat_X)
    Corr_chol <- t(Corr_chol)

    NormArray <- rnorm(m, mean = 0, sd = 1)
    NormArray <- as.matrix(NormArray)

    for (J in 1:m) {
      Result <- 0
      for (K in 1:J) {
        Result <- Result + Corr_chol[J, K] * NormArray[K, 1]
      }
      n <- n + 1
      x[n, 1] <- Result * sd_x + mean_x
    }
  }

  summary(x)

  ols_mean <- 0
  approx_se <- 0
  se_cluster_mean <- 0
  se_robust_mean <- 0
  se_classic_mean <- 0
  approx_ss <- 0

  slope_coef_array <- array(NA, dim = c(x_reps, reps))
  se_OLS_array <- array(NA, dim = c(x_reps, reps))
  se_robust_array <- array(NA, dim = c(x_reps, reps))
  se_cluster_array <- array(NA, dim = c(x_reps, reps))

  cat("\n")
  for (r in 1:reps) {
    cat(".")
    if (r %% 50 == 0) {
      cat(" (", r, ") ", "\n", sep = "")
    }


    corr_mat_ep <- diag(m)
    for (i in 1:m) {
      for (j in 1:m) {
        if (i != j) {
          corr_mat_ep[i, j] <- corr_ep
        }
      }
    }

    ep <- matrix(0, N, 1)
    n <- 0
    for (k in 1:C) {
      Corr_chol <- chol(corr_mat_ep)
      Corr_chol <- t(Corr_chol)

      NormArray <- rnorm(m, mean = 0, sd = 1)
      NormArray <- as.matrix(NormArray)


      for (J in 1:m) {
        Result <- 0
        for (K in 1:J) {
          Result <- Result + Corr_chol[J, K] * NormArray[K, 1]
        }
        n <- n + 1
        ep[n, 1] <- Result * sd_ep + mean_ep
      }
    }

    y <- beta0 + beta1 * x + ep
    regression <- lm(y ~ x)
    summary(regression)

    slope_coef_array[Outer_i, r] <- coef(regression)["x"]
    se_OLS_array[Outer_i, r] <- sqrt(vcov(regression)["x", "x"])

    se_robust_array[Outer_i, r] <- sqrt(vcovHC(regression)["x", "x"])

    # Cluster SEs

    index <- 1:N
    clusterid <- floor(((index - 1) / m)) + 1
    wt <- matrix(1, N, 1)
    data <- data.frame(x, y, wt, clusterid)

    design <- svydesign(id = ~clusterid, data = data, weights = ~wt)
    clusterregression <- svyglm(y ~ x, design = design)
    se_cluster_array[Outer_i, r] <- sqrt(vcov(clusterregression)["x", "x"])
    icc_x <- as.numeric(deff(x, clusterid)[3])
    # Approximate SE

    sigma2 <- diag(m)

    for (i in 1:m) {
      for (j in 1:m) {
        if (i == j) {
          sigma2[i, j] <- sd_ep * sd_ep
        }
      }
    }

    D <- matrix(0, 2, 2)
    xsigma2rhox <- matrix(0, 2, 2)
    ones <- matrix(1, m, 1)

    matrix_a <- matrix(0, m, 1)

    j_a <- 1
    for (i_a in 1:C) {
      k_a <- i_a * m
      matrix_a <- x[j_a:k_a, 1]
      matrix_a <- cbind(ones, matrix_a)
      j_a <- j_a + m

      xsigma2rhox <- t(matrix_a) %*% sigma2 %*% corr_mat_ep %*% matrix_a
      D <- D + xsigma2rhox
    }

    ones <- matrix(1, N, 1)
    matrix_x <- cbind(ones, x)
    V <- solve(t(matrix_x) %*% matrix_x) %*% D %*% solve(t(matrix_x) %*% matrix_x)

    exact_se <- sqrt(V[2, 2])
  }

  approx_se <- sd(as.numeric(slope_coef_array[Outer_i, ]))

  slope_coef_mean <- mean(slope_coef_array[Outer_i, ])
  se_OLS_mean <- mean(se_OLS_array[Outer_i, ])
  se_robust_mean <- mean(se_robust_array[Outer_i, ])
  se_cluster_mean <- mean(se_cluster_array[Outer_i, ])

  cat("\n", "\n")
  cat("Numbers of Repetitions:", reps, "\n")
  cat("Number of Clusters:", clusters, "\n")
  cat("Rho of Epsilons:", corr_ep, "\n")
  cat("Number of Observations per Cluster:", obs_per_cluster, "\n", "\n")

  cat("Slope Coefficient:", slope_coef_mean, "\n")
  cat("Intracluster Correlation of X:", icc_x, "\n")
  cat("\n")
  cat("Classic SE:", se_OLS_mean, "\n")
  cat("Robust SE:", se_robust_mean, "\n")
  cat("Cluster SE:", se_cluster_mean, "\n")
  cat("Exact SE:", exact_se, "\n")
  cat("Approximate SE:", approx_se, "\n")
}

sink()

cat("\n", " Time Taken in Minutes: \n")
time_taken <- (proc.time() - begin_time) / 60
print(time_taken)
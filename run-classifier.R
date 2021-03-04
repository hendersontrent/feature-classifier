#-------------------------------------------------
# This script sets out to produce a classification
# algorithm using feature space time series
# statistics
#-------------------------------------------------

#--------------------------------------
# Author: Trent Henderson, 4 March 2021
#--------------------------------------

#--------------------- Load in feature data & split ----------------

tmp <- read_csv("/Users/trenthenderson/Documents/git/feature-classifier/catch22_results.csv")

# Train-test split

set.seed(123) 
split <- sample.split(tmp$ra_name_2016, SplitRatio = 0.75) 
train <- subset(tmp, split == TRUE) 
test <- subset(tmp, split == FALSE)

# Scale features

train[-3] = scale(train[-3]) 
test[-3] = scale(test[-3]) 

#--------------------- Build classifier model ----------------------

# Set up inputs for Stan

stan_data <- list(N = nrow(train),
                  K = ncol(model.matrix(remoteness_area_2016 ~ . -1, data = train)),
                  y = train$remoteness_area_2016,
                  X = model.matrix(remoteness_area_2016 ~ . -1, data = train),
                  N_test = nrow(test),
                  X_test = model.matrix(remoteness_area_2016 ~ . -1, data = test))

# Run model

m1 <- stan(model_code = "stan/classifier-model.stan", data = stan_data, chains = 3, iter = 2000, seed = 123)

#--------------------- Compute outputs & data vis -----------------

# Examine predictive accuracy

fit <- extract(m1)
mean(apply(fit$y_test, 2, median) == y_test)

# Diagnostic 1: Chain convergence

mcmc_trace(m1)

# Diagnostic 2: LOO

loo1 <- loo(m1, save_psis = TRUE)
plot(loo1)

# Diagnostic 3: Posterior predictive checks

pp_check(m1, type = "bars", nsamples = 100) +
  labs(title = "Posterior predictive check",
       x = "Remoteness Classification",
       y = "Count")

# Diagnostic 4: Posterior predictive checks (cumulative probability function)

pp_check(m1, type = "ecdf_overlay", nsamples = 100) +
  labs(title = "Posterior predictive check of cumulative probability function",
       x = "Remoteness Classification",
       y = "Cumulative Probability")

# Summative data visualisation

mcmc_intervals(m1) +
  labs(title = "Coefficient posterior distributions")

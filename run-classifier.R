#-------------------------------------------------
# This script sets out to produce a classification
# algorithm using feature space time series
# statistics
#-------------------------------------------------

#--------------------------------------
# Author: Trent Henderson, 4 March 2021
#--------------------------------------

#--------------------- Load in feature data & split ----------------

load("data/computed-features.Rda")

tmp <- outs %>%
  group_by(perm_res_postcode, ra_name_2016, names) %>%
  summarise(values = mean(values)) %>%
  ungroup() %>%
  spread(key = names, value = values) %>%
  drop_na()

# Train-test split

set.seed(123) 
split <- sample.split(tmp$ra_name_2016, SplitRatio = 0.75) 
train <- subset(tmp, split == TRUE) 
test <- subset(tmp, split == FALSE)

# Scale features

train[-c(1,2)] = scale(train[-c(1,2)]) 
test[-c(1,2)] = scale(test[-c(1,2)])

train <- train %>%
  dplyr::select(-c(1,21,22))

test <- test %>%
  dplyr::select(-c(1,21,22))

#--------------------- Build classifier model ----------------------

options(mc.cores = parallel::detectCores())

m1 <- brm(formula = ra_name_2016 ~ 1 + ., 
          data = train, 
          family = bernoulli(link = "logit"),
          iter = 2000, chains = 3, seed = 123)

#--------------------- Compute outputs & data vis -----------------

# Check classification accuracy

Pred <- predict(m1, type = "response")
Pred <- if_else(Pred[,1] > 0.5, 1, 0)
ConfusionMatrix <- table(Pred, pull(train, ra_name_2016))
sum(diag(ConfusionMatrix))/sum(ConfusionMatrix) # 77.5%

# Diagnostic 1: Chain convergence

CairoPNG("output/traceplot.png",600,400)
mcmc_trace(m1)
dev.off()

# Diagnostic 2: LOO

CairoPNG("output/loo.png",600,400)
loo1 <- loo(m1, save_psis = TRUE)
plot(loo1)
dev.off()

# Diagnostic 3: Posterior predictive checks

CairoPNG("output/ppc.png",600,400)
pp_check(m1, type = "bars", nsamples = 100) +
  labs(title = "Posterior predictive check",
       x = "Remoteness Classification",
       y = "Count")
dev.off()

# Diagnostic 4: Posterior predictive checks (cumulative probability function)

CairoPNG("output/ppc_cpf.png",600,400)
pp_check(m1, type = "ecdf_overlay", nsamples = 100) +
  labs(title = "Posterior predictive check of cumulative probability function",
       x = "Remoteness Classification",
       y = "Cumulative Probability")
dev.off()

# Summative data visualisation

CairoPNG("output/intervals.png",600,400)
mcmc_intervals(m1, regex_pars = c("b_")) +
  labs(title = "Coefficient posterior distributions")
dev.off()

CairoPNG("output/areas.png",600,400)
mcmc_areas(m1, regex_pars = c("b_"), area_method = "scaled height") +
  labs(title = "Coefficient posterior distributions")
dev.off()

#--------------------- Heatmap for good measure -------------------

heat <- tmp

heat[-c(1,2)] = scale(heat[-c(1,2)]) 

heat_scaled <- heat %>%
  dplyr::select(-c(21,22)) %>%
  gather(key = names, value = values, 3:22)

CairoPNG("output/heatmap.png",800,600)
heat_scaled %>%
  ggplot(aes(x = names, y = perm_res_postcode, fill = values)) +
  geom_tile() +
  labs(title = "Heatmap of catch22 features and individual time series",
       x = "catch22 feature",
       y = "Time series",
       fill = "Scaled feature value") +
  theme_bw() +
  scale_fill_gradient(low = "#2f4b7c", high = "#ff6361") +
  theme(axis.text.y = element_blank(),
        axis.text.x = element_text(angle = 90),
        legend.position = "bottom")
dev.off()

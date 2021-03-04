//
// This Stan program aims to build a classification
// algorithm of time series feature outputs from catch22
// to predict membership of a postcode in a Major City or 
// not (as defined by ABS Remoteness Areas)
//

//
// Author: Trent Henderson, 4 March 2021
//

data {
  
  // Define input variables
  
  int<lower=0> N; // Number of observations
  int<lower=0> K; // Number of parameters
  int y[N]; // Outcome variable of remoteness category
  matrix[N,K] X; // Predictor variables (catch22 feature values)
  
  // Data for the prediction component
  
  int<lower=0> N_test; // Number of observations in test set
  matrix[N_test,K] X_test; // Predictor variables (catch22 feature values) in test set
}

parameters {
  
  // Define quantities to be estimated
  
  real alpha; // Intercept
  vector[K] beta; // Regression coefficients
}

transformed parameters {
  
  // Instantiate variable to hold real output
  
  vector[N] eta;
  
  // Fit linear model
  
  eta = alpha + beta*X;
}

model {
  
  // Priors
  
  alpha ~ cauchy(0,5);
  beta ~ student_t(7,0,2.5); // Quite wide prior given usually large scale of logit coefficients
  
  // Likelihood
  
  y ~ bernoulli_logit(eta);
}

generated quantities {
  
  // Simulate data from the posterior
    
  vector[N] y_rep;
  
  // Log-likelihood posterior
  
  vector[N] log_lik;
  
  for(i in 1:N){
    y_rep[i] = bernoulli_rng(inv_logit(eta[i]));
  }
  
  for(i in 1:N){
    log_lik[i] = bernoulli_logit_lpmf(y[i] | eta[i]);
  }
  
  // Predictions on test set
  
  vector[N_test] y_test; // Instantiate prediction variable
  
  for(i in 1:N_test){
    y_test[i] = bernoulli_rng(inv_logit(alpha + beta*X_test[i]));
  }
}

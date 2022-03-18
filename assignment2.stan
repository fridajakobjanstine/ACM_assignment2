//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data is a vector 'y' of length 'N'.
data {
  int<lower = 0> n;
  array[n] int h;
  
  vector<lower=-1, upper=1>[n] heads_bias; 
  vector<lower=-1, upper=1>[n] tails_bias;
  
  real alpha_prior_mean;
  real beta_prior_mean;
  real beta2_prior_mean;
  
  real<lower=0> alpha_prior_sd;
  real<lower=0> beta_prior_sd;
  real<lower=0> beta2_prior_sd;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real alpha;
  real beta;
  real beta2; 
  
} 

transformed parameters{
  vector[n] theta;
  theta = alpha + beta * heads_bias + beta2 * tails_bias;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  target += normal_lpdf(alpha | alpha_prior_mean, alpha_prior_sd);
  target += normal_lpdf(beta | beta_prior_mean, beta_prior_sd);
  target += normal_lpdf(beta2 | beta2_prior_mean, beta2_prior_sd);
  
  target += bernoulli_logit_lpmf(h | theta);
  
}

generated quantities{
  real alpha_prior;
  real beta_prior;
  real beta2_prior;
    
  int<lower=0, upper=n> prior_preds;
  int<lower=0, upper=n> posterior_preds;
  
  alpha_prior = normal_rng(alpha_prior_mean, alpha_prior_sd);
  beta_prior = normal_rng(beta_prior_mean, beta_prior_sd);
  beta2_prior = normal_rng(beta2_prior_mean, beta2_prior_sd);

  #prior_preds = to_vector(binomial_rng(n, inv_logit(alpha_prior + beta_prior * stay_bias + beta2_prior * leave_bias)));
  #posterior_preds = to_vector(binomial_rng(n, inv_logit(alpha + beta * stay_bias + beta2 * leave_bias)));
}



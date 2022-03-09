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
  
  vector<lower=-1, upper=1>[n] win_bias; 
  vector<lower=-1, upper=1>[n] loose_bias;
  
  real alpha_prior_mean;
  real win_beta_prior_mean;
  real loose_beta_prior_mean;
  
  real<lower=0> alpha_prior_sd;
  real<lower=0> win_beta_prior_sd;
  real<lower=0> loose_beta_prior_sd;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real alpha;
  real win_beta;
  real loose_beta; 
  
} 

transformed parameters{
  vector[n] theta;
  theta = alpha + win_beta * win_bias + loose_beta * loose_bias;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  target += normal_lpdf(alpha | alpha_prior_mean, alpha_prior_sd);
  target += normal_lpdf(win_beta | win_beta_prior_mean, win_beta_prior_sd);
  target += normal_lpdf(loose_beta | loose_beta_prior_mean, loose_beta_prior_sd);
  
  target += bernoulli_logit_lpmf(h | alpha + win_beta * win_bias + loose_beta * loose_bias);
  
}

generated quantities{
  real alpha_prior;
  real win_beta_prior;
  real loose_beta_prior;
    
  array[n] int posterior_preds;

  alpha_prior = normal_rng(alpha_prior_mean, alpha_prior_sd);
  win_beta_prior = normal_rng(win_beta_prior_mean, win_beta_prior_sd);
  loose_beta_prior = normal_rng(loose_beta_prior_mean, loose_beta_prior_sd);

  //prior_preds = binomial_rng(n, inv_logit(alpha_prior + beta_prior * heads_bias + beta2_prior * tails_bias));
  posterior_preds = binomial_rng(n, inv_logit(alpha + win_beta * win_bias + loose_beta * loose_bias));
}



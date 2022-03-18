\\ DATA BLOCK: In this block we specify what data the STAN model can expect, i.e., it is values and variables we already have and wish to use in the model
\\ There will be n trials  and an array named h of length n with intergers.
\\ There will be two vectors of length n called win_bias and lose_bias, respectively
\\ There will be real numbers indicating the mean and sd of the priors for alpha, win_beta and lose_beta
data {
  int<lower = 0> n; \\ n is an integer bounded at zero
  array[n] int h; \\ h is an array of integers, the length og h is n
  
  vector<lower=-1, upper=1>[n] win_bias;  \\ win_bias is a vector bounded between -1 and 1, length is n
  vector<lower=-1, upper=1>[n] lose_bias; \\ lose_bias is a vector bounded between -1 and 1, length is n
  
  real alpha_prior_mean;    \\ alpha_prior_mean is a real number 
  real win_beta_prior_mean; \\ win_beta_prior_mean is a real number
  real lose_beta_prior_mean; \\ lose_beta_prior_mean is a real number
  
  real<lower=0> alpha_prior_sd;     \\ alpha_prior_sd is a real number bounded at 0
  real<lower=0> win_beta_prior_sd;  \\ win_beta_prior_sd is a real number bounded at 0
  real<lower=0> lose_beta_prior_sd; \\ lose_beta_prior_sd is a real number bounded at 0
}

\\ PARAMETERS BLOCK: In this block we specify the parameters we want the model to estimate
parameters {
  real alpha;     \\ Estimate the real number alpha
  real win_beta;  \\ Estimate the real number win_beta
  real lose_beta; \\ Estimate the real number lose_beta
} 

\\ TRANSFORMED PARAMETERS BLOCK: In this block we inform about the parameter theta that is dependent of the other parameters and variables
\\ This is what we are actually interested in, but it is not directly estimated. We specify it here to be able to extract it from the model directly

transformed parameters{
  vector[n] theta; \\ theta is a vector of length n
  \\ theta is given by the formula consiting of the estimated real number parameters and the input data vectors
  theta = alpha + win_beta * win_bias + lose_beta * lose_bias; 
}

\\ MODEL BLOCK: Here we specify how the model is set up. We specify that the parameters depend on the priors 
model {
  \\ The parameter alpha comes from a normal distribution with mean=alpha_prior_mean and sd=alpha_prior_sd
  target += normal_lpdf(alpha | alpha_prior_mean, alpha_prior_sd);
  \\ The parameter win_beta comes from a normal distribution with mean=win_beta_prior_mean and sd=win_beta_prior_sd
  target += normal_lpdf(win_beta | win_beta_prior_mean, win_beta_prior_sd);
  \\ The parameter lose_beta comes from a normal distribution with mean=lose_beta_prior_mean and sd=lose_beta_prior_sd
  target += normal_lpdf(lose_beta | lose_beta_prior_mean, lose_beta_prior_sd);
  
  \\ the array h is given by the formula using the to-be estimated parameters alpha, win_beta, lose_beta and the data variables win_bias and lose_bias
  target += bernoulli_logit_lpmf(h | alpha + win_beta * win_bias + lose_beta * lose_bias);
}

\\ GENERATED QUANTITIES BLOCK: This block is for extracting quantities of interest to us. 
\\ It is not necessary for the model to run, but we use for extracting values and variables to make PP check, prior-posterior update checks etc. 
generated quantities{
  real alpha_prior;     \\ alpha_prior is a real number
  real win_beta_prior;  \\ win_beta_prior is a real number
  real lose_beta_prior; \\ lose_beta_prior is a real number
    
  array[n] int posterior_preds; \\ posterior_preds is an array of length n consisting of integers

  \\ normal_rng = normal random number generator
  \\ alpha_prior should be drawn randomly from a normal distribution with mean=alpha_prior_mean and sd=alpha_prior_sd
  alpha_prior = normal_rng(alpha_prior_mean, alpha_prior_sd);
  \\ win_beta_prior should be drawn randomly from a normal distribution with mean=win_beta_prior_mean and sd=win_beta_prior_sd
  win_beta_prior = normal_rng(win_beta_prior_mean, win_beta_prior_sd);
  \\ lose_beta_prior should be drawn randomly from a normal distribution with mean=lose_beta_prior_mean and sd=lose_beta_prior_sd
  lose_beta_prior = normal_rng(lose_beta_prior_mean, lose_beta_prior_sd);

  \\ prior_preds (the prior predictions) should be randomly drawn from a binomial distribution 
  \\ of n observations with a bias=inverse logit of the specified formula
  prior_preds = binomial_rng(n, inv_logit(alpha + win_beta * win_bias + lose_beta * lose_bias));
  \\ posterior_preds (the posterior predictions) should be randomly drawn from a binomial distribution 
  \\ of n observations with a bias=inverse logit of the specified formula
  posterior_preds = binomial_rng(n, inv_logit(alpha + win_beta * win_bias + lose_beta * lose_bias));
}



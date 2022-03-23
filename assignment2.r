# Load packages
install.packages("pacman")
library(pacman)
pacman::p_load(tidyverse, here, posterior, brms, sigmoid, remotes)
remotes::install_github("stan-dev/cmdstanr")

# Defining function for converting log odds to probability
logit2prob <- function(logit){
  odds <- exp(logit)
  prob <- odds / (1 + odds)
  return(prob)
}


#################################
#### PRIOR SENSITIVITY CHECK ####
#################################

# Read data
d  <- read.csv("feedback_agent_10000_trials.csv")

# Lag the two columns, use 0 as default
d <- d %>% 
  group_by(rate) %>% 
  mutate(win_bias_lag = dplyr::lag(Win_bias, default = 0),
         lose_bias_lag = dplyr::lag(Lose_bias, default = 0))

# Subset to 1 rate
data <- d %>% 
  subset(rate == 0.7) 

# Define different priors
alpha_prior_mean <- seq(-.5, .5, .5) 
win_beta_prior_mean <- seq(0, 1, .5)
lose_beta_prior_mean <- seq(0, 1, .5)

alpha_prior_sd <- c(1) 
win_beta_prior_sd <- c(.5) 
lose_beta_prior_sd <- c(.5) 

# Generate all possible combinations of prior-parameters
priors <-  expand.grid(alpha_prior_mean, win_beta_prior_mean, lose_beta_prior_mean,
                    alpha_prior_sd, win_beta_prior_sd, lose_beta_prior_sd)

# Convert table to tibble
priors <-  tibble(alpha_prior_mean=priors$Var1, win_beta_prior_mean=priors$Var2, lose_beta_prior_mean=priors$Var3,
               alpha_prior_sd=priors$Var4, win_beta_prior_sd=priors$Var5, lose_beta_prior_sd=priors$Var6)

# Load STAN model
file <- file.path("assignment2.stan")
mod <-  cmdstanr::cmdstan_model(file, cpp_options = list(stan_threads = TRUE))

# Looping through priors
for (p in seq(nrow(priors))){
  
  # Specify data
  d <- list(
    n = nrow(data), 
    h = data$agent_choices, 
    # win_bias = data$Win_bias, 
    # lose_bias = data$Lose_bias,
    win_bias = data$win_bias_lag, 
    lose_bias = data$lose_bias_lag,
    alpha_prior_mean=priors$alpha_prior_mean[p],
    win_beta_prior_mean=priors$win_beta_prior_mean[p],
    lose_beta_prior_mean=priors$lose_beta_prior_mean[p],
    alpha_prior_sd=priors$alpha_prior_sd[p],
    win_beta_prior_sd=priors$win_beta_prior_sd[p],
    lose_beta_prior_sd=priors$lose_beta_prior_sd[p])
  
  # Fit STAN model
  samples <- mod$sample(
    data = d,
    seed = 123,
    chains = 2,
    parallel_chains = 2,
    threads_per_chain = 2,
    iter_warmup = 1000,
    iter_sampling = 1000,
    refresh = 500,
    max_treedepth = 20,
    adapt_delta = 0.99)
  
  # Get model summary
  model_sum <- samples$summary()
  
  # Return model defined priors and posteriors
  draws_df <- as_draws_df(samples$draws())
  temp <- tibble(alpha = draws_df$alpha,
                 win_beta = draws_df$win_beta,
                 lose_beta = draws_df$lose_beta,
                 alpha_sd = model_sum[2,4][[1]],
                 win_beta_sd = model_sum[3,4][[1]],
                 lose_beta_sd = model_sum[4,4][[1]],
                 alpha_prior = draws_df$alpha_prior,
                 win_beta_prior = draws_df$win_beta_prior,
                 lose_beta_prior = draws_df$lose_beta_prior,
                 alpha_prior_mean=priors$alpha_prior_mean[p],
                 win_beta_prior_mean=priors$win_beta_prior_mean[p],
                 lose_beta_prior_mean=priors$lose_beta_prior_mean[p],
                 alpha_prior_sd=priors$alpha_prior_sd[p],
                 win_beta_prior_sd=priors$win_beta_prior_sd[p],
                 lose_beta_prior_sd=priors$lose_beta_prior_sd[p])
  
  # Generate df for sensitivity plots
  if (exists('sensitivity_df')){sensitivity_df <- rbind(sensitivity_df, temp)} else {sensitivity_df <- temp}
}

#write_csv(sensitivity_df, 'sensitivity_df.csv')


############################
#### PRECISION ANALYSIS ####
############################

# Read data
raw_data  <- read.csv("simulation_rates_trials.csv")

# Define different priors
# We use a prior distribution centered at 0 with a sd of 1 for the alpha (noise). 
# For both beta estimates (win/lose), we use prior distributions with a mean and sd of .5 (i.e. chance) 
alpha_prior_mean <- c(0) 
win_beta_prior_mean <- c(.5)
lose_beta_prior_mean <- c(.5)

alpha_prior_sd <- c(1) 
win_beta_prior_sd <- c(.5) 
lose_beta_prior_sd <- c(.5) 

# Generate all possible combinations of prior-parameters
priors <-  expand.grid(alpha_prior_mean, win_beta_prior_mean, lose_beta_prior_mean,
                       alpha_prior_sd, win_beta_prior_sd, lose_beta_prior_sd)

# Convert table to tibble
priors <-  tibble(alpha_prior_mean=priors$Var1, win_beta_prior_mean=priors$Var2, lose_beta_prior_mean=priors$Var3,
                  alpha_prior_sd=priors$Var4, win_beta_prior_sd=priors$Var5, lose_beta_prior_sd=priors$Var6)

# Load STAN model
file <- file.path("assignment2.stan")
mod <-  cmdstanr::cmdstan_model(file, cpp_options = list(stan_threads = TRUE))


for (temp_rate in unique(raw_data$rate)){
  for (temp_ntrials in unique(raw_data$ntrials)){
    
    # Lag the two columns, use 0 as default
    data <- raw_data %>% 
      subset(rate == temp_rate) %>% 
      subset(ntrials == temp_ntrials) %>% 
      mutate(win_bias_lag = dplyr::lag(Win_bias, default = 0),
             lose_bias_lag = dplyr::lag(Lose_bias, default = 0))
    
    # Looping through priors
    for (p in seq(nrow(priors))){
    
      # Specify data
      d <- list(
        n = nrow(data), 
        h = data$agent_choices, 
        # win_bias = data$Win_bias, 
        # lose_bias = data$Lose_bias,
        win_bias = data$win_bias_lag, 
        lose_bias = data$lose_bias_lag,
        alpha_prior_mean=priors$alpha_prior_mean[p],
        win_beta_prior_mean=priors$win_beta_prior_mean[p],
        lose_beta_prior_mean=priors$lose_beta_prior_mean[p],
        alpha_prior_sd=priors$alpha_prior_sd[p],
        win_beta_prior_sd=priors$win_beta_prior_sd[p],
        lose_beta_prior_sd=priors$lose_beta_prior_sd[p])
      
      # Fit STAN model
      samples <- mod$sample(
        data = d,
        seed = 123,
        chains = 2,
        parallel_chains = 2,
        threads_per_chain = 2,
        iter_warmup = 1000,
        iter_sampling = 1000,
        refresh = 500,
        max_treedepth = 20,
        adapt_delta = 0.99)
      
      # Get model summary
      model_sum <- samples$summary()
      
      # Return model defined priors and posteriors
      draws_df <- as_draws_df(samples$draws())
      temp <- tibble(alpha = draws_df$alpha,
                     win_beta = draws_df$win_beta,
                     lose_beta = draws_df$lose_beta,
                     alpha_sd = model_sum[2,4],
                     win_beta_sd = model_sum[3,4],
                     lose_beta_sd = model_sum[4,4],
                     alpha_prior = draws_df$alpha_prior,
                     win_beta_prior = draws_df$win_beta_prior,
                     lose_beta_prior = draws_df$lose_beta_prior,
                     alpha_prior_mean=priors$alpha_prior_mean[p],
                     win_beta_prior_mean=priors$win_beta_prior_mean[p],
                     lose_beta_prior_mean=priors$lose_beta_prior_mean[p],
                     alpha_prior_sd=priors$alpha_prior_sd[p],
                     win_beta_prior_sd=priors$win_beta_prior_sd[p],
                     lose_beta_prior_sd=priors$lose_beta_prior_sd[p],
                     rate = temp_rate,
                     ntrials = temp_ntrials)
      
      # Generate df for sensitivity plots
      if (exists('precision_df')){precision_df <- rbind(precision_df, temp)} else {precision_df <- temp}
    
    }
  }
}

#write_csv(precision_df, 'precision_df.csv')



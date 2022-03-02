 library(pacman)
pacman::p_load(tidyverse, here, posterior, cmdstanr, brms)


# Read data
data  <- read_csv("Desktop/Cognitive_Science/Cognitive Science 8th Semester/Advanced Cognitive Modeling/Week 3 - Stan/game_data.csv")


# Function for converting log odds to probability
logit2prob <- function(logit){
  odds <- exp(logit)
  prob <- odds / (1 + odds)
  return(prob)
}


# Define different priors
alpha_prior_mean <- c(0, .5)
beta_prior_mean <- c(0, .5)
beta2_prior_mean <- c(0, .5)

alpha_prior_sd <- c(1, 2)
beta_prior_sd <- c(.5, 1)
beta2_prior_sd <- c(.5, 1)

priors <-  expand.grid(alpha_prior_mean, beta_prior_mean, beta2_prior_mean,
                    alpha_prior_sd, beta_prior_sd, beta2_prior_sd)

priors <-  tibble(alpha_prior_mean=priors$Var1, beta_prior_mean=priors$Var2, beta2_prior_mean=priors$Var3,
               alpha_prior_sd=priors$Var4, beta_prior_sd=priors$Var5, beta2_prior_sd=priors$Var6)

# Loading model
file <- file.path("Desktop/Cognitive_Science/Cognitive Science 8th Semester/Advanced Cognitive Modeling/Week 3 - Stan/assignment2.stan")
mod <-  cmdstan_model(file, cpp_options = list(stan_threads = TRUE))

# Looping throgh priors
for (p in seq(nrow(priors))){
  
  d <- list(
    n = nrow(data),
    h = data$agent_choices,
    stay_bias = data$Staybias,
    leave_bias = data$Leavebias,
    alpha_prior_mean=priors$alpha_prior_mean[p],
    beta_prior_mean=priors$beta_prior_mean[p],
    beta2_prior_mean=priors$beta2_prior_mean[p],
    alpha_prior_sd=priors$alpha_prior_sd[p],
    beta_prior_sd=priors$beta_prior_sd[p],
    beta2_prior_sd=priors$beta2_prior_sd[p])
  
  samples <- mod$sample(
    data = d,
    seed = 123,
    chains = 1,
    parallel_chains = 1,
    threads_per_chain = 1,
    iter_warmup = 1000,
    iter_sampling = 2000,
    refresh = 500,
    max_treedepth = 20,
    adapt_delta = 0.99)
    
  draws_df <- as_draws_df(samples$draws())
  temp <- tibble(alpha = draws_df$alpha,
                 beta = draws_df$beta,
                 beta2 = draws_df$beta2,
                 alpha_prior_mean=priors$alpha_prior_mean[p],
                 beta_prior_mean=priors$beta_prior_mean[p],
                 beta2_prior_mean=priors$beta2_prior_mean[p],
                 alpha_prior_sd=priors$alpha_prior_sd[p],
                 beta_prior_sd=priors$beta_prior_sd[p],
                 beta2_prior_sd=priors$beta2_prior_sd[p])
  
  if (exists('sensitivity_df')){sensitivity_df <- rbind(sensitivity_df, temp)} else {sensitivity_df <- temp}
}

samples$summary()


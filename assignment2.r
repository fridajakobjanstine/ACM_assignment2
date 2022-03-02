 library(pacman)
pacman::p_load(tidyverse, here, posterior, cmdstanr, brms, sigmoid)


# Read data
d  <- read_csv("Desktop/Cognitive_Science/Cognitive Science 8th Semester/Advanced Cognitive Modeling/Week 3 - Stan/game_data_rate_loops.csv")

data <- d %>% subset(rate == 0.7)

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
    heads_bias = data$Staybias,
    tails_bias = data$Leavebias,
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
                 alpha_sd = samples$summary()[2,4],
                 beta_sd = samples$summary()[3,4],
                 beta2_sd = samples$summary()[4,4],
                 alpha_prior = draws_df$alpha_prior,
                 beta_prior = draws_df$beta_prior,
                 beta2_prior = draws_df$beta2_prior,
                 alpha_prior_mean=priors$alpha_prior_mean[p],
                 beta_prior_mean=priors$beta_prior_mean[p],
                 beta2_prior_mean=priors$beta2_prior_mean[p],
                 alpha_prior_sd=priors$alpha_prior_sd[p],
                 beta_prior_sd=priors$beta_prior_sd[p],
                 beta2_prior_sd=priors$beta2_prior_sd[p])
  
  if (exists('sensitivity_df')){sensitivity_df <- rbind(sensitivity_df, temp)} else {sensitivity_df <- temp}
}

samples$summary()

# Plotting sensitivity for alpha
sensitivity_df %>% ggplot(aes(as.factor(alpha_prior_mean), alpha))+
  geom_point(size=3, alpha=0.05)+
  facet_wrap(~alpha_prior_sd)+
  theme_classic()

# Plotting sensitivity for alpha
sensitivity_df %>% ggplot(aes(as.factor(beta_prior_mean), beta))+
  geom_point(size=3, alpha=0.05)+
  facet_wrap(~beta_prior_sd)+
  theme_classic()

# Plotting sensitivity for alpha
sensitivity_df %>% ggplot(aes(as.factor(beta2_prior_mean), beta2))+
  geom_point(size=3, alpha=0.05)+
  facet_wrap(~beta2_prior_sd)+
  theme_classic()


sensitivity_df %>% subset(alpha_prior_mean==0 & alpha_prior_sd==1 &
                          beta_prior_mean==0 & beta_prior_sd==.5 &
                          beta2_prior_mean==0 & beta2_prior_sd==.5) %>% 
  ggplot() +
  geom_density(aes(beta, fill="blue", alpha=0.3) +
  geom_density(aes(beta_prior), fill="red", alpha=0.3) +
  xlab("Rate") +
  ylab("Posterior Density") +
  theme_classic()

  
theta_test <- samples$summary()[2,2] + samples$summary()[3,2] * (-1)
sigmoid(1)

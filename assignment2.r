# Load packages
library(pacman)
pacman::p_load(tidyverse, here, posterior, cmdstanr, brms, sigmoid)

# Defining function for converting log odds to probability
logit2prob <- function(logit){
  odds <- exp(logit)
  prob <- odds / (1 + odds)
  return(prob)
}

# Read data
d  <- read_csv("Desktop/Cognitive_Science/Cognitive Science 8th Semester/Advanced Cognitive Modeling/Week 3 - Stan/feedback_agent_10000_trials.csv")

# Subset to 1 rate
data <- d %>% subset(rate == 0.7)


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
priors <-  expand.grid(alpha_prior_mean, win_beta_prior_mean, loose_beta_prior_mean,
                    alpha_prior_sd, win_beta_prior_sd, loose_beta_prior_sd)

# Convert table to tibble
priors <-  tibble(alpha_prior_mean=priors$Var1, win_beta_prior_mean=priors$Var2, loose_beta_prior_mean=priors$Var3,
               alpha_prior_sd=priors$Var4, win_beta_prior_sd=priors$Var5, loose_beta_prior_sd=priors$Var6)

# Load STAN model
file <- file.path("Desktop/Cognitive_Science/Cognitive Science 8th Semester/Advanced Cognitive Modeling/Week 3 - Stan/assignment2.stan")
mod <-  cmdstan_model(file, cpp_options = list(stan_threads = TRUE))

# Looping through priors
for (p in seq(nrow(priors))){
  
  # Specify data
  d <- list(
    n = nrow(data), 
    h = data$agent_choices, 
    win_bias = data$Win_bias, 
    loose_bias = data$Lose_bias,
    alpha_prior_mean=priors$alpha_prior_mean[p],
    win_beta_prior_mean=priors$win_beta_prior_mean[p],
    loose_beta_prior_mean=priors$loose_beta_prior_mean[p],
    alpha_prior_sd=priors$alpha_prior_sd[p],
    win_beta_prior_sd=priors$win_beta_prior_sd[p],
    loose_beta_prior_sd=priors$loose_beta_prior_sd[p])
  
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
                 loose_beta = draws_df$loose_beta,
                 alpha_sd = model_sum[2,4],
                 win_beta_sd = model_sum[3,4],
                 loose_beta_sd = model_sum[4,4],
                 alpha_prior = draws_df$alpha_prior,
                 win_beta_prior = draws_df$win_beta_prior,
                 loose_beta_prior = draws_df$loose_beta_prior,
                 alpha_prior_mean=priors$alpha_prior_mean[p],
                 win_beta_prior_mean=priors$win_beta_prior_mean[p],
                 loose_beta_prior_mean=priors$loose_beta_prior_mean[p],
                 alpha_prior_sd=priors$alpha_prior_sd[p],
                 win_beta_prior_sd=priors$win_beta_prior_sd[p],
                 loose_beta_prior_sd=priors$loose_beta_prior_sd[p])
  
  # Generate df for sensitivity plots
  if (exists('sensitivity_df')){sensitivity_df <- rbind(sensitivity_df, temp)} else {sensitivity_df <- temp}
}

write_csv(sensitivity_df, 'sensitivity_df.csv')
 
# Inspect summary
model_sum

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



# Assignment 2
_Jakob, Stine, Jan, Frida_ 

Code for assignment 2 in Advanced Cognitive Modeling, MSc Cognitive Science, Aarhus University.

------------
For this assignment, we are exploring the modeling of a strategy for playing the Matching Pennies Game. 

## Modeling

__Strategy__:  
We have used FeedbackAgent defined in [assignment 1](https://github.com/CognitiveScienceAU/assignment1_fromverbal2formal-fridajakobjanstine) where the formalization (i.e. code) of the agent can also be found. 
This agent assumes that the opponent is a "human agent" who follows the standard human behavior of switching too often. It assumes that the bias for switching is 70%. As it plays as the matcher, its strategy is therefore that when it wins, 
it assumes that the opponent will be more likely to switch, and is therefore more likely to switch itself. Likewise, when it loses, it assumes the opponent is more likely to switch and is self more likely to stay. The strategy can be thought of as "win 70% switch, lose 70% stay". The assumed bias of switching 70% of the time was arbitrarily chosen. It plays against a completely random agent, and its strategy is therefore not likely to be successful.

__Bayesian model__:  
The data we are using are simulated from these assumptions. We simulate a game between the FeedbackAgent described above, and a completely random agent. They play for 1000 rounds. We then make two new columns, win_bias and lose_bias, respectively. win_bias has the value 1 (heads) if the Feedback Agent AND the random agent chose 0 (tails) in the present round, -1 if both agents chose 1 (heads) in the present round, and otherwise 0. This means that this column indicates pushing towards shifting when the two agents chose the same (meaning that Feedback Agent as the Matcher won). Likewise, lose_bias has value 1 when Feedback Agent chose 1 (heads) and random agent chose 0 (meaning that Feedback agent lost), -1 when Feedback agent chose 0 (tail) and random agents chose 1, and otherwise 0. 
We then algged those two columns, so that one row of the data contain information of the bias given the previous round and the choice given this bias. 

(needs rewriting)  
The data as described above was used to model the following: 

choice ~ alpha + win_beta * win_bias + lose_beta * lose_bias

Here, _choice_ is the choice of the Feedback agent at the present round, akpha is a parameter modelling systematic noise, win_beta is the to-be estimated parameter for the win_bias, and lose_beta is the to-be estimated parameter for the lose_bias. Note, that due to the way the two columns were created, either one or the other will always be zero. If Feedback Agent won the previous round, then lose_bias is zero (because the agent didn't lose) and vice versa. 

## Priors and true values

Parameters to estimate:
- alpha: noise (since we added no noise in the model, we expect it to be close to zero)
- win_beta: true value is 0.7
- lose_beta: true value is 0.7

All parameters were modelled with normally distributed priors. We used three different priors for the means to perform some prior robustness checks. 

Prior means:
- alpha: -0.5, 0, 0.5. 0 is the main prior, the other two are robustness checks
- win_beta: 0, 0.5, 1. 0.5 is the main prior (which is equal to chance), the other two are robustness checks
- lose_beta: 0, 0.5, 1. 0.5 is the main prior (which is equal to chance), the other two are robustness checks

Prior sd:
- alpha: sd = 1 (large standard deviation to not constrain the estimate of the noise, even though we expect it to be low)
- betas: sd = 0.5 (smaller standard deviation to keep estimates of biases in a reasonable range)

## Parameter recovery 
When building our model, we use simulations to perform parameter recovery. By simulating data from known parameters we know the “truth”. By applying our model to simulated data, we can run checks on the model to see how well it recovers (i.e. how accurate our estimates are) for different simulations. This could e.g. show us that we need a more simple model or more data. In this way, the process of parameter recovery will hopefully make it less likely that we draw invalid conclusions with our model. Parameter recovery is important for validating the inferences you make in a cognitive modeling analysis. It helps you understand whether your analysis can tell you anything about what is actually going on.

## Discussing results
...plots

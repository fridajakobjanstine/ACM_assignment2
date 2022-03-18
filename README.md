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
(needs rewriting)  
... blabla  bayesian model

Parameters to estimate:
- alpha: noise
- win_beta: want it to be 0.7
- lose_beta: want it to be 0.7

For alpha, we use a normally distributed prior centered around 0 with a standard deviation of 1. For the betas, we use normally distributed priors with a mean of 0.5 (chance) and a standard deviation of 0.5. 

## Parameter recovery 
When building our model, we use simulations to perform parameter recovery. By simulating data from known parameters we know the “truth”. By applying our model to simulated data, we can run checks on the model to see how well it recovers (i.e. how accurate our estimates are) for different simulations. This could e.g. show us that we need a more simple model or more data. In this way, the process of parameter recovery will hopefully make it less likely that we draw invalid conclusions with our model. Parameter recovery is important for validating the inferences you make in a cognitive modeling analysis. It helps you understand whether your analysis can tell you anything about what is actually going on.

## Discussing results
...plots

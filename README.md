# Assignment 2
_Jakob, Stine, Jan, Frida_ 

Code for assignment 1 in Advanced Cognitive Modeling, MSc Cognitive Science, Aarhus University.

------------

For the assignment, we have defined different strategies for playing the Matching Pennies Game. Below, we have described the different strategies and a formalization of each (i.e. code) can be found in the _agents.py_ file. The analysis can be found in the _matching\_pennies.ipynb_ file. 


__FeedbackAgent__:  
This agent assumes that the opponent is a "human agent" who follows the standard human behavior of switching too often. 
It assumes that the bias for switching is 70%. 
As it plays as the matcher, its strategy is therefore that when it wins, 
it assumes that the opponent will be more likely to switch, and is therefore more likely to switch itself. 
Likewise, when it loses, it assumes the opponent is more likely to switch and is self more likely to stay. 
The strategy can be thought of as "win 70% switch, lose 70% stay". 
The assumed bias of switching 70% of the time was arbitrarily chosen. 
It plays a completely random agent, and its strategy is therefore not likely to be successful. 

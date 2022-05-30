# SOAS Project - Cristian Camargo, Felix Schreyer

The goal of this project is to implement a netlogo model able to simulate the behavior of normative agents as they play the multi-round **Ultimatum Game** (UG), based on the proposed design by the paper *"The Value of Values and Norms in Social Simulation"* by Mercuur et al.


## THE SCENARIO


In the UG, two players negotiate over a fixed amount of money ("the pie"). Player 1 (the proposer) demands a portion of the pie, with the remainder offered to Player 2 (the responder). The latter can then choose to accept or reject this proposed split. If the responder chooses to **accept**, the money is split between both players according to the proposer's demand. If the responder chooses to **reject**, both players get no money. 

This particular implementation deals with the multi-round UG scenario, where our interest lies in evaluating if the same behaviour humans display over multiple game rounds can be reproduced by a normative agent model.


## HOW TO USE

To run the experiment, simply click the "Setup" button once which will initialize the model and then follow by clicking on the "Go" button, which will proceed to play the game for the chosen amount of rounds

There are several parameters that influence the simulation, where the default values provided correspond to the same ones used by the authors of the paper. Thus, if the goal is to reproduce the paper's exact results the parameters should be left as is.

The following settings influence the global rules of the game:

* **num-players**: determines the number of agents that will play the game, half will be split into proposers and the rest into responders.
* **num-rounds**: maximum number of rounds that the game will run for.
* **pie-size**: size of the money pot that will be split across two players playing the UG.

On the other hand, the rest of the settings control the starting behavior of the agents (i.e. when no norms have been established yet):

* **initial-demand-mean**: mean value for the proposer's demands, which will be used in order to draw a normal distribution.
* **initial-demand-sd**: standard deviation for the amount demanded by the proposer.
* **initial-accept-mean**: mean value for the responder's accept rate, which will be used in order to draw a normal distribution.
* **initial-accept-sd**: standard deviation for the responder's accept rate.


## HOW IT WORKS

Initially, players are split into two groups: proposers (red) and responders (blue). They are then arranged in a circle formation so that each proposer is paired with a responder. Once the game starts, the proposer states his demand to their paired responder (via a link) and the responder then chooses his answer for the proposal. 
If the responder accepts, he will show a message saying "yes" and both parties will be colored green to indicate that the deal went through. If he disagrees however, a message of "no" will be shown instead and their interaction will end here.

During the first round, since no norms have been established for both the proposers and responders, they will decide their actions based on a normal distribution using the provided parameters from the model's configuration. This is meant to simulate that the agents will initially display human behavior, an important assumption made by the authors of the paper, and then study where they go from there.

In each subsequent round, responders will start to base their decision threshold on the average value of the demands they've seen thus far. As such, if the value of the next demand is higher than the average of previous demands, they will reject the offer and cancel the deal.

Proposers on the other hand will adjust their demands based on the average of two indicators: the lowest demand that has been rejected and the highest demand that has been accepted. If one of the indicators is missing (e.g. no demands have been accepted yet) then the agent will continue to draw a value from a normal distribution just like in the first round.

After both players are done communicating their decisions, the mean values for the demand/acceptance rate for that round will be displayed across the two accompanying graphs. The results will also be output to a local text file "log.txt" that can be found in the same folder as the model file.

Finally, the players will be randomly paired once again (without switching roles) and the game will start anew, up until the maximum number of rounds.

globals
[
  sum-wealth
]

turtles-own [
  endowment ;;amount of money to play
  proposer ;;boolean, 1 if the player aquired the role of proposer for the turn
  responder ;;boolean, 1 if the player aquired the role of responder for the turn
  prop-take-rate ;;the take-rate the the player will propose to the responder if it has the proposer role for the turn
  resp-take-rate ;;tha tak-e rate that the player will accept from a proposer if it has the responder role for the turn
]
links-own [
  take-amount ;;amount fo the transaction
  trn-prop-take-rate ;;proposed take of the transaction
]

breed [players player]


;;;
;;; SETUP PROCEDURES
;;;

to setup
  clear-all
  reset-ticks
  setup-players
end

;;Create players, set initial endowments and take rates
to setup-players
  create-players 32
  ask players [
    ;;setup initial endowment
    (ifelse  initial-endowment-distribution = "Exp" [
      set endowment random-exponential 10
    ] initial-endowment-distribution = "Normal" [
      set endowment random-normal 10 1
    ] initial-endowment-distribution = "Equal" [
      set endowment 10
    ])

    set shape "person"
    set color grey
    setxy random-pxcor random-pycor
    set prop-take-rate random-normal prop-mean-take-rate prop-sd-take-rate;; draw take rates when player is proposer from a normal distribution
    set resp-take-rate random-normal resp-mean-take-rate resp-sd-take-rate;; draw take rates when player is responder from a normal distribution
  ]
end


;;;
;;; GO PROCEDURES
;;;


to go
  setup-turn
  setup-proposals
  prop-propose
  resp-decide
  ask players [set endowment endowment * (1 + interest-rate)] ;;earn interest
  ask players [set endowment (endowment + turn-endowment)] ;;wellfare endowment
  if count links < 1 [stop]
  if ticks > 100 [stop]
  tick
end


;;Each turn these players are randomly assigned to the role of responder (red) and proposer (blue)
;;and responders and proposers are paired with each other in cricle, also randomly.
to setup-turn
  clear-links
  reset-players
  setup-responders
  setup-proposers
  layout-circle players with [responder = 1] (world-width / 2.13)
  layout-circle players with [proposer = 1] (world-width / 2.3)
  ask players with [endowment < cost-to-play] [ set color grey]
end

to reset-players
  ask players [
    setxy random-pxcor random-pycor
    set proposer 0
    set responder 0
    set color grey
    set label ""
  ]

end

to setup-responders
  ask n-of 30 players[
    set color red
    set responder 1
   ]
end

to setup-proposers
  ask players with [responder != 1]  [
    set proposer 1
    set color blue
  ]
end

to setup-proposals
  ask players with [responder = 1 and endowment > 0] [ ;;only link if you have money to play
    let potential-partner turtles-on  neighbors
    let actual-partner potential-partner with [ endowment >= cost-to-play] ;;only link if the proposer can afford the cost to play
    create-links-with actual-partner
  ]
end

to prop-propose
 ask players with [proposer = 1]  [
    let temp prop-take-rate
    ask my-out-links[
      set trn-prop-take-rate temp
    ]
 ]
 ask players with [responder = 1]  [
    let temp2 endowment
    ask my-out-links[
      set take-amount (temp2 * trn-prop-take-rate)
    ]
 ]
end

to resp-decide
ask players with [responder = 1 and count link-neighbors with [proposer = 1] > 0] [
      let temp3 0
      ask my-out-links [
        set temp3 trn-prop-take-rate
      ]
      ifelse  temp3  > resp-take-rate [   ;;destroy the endowment
        set endowment 0
        set label "x"
      ]
      [
        set label "deal!" ;;accept the take
      ]
]

ask players with [label = "deal!" and responder = 1] [ ;; transactions for the agreed take
    let temp4 0
    set color green
    ask my-out-links [ ;; retrieve the amout the take-amount of the transaction
      set temp4 take-amount
    ]
      set endowment endowment - temp4 ;; deduce the take-amount from the responders endowment
    ask link-neighbors [
      set endowment endowment + temp4 ;; deposit the take-amount in the proposers endowment
      ;; increase the proposers take rate for next time
      ifelse (prop-take-rate * (1 + prop-greed-weight)) <= 1 [
        set prop-take-rate (prop-take-rate * (1 + prop-greed-weight))
      ][
        set prop-take-rate 1
      ]
       set color green
    ]
]

ask players with [label = "x" and responder = 1] [ ;; associated proposers take shame and reduce take-ratio
    ask my-out-links [set color red]
    ask link-neighbors [
      set prop-take-rate (prop-take-rate * (1 - prop-shame-weight)) ;; reduce the proposers take rate for next time
    ]
]
end


;2020- Mariano Crimi
@#$#@#$#@
GRAPHICS-WINDOW
211
10
644
444
-1
-1
12.9
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
turns
30.0

BUTTON
360
454
424
487
setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
429
454
492
487
NIL
go\n
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

SLIDER
0
419
189
452
resp-mean-take-rate
resp-mean-take-rate
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
1
230
185
263
prop-mean-take-rate
prop-mean-take-rate
0
1
0.8
0.01
1
NIL
HORIZONTAL

SLIDER
1
269
185
302
prop-sd-take-rate
prop-sd-take-rate
0
0.1
0.07
0.01
1
NIL
HORIZONTAL

SLIDER
1
307
185
340
prop-shame-weight
prop-shame-weight
0
1
0.6
0.05
1
NIL
HORIZONTAL

PLOT
664
11
1106
175
Total wealth
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [endowment] of turtles"

PLOT
663
182
1110
302
Wealth distribution
$
players
0.0
500.0
0.0
60.0
false
false
"" ""
PENS
"pen-0" 10.0 1 -7500403 true "" "plot-pen-reset\nhistogram [endowment] of players"

SLIDER
0
347
186
380
prop-greed-weight
prop-greed-weight
0
1
0.05
0.05
1
NIL
HORIZONTAL

SLIDER
0
456
187
489
resp-sd-take-rate
resp-sd-take-rate
0
0.1
0.02
0.01
1
NIL
HORIZONTAL

PLOT
665
310
1110
453
# of players who can't play
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles with [endowment < cost-to-play]"

SLIDER
0
82
187
115
interest-rate
interest-rate
0
1
0.05
0.05
1
NIL
HORIZONTAL

TEXTBOX
4
395
154
413
Responders
14
14.0
1

TEXTBOX
4
204
154
222
Proposers
14
95.0
1

TEXTBOX
7
10
157
28
World settings
14
0.0
1

CHOOSER
0
34
187
79
initial-endowment-distribution
initial-endowment-distribution
"Exp" "Normal" "Equal"
1

SLIDER
0
158
190
191
cost-to-play
cost-to-play
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
0
119
189
152
turn-endowment
turn-endowment
0
100
0.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This is a an excercise model that attempts to describe the emergence of cumulative wealth and the distribution of such wealth in an iterative ultimatum game, considering the prosocial emotion of "shame" and profit-maximing "greed",

This  model is inspared by the work of Reuben et al in trying to understand the role of emotions after punishment (in particular shame/guilt) in the take rates of proposers:

https://www.sciencedirect.com/science/article/abs/pii/S0167487010000887?via%3Dihub


## ULTIMATUM GAMES

One player, the proposer, is endowed with a sum of money. The proposer is tasked with splitting it with another player, the responder. Once the proposer communicates their decision, the responder may accept it or reject it. If the responder accepts, the money is split per the proposal; if the responder rejects, both players receive nothing


Ultimatum games: https://en.wikipedia.org/wiki/Ultimatum_game

## HOW IT WORKS
60 players are created and endowed with an initial amount of money - 10 euros. This initial endowment can be taken from a distribution (exponential or normal) or be equal for all the participants. This is controlled by the **initial-endowment-distribution** selector.

Players are also assigned with a take-rate in the case they are proposers (**prop-take-rate**) and one for when they take the roles of responders (**resp-take-rate**). The proposer take rate will determine the offer of the proposer while the responder take rate will determine the amount that the responder agrees to from the proposer to take.

To cater for variabilities in fairness perceptions in the different players the take rates are taken from a normal distribution with mean **mean-take-rate** and **sd-take-rate** both for the responder and proposer rates.

Each turn these players are randomly assigned to the role of responder (red) and proposer (blue) and responders and proposers are paired with each other, also randomly.

If the responder has an endowment and the proposers endowment is more than the **cost-to-play** then a link is established between the two and a proposal is made by the proposer to take an amount of the endowment of the responder according to the **prop-take-rate** of the proposer. 

If the proposed take rate is lower or equal to the what the responder considers fair (**resp-take-rate**) there is a "deal" and the proposed proportion of the responders endowment will pass to the proposer and be deducted from the responders.

If the proposed take rate is larger than the one that the responder considers fair (**resp-take-rate**) there is no deal, and the proposer will set his/her endowment to 0 effectively destroying their wealth.

Those proposers who got they proposal rejected will reduce the prop-take-rate by a percentage corresponding to the **prop-shame-weight** for next time.

Those proposers who got they proposal accepted will increase the prop-take-rate by a percentage corresponding to the **prop-greed-weight** for next time.

For the next turn every player's endowment will be increased by a fixed amount defined by the **turn-endowment** global variable simulating a wellfare endowment. 

Additionally, the current endowment of the players (not considering the wellfare endowment) will be increased by 1+**interest-rate** each turn

The game will end after 100 turns. If no proposals can be made (no proposers can afford the cost-to-play and/or responders have 0 endowment left) the game will end.

## THINGS TO NOTICE

- Which starting point of take rates (both responder and proposer) and combination of adjusting behavior (greed/shame) will be the best agent for a given agent to maximize long term profit.
- Cummulative weatlh - what is the best settings and players strategy to reach the best cumulative wealth?
- Wealth distribution - what is the best settings and players  strategy to achieve the fairest wealth distribution?
- Players out of the game - the amount of players that can no longer play because they can't affor the cost-to-play.
- How many turns does the game last?


## THINGS TO TRY

- Try cost to play = 0 (everyone can propose)
- Explore the relationship between turn-endowment and cost-to-play
- Comapre fixed endowment with interest rate on current endowment and how that affects the wealth distribution

## EXTENDING THE MODEL

- Compare this model with one where the players stick to they roles (once a proposer/responder always a proposer/responder)
- Wellfare endowment could be a proportion of the amount taken from the responders in succesfull operations in each turn. This would simulate an authority redistributing wealth.
- Eplore different distributions in the resp-take-rates and prop-take-rate
- Include and adjusting behavior on the resp-take-rate for the responder after destroying the endowment.
- This model only considers take-rates for the responder decison to wether destroy the endowment or not. It is clear that the abolute value of the take should also be considered.
- Greed and shame weights are assumed to be equal for all participants. These could be drawn from a distribution to add some more randomness to the model.
- This models response in binary terms (destroy all vs accept) . This model could be extended to consider partial endowment destroy.


## RELATED MODELS

Wealth distribution

## CREDITS AND REFERENCES

Author: Mariano Crimi

https://www.sciencedirect.com/science/article/abs/pii/S0167487010000887?via%3Dihub
https://www.nature.com/articles/s41598-017-05122-5
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

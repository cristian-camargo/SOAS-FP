globals
[
  ;num-players
  ;num-rounds
  ;pie-size
  ;initial-demand
  ;initial-accept
]

turtles-own [
  demand-rate ;; portion of the pie to demand
  accept-rate ;; min. portion to accept an offer 
  is-proposer? ;; true if the player has the role of proposer
]

links-own [
  prop-demand ;; amount demanded by the proposer
  resp-accept ;; equals 1 if the responder accepts the offer
]

breed [players player]

;; Reset the simulation
to setup
  random-seed 117
  clear-all
  reset-ticks
  setup-agents
end

;; Create and setup the player agents
to setup-agents
  create-players num-players
  init-players
  init-roles
  match-players
end

;; Initialize the agents' state
to init-players
  ask players [
    set label ""
    set shape "person"
    set color grey
    set is-proposer? false
    set demand-rate random-normal initial-demand 0.2
    set accept-rate random-normal initial-accept 0.2
    setxy random-pxcor random-pycor
  ]
end

;; Agents are randomly marked as responders or proposers
to init-roles
  ask n-of (num-players / 2) players [
    set is-proposer? true
    set color red
  ]
  ask players with [not is-proposer?]  [
    set color blue
  ]
end

;; Run the simulation
to go
  reset-players
  match-players
  send-offer
  send-response
  if ticks > num-rounds [stop]
  tick
end

to reset-players
  ask players [
    set label ""
  ]
  ask players with [is-proposer?]  [
    set color red
  ]
  ask players with [not is-proposer?]  [
    set color blue
  ]
end

;; Proposer agents are paired with Responder agents
to match-players
  clear-links
  layout-circle players with [is-proposer?] (world-width / 3.0)
  layout-circle players with [not is-proposer?] (world-width / 2.7)
  
  ask players with [is-proposer?] [
    let partner turtles-on neighbors
    create-links-with partner
  ]
end

;; Send an offer to another agent
to send-offer
  ask players with [is-proposer?]  [
    set demand-rate random-normal initial-demand 0.2
    let rate demand-rate
    ask my-out-links [
      set prop-demand (pie-size * rate)
    ]
 ]
end

;; Respond to another agent's offer
to send-response
  ask players with [not is-proposer? and (count link-neighbors with [is-proposer?] > 0)] [
    set accept-rate random-normal initial-accept 0.2
    let reward 0
    let threshold (pie-size * accept-rate)

    ask my-out-links [
      set reward (pie-size - prop-demand)
    ]

    ifelse reward < threshold [   
      set label "no" ;; refuse the offer
    ][
      set label "yes" ;; accept the offer
      ask my-out-links [
        set resp-accept 1
      ]
    ]
  ]

  ask players with [label = "yes"] [
      set color green
      ask link-neighbors [
        set color green
      ]
  ]

end
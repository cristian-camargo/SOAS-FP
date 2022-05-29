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
  offer-amount ;; amount for the transaction
  accept-offer ;; 1 if the responder accepts the offer
]

breed [players player]

;; Reset the simulation
to setup
  random-seed 117
  clear-all
  reset-ticks
  init-players
end

;; Initialize the player agents
to init-players
  create-players num-players
  reset-players
  init-roles
end

;; Reset the agents' state
to reset-players
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

;; Run the simulation
to go
  init-roles
  match-players
  send-offer
  send-response
  if ticks > num-rounds [stop]
  tick
end

;; Agents are randomly marked as responders or proposers and then paired with each other
to init-roles
  clear-links
  reset-players
  ask n-of (num-players / 2) players [
    set color red
    set is-proposer? true
  ]
  ask players with [not is-proposer?]  [
    set color blue
  ]
  layout-circle players with [is-proposer?] (world-width / 2.3)
  layout-circle players with [not is-proposer?] (world-width / 2.13)
end

;; Pair proposers with responders
to match-players
  ask players with [is-proposer?] [
    let partner turtles-on neighbors
    create-links-with partner
  ]
end

;; Send an offer to another agent
to send-offer
  ask players with [is-proposer?]  [
    let rate demand-rate
    ask my-out-links[
      set offer-amount (pie-size * rate)
    ]
 ]
end

;; Respond to another agent's offer
to send-response
  ask players with [not is-proposer? and count link-neighbors with [is-proposer?] > 0] [
    let amount 0
    ask my-out-links [
      set amount (pie-size - offer-amount)
    ]
    ifelse amount < (pie-size * accept-rate) [   
      set label "no" ;; refuse the offer
    ]
    [
      set label "yes" ;; accept the offer
      ask my-out-links [
        set accept-offer 1
      ]
    ]
  ]

  ask players with [label = "yes" and not is-proposer?] [
      set color green
      ask link-neighbors [
        set color green
      ]
  ]

end
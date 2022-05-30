globals
[
  current-sim
  current-round
  filename
]

turtles-own [
  is-proposer? ;; true if the player has the role of proposer
  min-rejected ;; lowest demand that was rejected
  max-accepted ;; highest demand that was accepted
  seen-demands ;; list of demands seen in previous rounds
]

links-own [
  prop-demand ;; amount demanded by the proposer
  resp-accept ;; equals 1 if the responder accepts the offer
]

breed [players player]

;; Reset the simulation
to setup
  let sim current-sim
  clear-all
  reset-ticks
  setup-agents
  ;random-seed 117

  set current-sim (sim + 1)
  set current-round 1
  file-open "log.csv"
  if (current-sim = 1) [
      file-type "Test,Round,Demand,Accept"
      file-print ""
  ]
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
    set min-rejected 0
    set max-accepted 0
    set seen-demands []
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
  update-norms
  write-log
  set current-round (current-round + 1)
  if current-round > num-rounds [
    file-close 
    stop 
  ]
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

;; Send an offer to another agent according to the norm
;; The norm is the average of the lowest demand that is rejected and the highest demand that is accepted
to send-offer
  ask players with [is-proposer?]  [
    let demand 0

    ifelse (min-rejected = 0) or (max-accepted = 0) [
      set demand random-normal initial-demand-mean initial-demand-sd ;; draw from a random distribution
    ][
      let norm (min-rejected + max-accepted) / 2
      set demand norm ;; propose according to the norm
    ]

    ask my-out-links [
      set prop-demand demand
    ]
 ]
end

;; Respond to another agent's offer according to the norm
;; The norm is the average over all previously seen demands
to send-response
  ask players with [not is-proposer? and (count link-neighbors with [is-proposer?] > 0)] [
    let demand 0
    let accept false

    ask my-out-links [
      set demand prop-demand ;; get amount demanded by the proposer
    ]

    ifelse length seen-demands > 0 [
      let norm (mean seen-demands)
      if demand <= norm [
        set accept true ;; accept if demand is lower than the norm
      ]
    ][
      let rate random-normal initial-accept-mean initial-accept-sd ;; draw from a random distribution
      if (random-float 1 < rate) [
        set accept true
      ]
    ]

    ifelse not accept [   
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

;; Update norm values for the player agents
to update-norms
  ask players [
    let demand 0
    let accepted 0

    ask my-out-links [
      set demand prop-demand ;; amount demanded by the proposer
      set accepted resp-accept ;; whether the offer was accepted or not
    ]

    set seen-demands lput demand seen-demands ;; update seen demands

    ifelse accepted = 1 [
      if demand > max-accepted [
        set max-accepted demand ;; update highest accepted demand
      ]
    ][
      if (demand < min-rejected) or (min-rejected = 0) [
        set min-rejected demand ;; update lowest rejected demand
      ]
    ]
  ]
end

;; Write results to the log file
to write-log
  let demands [prop-demand] of links
  let accepted [resp-accept] of links
  file-type (word current-sim ",")
  file-type (word current-round ",")
  file-type (word mean demands ",")
  file-type (word mean accepted)
  file-print ""
end
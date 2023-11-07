extensions [ csv rnd ]
breed [posts post]
breed [comments comment]
posts-own [number-of-comments number-of-upvotes id growthCommentsAlert growthUpvotesAlert hasImage titleLength textLength titleSentiment textSentiment succesfulUser memberCount]
globals [init-post-counter filecounter number-of-posts-in-csv max-number-of-comments max-number-of-upvotes  comments-difference upvotes-difference modell-counter-comments modell-counter-upvotes stepSizeX stepSizeY growthComments growthUpvotes controversial]



to setup
  clear-all
  set-default-shape posts "circle"
  set-default-shape comments "circle 2"
  set filecounter 1
  set number-of-posts-in-csv 0
  set max-number-of-comments 0
  set max-number-of-upvotes 0
  set comments-difference find-comments-difference
  set upvotes-difference find-upvotes-difference
  set modell-counter-comments comments-difference
  set modell-counter-upvotes upvotes-difference
  count-turtles-from-csv
  set stepSizeX (world-width / sqrt number-of-posts-in-csv) - 0.05
  set stepSizeY world-height / sqrt number-of-posts-in-csv
  read-initial-turtles-from-csv
  reset-ticks
end

to-report find-comments-difference
  file-close-all
  let begin-comment-number 0
  let end-comment-number 0
  if not file-exists? (word csv-file-dropdown min-file-number ".csv") [
    user-message (word "No file " csv-file-dropdown min-file-number" exists!")
    report 0
  ]
  file-open (word csv-file-dropdown min-file-number ".csv") ;
  while [ not file-at-end?] [
    let data csv:from-row file-read-line
    if item 10 data = "post" [
      set begin-comment-number begin-comment-number + (item 1 data)
    ]
  ]
  if not file-exists? (word csv-file-dropdown max-file-number ".csv") [
    user-message (word "No file " csv-file-dropdown max-file-number" exists!")
    report 0
  ]
  file-open (word csv-file-dropdown max-file-number ".csv") ;
  while [ not file-at-end?] [
    let data csv:from-row file-read-line
    if item 10 data = "post" [
      set end-comment-number end-comment-number + (item 1 data)
    ]
  ]

  report end-comment-number - begin-comment-number
end

to-report find-upvotes-difference
  file-close-all
  let begin-upvotes-number 0
  let end-upvotes-number 0
  if not file-exists? (word csv-file-dropdown min-file-number ".csv") [
    user-message (word "No file " csv-file-dropdown min-file-number" exists!")
    report 0
  ]
  file-open (word csv-file-dropdown min-file-number ".csv") ;
  while [ not file-at-end?] [
    let data csv:from-row file-read-line
    if item 10 data = "post" [
      set begin-upvotes-number begin-upvotes-number + (item 2 data)
    ]
  ]
  if not file-exists? (word csv-file-dropdown max-file-number ".csv") [
    user-message (word "No file " csv-file-dropdown max-file-number" exists!")
    report 0
  ]
  file-open (word csv-file-dropdown max-file-number ".csv") ;
  while [ not file-at-end?] [
    let data csv:from-row file-read-line
    if item 10 data = "post" [
      set end-upvotes-number end-upvotes-number + (item 2 data)
    ]
  ]

  report end-upvotes-number - begin-upvotes-number
end

to count-turtles-from-csv
  file-close-all

  if not file-exists? (word csv-file-dropdown filecounter ".csv") [
    user-message (word "No file " csv-file-dropdown filecounter" exists!")
    stop
  ]
  file-open (word csv-file-dropdown filecounter ".csv") ;

  while [ not file-at-end?] [
    let data csv:from-row file-read-line
    if item 10 data = "post" [
      set number-of-posts-in-csv number-of-posts-in-csv + 1
      if max-number-of-comments < item 1 data [
        set max-number-of-comments item 1 data
      ]
      if max-number-of-upvotes < item 2 data [
        set max-number-of-upvotes item 2 data
      ]
    ]
  ]
  file-close
end

to read-initial-turtles-from-csv
  file-close-all

  if not file-exists? (word csv-file-dropdown filecounter ".csv") [
    user-message (word "No file " csv-file-dropdown filecounter" exists!")
    stop
  ]
  file-open (word csv-file-dropdown filecounter ".csv") ;
  let xcor4turtle Min-pxcor - stepSizeX
  let ycor4turtle Min-pycor
  while [ not file-at-end?] [
    let data csv:from-row file-read-line
    if item 10 data = "post" [
      create-posts 1 [
        set xcor    xcor4turtle
        set ycor    ycor4turtle
        set number-of-comments item 1 data
        if number-of-comments < 5 [set number-of-comments 0]
        set number-of-upvotes item 2 data
        set growthCommentsAlert false
        set growthUpvotesAlert false
        set id item 3 data
        if visualize-object = "comments"[
          set color red
          ;0.6 ist minimal sichtbare größe, 11 ist als maximale größe definiert um übersicht zu bewahren, % wert im vergleich zu maximaler kommentarzahl wird zu wert zwischen 0.6 und 11 umgerechnet
          set size (number-of-comments / (max-number-of-comments) ) * 11 + 0.6
        ]
        if visualize-object = "upvotes"[
          set color green
          set size (number-of-upvotes / (max-number-of-upvotes) ) * 11 + 0.6
        ]
        set hasImage item 4 data
        set titleLength item 5 data
        set textLength item 6 data
        set titleSentiment item 7 data
        set textSentiment item 8 data
        set succesfulUser item 9 data
        set memberCount item 11 data
      ]
    ]
    ;calculate coordinate for next turtle
    set xcor4turtle xcor4turtle + stepSizeX
    if xcor4turtle >= max-pxcor [
      set xcor4turtle  Min-pxcor
      set ycor4turtle ycor4turtle + stepSizeY
    ]
  ]
  set filecounter filecounter + 1
  file-close
end

to update-turtles-from-csv
  file-close-all
  count-turtles-from-csv
  if not file-exists? (word csv-file-dropdown filecounter ".csv") [
    user-message (word "No file " csv-file-dropdown filecounter" exists!")
    stop
  ]
  file-open (word csv-file-dropdown filecounter ".csv") ;
  let xcor4turtle Min-pxcor - stepSizeX
  let ycor4turtle Min-pycor
  let linecounter 0
  let commentsBefore sum [number-of-comments] of posts
  let upvotesBefore sum [number-of-upvotes] of posts
  while [ not file-at-end?] [
    let data csv:from-row file-read-line
    if linecounter > 0 [
      ask post (linecounter - 1) [
        ;set +1 to avoid division by zero
        ifelse thresholdOptions = "factor"[
          if ((item 1 data + 1) / (number-of-comments + 1)) > growthAlertThreshold[
            set growthCommentsAlert true
          ]
          if ((item 2 data + 1) / (number-of-upvotes + 1)) > growthAlertThreshold[
            set growthUpvotesAlert true
          ]
        ][
          if (item 1 data + 1)  > ((number-of-comments + 1) + growthAlertThreshold)[
            set growthCommentsAlert true
          ]
          if (item 2 data + 1) > ((number-of-upvotes + 1) + growthAlertThreshold)[
            set growthUpvotesAlert true
          ]
        ]
        set number-of-comments item 1 data
        set number-of-upvotes item 2 data
        if visualize-object = "comments"[
          set color red
          if growthCommentsAlert = true [
            set color white
            if growthUpvotesAlert = true
            [
              set color blue
            ]
            show id
          ]
          ;0.6 ist minimal sichtbare größe, 11 ist als maximale größe definiert um übersicht zu bewahren, % wert im vergleich zu maximaler kommentarzahl wird zu wert zwischen 0.6 und 11 umgerechnet
          set size (number-of-comments / (max-number-of-comments) ) * 11 + 0.6
        ]
        if visualize-object = "upvotes"[
          set color green
          if growthUpvotesAlert = true [
            set color white
            if growthCommentsAlert = true
            [
              set color red
            ]
            show id
          ]
          set size (number-of-upvotes / (max-number-of-upvotes) ) * 11 + 0.6
        ]
        set growthCommentsAlert false
        set growthUpvotesAlert false
      ]
    ]
    ;calculate coordinate for next turtle
    set linecounter linecounter + 1
  ]
  set filecounter filecounter + 1
  file-close
  set growthComments (((sum [number-of-comments] of posts) / commentsBefore)) * 100
  set growthUpvotes (((sum [number-of-upvotes] of posts) / upvotesBefore)) * 100
  show "--------"
end


to visualize
  if visualize-object = "comments"[
    ask posts [set size (number-of-comments / (max-number-of-comments) ) * 11 + 0.6]
    ask posts [set color red]
  ]
  if visualize-object = "upvotes"[
    ask posts [set size (number-of-upvotes / (max-number-of-upvotes) ) * 11 + 0.6]
    ask posts [set color green]
  ]
end

to go
  set number-of-posts-in-csv 0
  if not file-exists? (word csv-file-dropdown filecounter ".csv") [
    user-message (word "Kein File mit dem Namen " csv-file-dropdown filecounter ".csv existiert")
    stop
  ]
  update-turtles-from-csv
  reset-ticks
end

to-report find-post-for-comments-sim
  if Model-Simulation = "Barabasi-Albert"
  [
    report rnd:weighted-one-of posts [ number-of-comments / (sum [number-of-comments] of posts) ]
  ]
  if Model-Simulation = "Inner Log DS1"
  [
    report rnd:weighted-one-of posts [ number-of-comments * 0.594 + number-of-upvotes * 0.406]
  ]
  if Model-Simulation = "Middle Log DS1"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.018) + (number-of-upvotes * 0.012) + (titleLength * 0.383) - (textLength * 0.006) - (hasImage * 0.518) - (titleSentiment * 0.063)) >= 0 [
        (number-of-comments * 0.018) + (number-of-upvotes * 0.012) + (titleLength * 0.383) - (textLength * 0.006) - (hasImage * 0.518) - (titleSentiment * 0.063)
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Outer Log DS1"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.232) + (number-of-upvotes * 0.159) - (hasImage * 0.124) - (titleSentiment * 0.156) + (memberCount * 0.329)) >= 0 [
        (number-of-comments * 0.232) + (number-of-upvotes * 0.159) - (hasImage * 0.124) - (titleSentiment * 0.156) + (memberCount * 0.329)
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Inner Log DS2"
  [
    report rnd:weighted-one-of posts [
      ifelse-value (number-of-comments * 0.764 + number-of-upvotes * 0.236) >= 0 [
        number-of-comments * 0.764 + number-of-upvotes * 0.236
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Middle Log DS2"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.359) + (number-of-upvotes * 0.140) - (textLength * 0.062) - (hasImage * 0.123) - (titleSentiment * 0.062) - (textSentiment * 0.084) - (SuccesfulUser * 0.169)) >= 0 [
        (number-of-comments * 0.359) + (number-of-upvotes * 0.140) - (textLength * 0.062) - (hasImage * 0.123) - (titleSentiment * 0.062) - (textSentiment * 0.084) - (SuccesfulUser * 0.169)
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Outer Log DS2"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.048) + (number-of-upvotes * 0.019) + (textLength * 0.016) - (hasImage * 0.004) - (titleSentiment * 0.008) - (textSentiment * 0.008) + (controversial * 0.010) + (memberCount * 0.887)) >= 0 [
        (number-of-comments * 0.048) + (number-of-upvotes * 0.019) + (textLength * 0.016) - (hasImage * 0.004) - (titleSentiment * 0.008) - (textSentiment * 0.008) + (controversial * 0.010) + (memberCount * 0.887)
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Inner Neg B DS1"
  [
    report rnd:weighted-one-of posts [
      ifelse-value (number-of-comments * 0.921 + number-of-upvotes * 0.072) >= 0 [
        number-of-comments * 0.921 + number-of-upvotes * 0.072
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Middle Neg B DS1"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.591) + (number-of-upvotes * 0.126) + (textSentiment * 0.281)) >= 0 [
        (number-of-comments * 0.591) + (number-of-upvotes * 0.126) + (textSentiment * 0.281)
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Outer Neg B DS1"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.232) + (number-of-upvotes * 0.159) + (textSentiment * 0.050) + (SuccesfulUser * 0.135) + (memberCount * 0.329)) >= 0 [
        (number-of-comments * 0.232) + (number-of-upvotes * 0.159) + (textSentiment * 0.050) + (SuccesfulUser * 0.135) + (memberCount * 0.329)
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Inner Neg B DS2"
  [
    report rnd:weighted-one-of posts [ number-of-comments * 1.000 + number-of-upvotes * 0.000 ]
  ]
  if Model-Simulation = "Middle Neg B DS2"
  [
    report rnd:weighted-one-of posts [number-of-comments * 1.00]
  ]
  if Model-Simulation = "Outer Neg B DS2"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.581) + (number-of-upvotes * 0.131) - (controversial * 0.083) + (memberCount * 0.008)) >= 0 [
        (number-of-comments * 0.581) + (number-of-upvotes * 0.131) - (controversial * 0.083) + (memberCount * 0.008)
      ] [
        0
      ]
    ]
  ]
end

to-report find-post-for-upvotes-sim
  ;;report rnd:weighted-one-of posts [ number-of-comments * number-of-comments * comment-weight]
  if Model-Simulation = "Barabasi-Albert"
  [
    report rnd:weighted-one-of posts [ number-of-upvotes / (sum [number-of-upvotes] of posts) ]
  ]
  if Model-Simulation = "Inner Log DS1"
  [
    report rnd:weighted-one-of posts [ (number-of-comments * 0.154) + (number-of-upvotes * 0.846)]
  ]
  if Model-Simulation = "Middle Log DS1"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.009) + (number-of-upvotes * 0.030) + (titleLength * 0.034) + (hasImage * 0.410) - (titleSentiment * 0.042) + (textSentiment * 0.027) + (SuccesfulUser * 0.450)) >= 0 [
        (number-of-comments * 0.009) + (number-of-upvotes * 0.030) + (titleLength * 0.034) + (hasImage * 0.410) - (titleSentiment * 0.042) + (textSentiment * 0.027) + (SuccesfulUser * 0.450)
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Outer Log DS1"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.149) + (number-of-upvotes * 0.131) + (textLength * 0.093) + (hasImage * 0.128) - (titleSentiment * 0.119) + (textSentiment * 0.114) + (SuccesfulUser * 0.120) + (memberCount * 0.147)) >= 0 [
        (number-of-comments * 0.149) + (number-of-upvotes * 0.131) + (textLength * 0.093) + (hasImage * 0.128) - (titleSentiment * 0.119) + (textSentiment * 0.114) + (SuccesfulUser * 0.120) + (memberCount * 0.147)
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Inner Log DS2"
  [
    report rnd:weighted-one-of posts [ (number-of-comments * 0.305) + (number-of-upvotes * 0.695) ]
  ]
  if Model-Simulation = "Middle Log DS2"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.274) + (number-of-upvotes * 0.294) + (titleLength * 0.180) + (textLength * 0.100) + (hasImage * 0.145) + (SuccesfulUser * 0.007)) >= 0 [
        (number-of-comments * 0.274) + (number-of-upvotes * 0.294) + (titleLength * 0.180) + (textLength * 0.100) + (hasImage * 0.145) + (SuccesfulUser * 0.007)
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Outer Log DS2"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.154) + (number-of-upvotes * 0.163) + (textLength * 0.049) + (hasImage * 0.096) + (SuccesfulUser * 0.082) + (controversial * 0.118) + (memberCount * 0.337)) >= 0 [
        (number-of-comments * 0.154) + (number-of-upvotes * 0.163) + (textLength * 0.049) + (hasImage * 0.096) + (SuccesfulUser * 0.082) + (controversial * 0.118) + (memberCount * 0.337)
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Inner Neg B DS1"
  [
    report rnd:weighted-one-of posts [ (number-of-comments * 0.478) + (number-of-upvotes * 0.522) ]
  ]
  if Model-Simulation = "Middle Neg B DS1"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.643) + (number-of-upvotes * 0.304) - (titleSentiment * 0.079) + (textSentiment * 0.259) + (SuccesfulUser * 0.282)) >= 0 [
        (number-of-comments * 0.643) + (number-of-upvotes * 0.304) - (titleSentiment * 0.079) + (textSentiment * 0.259) + (SuccesfulUser * 0.282)
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Outer Neg B DS1"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.739) + (number-of-upvotes * 0.164) + (hasImage * 0.070) - (titleSentiment * 0.125) + (textSentiment * 0.049) + (SuccesfulUser * 0.196)) >= 0 [
        (number-of-comments * 0.739) + (number-of-upvotes * 0.164) + (hasImage * 0.070) - (titleSentiment * 0.125) + (textSentiment * 0.049) + (SuccesfulUser * 0.196)
      ] [
        0
      ]
    ]
  ]
  if Model-Simulation = "Inner Neg B DS2"
  [
    report rnd:weighted-one-of posts [ (number-of-comments * 0.645) + (number-of-upvotes * 0.355) ]
  ]
  if Model-Simulation = "Middle Neg B DS2"
  [
    report rnd:weighted-one-of posts [ (number-of-comments * 0.434) + (number-of-upvotes * 0.356) + (SuccesfulUser * 0.210)]
  ]
  if Model-Simulation = "Outer Neg B DS2"
  [
    report rnd:weighted-one-of posts [
      ifelse-value ((number-of-comments * 0.581) + (number-of-upvotes * 0.131) + (hasImage * 0.106) - (controversial * 0.072) + (memberCount * 0.002)) >= 0 [ ;
        (number-of-comments * 0.581) + (number-of-upvotes * 0.131) + (hasImage * 0.106) - (controversial * 0.072)+ (memberCount * 0.002); membercount entfernt, da für alle threads gleich und somit das ergebnis verfälscht.
      ] [
        0
      ]
    ]
  ]
end

to modell-go
  ifelse modell-counter-comments > 0 OR modell-counter-upvotes > 0 [
    if modell-counter-comments > 0 [
      ask find-post-for-comments-sim
      [
        set number-of-comments number-of-comments + 1
        if number-of-comments > max-number-of-comments [
          set max-number-of-comments number-of-comments
        ]
        if visualize-object = "comments"
        [
          set size (number-of-comments / (max-number-of-comments)) * 11 + 0.6
        ]
      ]
      set modell-counter-comments modell-counter-comments - 1
    ]
    if modell-counter-upvotes > 0 [
      ask find-post-for-upvotes-sim
      [
        set number-of-upvotes number-of-upvotes + 1
        if number-of-upvotes > max-number-of-upvotes [
          set max-number-of-upvotes number-of-upvotes
        ]
        if visualize-object = "upvotes"
        [
          set size (number-of-upvotes / (max-number-of-upvotes)) * 11 + 0.6
        ]
      ]
      set modell-counter-upvotes modell-counter-upvotes - 1
    ]
  ][
    user-message (word "Anzahl Posts der Datenbasis fuer beide Variablen erreicht.")
    stop
  ]
  tick
end

to modell-go-anyway
    ask find-post-for-comments-sim
    [
      set number-of-comments number-of-comments + 1
      if number-of-comments > max-number-of-comments [
        set max-number-of-comments number-of-comments
      ]
      if visualize-object = "comments"
      [
        set size (number-of-comments / (max-number-of-comments)) * 11 + 0.6
      ]
    ]
    set modell-counter-comments modell-counter-comments - 1

    ask find-post-for-upvotes-sim
    [
      set number-of-upvotes number-of-upvotes + 1
      if number-of-upvotes > max-number-of-upvotes [
        set max-number-of-upvotes number-of-upvotes
      ]
      if visualize-object = "upvotes"
      [
        set size (number-of-upvotes / (max-number-of-upvotes)) * 11 + 0.6
      ]
    ]
    set modell-counter-upvotes modell-counter-upvotes - 1
    tick
end

to modell-go-without-count
    ask find-post-for-comments-sim [set number-of-upvotes number-of-upvotes + 1]
    ask find-post-for-upvotes-sim [set number-of-upvotes number-of-upvotes + 1]
    set modell-counter-comments modell-counter-comments - 1 ;ist noch quatsch
end
@#$#@#$#@
GRAPHICS-WINDOW
1083
10
1487
415
-1
-1
2.81
1
10
1
1
1
0
0
0
1
-70
70
-70
70
0
0
1
ticks
30.0

BUTTON
15
25
110
58
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
15
77
110
110
go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
124
77
225
110
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
15
168
110
213
# of threads
count posts
3
1
11

SWITCH
15
225
143
258
plotComments?
plotComments?
0
1
-1000

PLOT
14
489
526
732
Degree Distribution of  all Comments
degree
# of nodes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if not plotComments? [ stop ]\nlet max-degree max [number-of-comments] of posts\nplot-pen-reset  ;; erase what we plotted before\nset-plot-x-range 1 (max-degree + 1)  ;; + 1 to make room for the width of the last bar\nhistogram [number-of-comments] of posts"

PLOT
268
324
541
468
Degree Distribution of all Comments (log-log)
log(degree)
log(# of nodes)
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if not plotComments? [ stop ]\nlet max-degree max [number-of-comments] of posts\n;; for this plot, the axes are logarithmic, so we can't\n;; use \"histogram-from\"; we have to plot the points\n;; ourselves one at a time\nplot-pen-reset  ;; erase what we plotted before\n;; the way we create the network there is never a zero degree node,\n;; so start plotting at degree one\nlet degree 1\nwhile [degree <= max-degree] [\n  let matches posts with [number-of-comments = degree]\n  if any? matches\n    [ plotxy log degree 10\n             log (count matches) 10 ]\n  set degree degree + 1\n]"

PLOT
548
489
1060
732
Degree Distribution of all Upvotes for Posts
degree
# of nodes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if not plotUpvotes? [ stop ]\nlet max-degree max [number-of-upvotes] of posts\nplot-pen-reset  ;; erase what we plotted before\nset-plot-x-range 1 (max-degree + 1)  ;; + 1 to make room for the width of the last bar\nhistogram [number-of-upvotes] of posts"

BUTTON
15
118
110
151
model-go-once
modell-go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
124
118
226
151
model-go
modell-go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
124
168
256
213
Total Comments
sum [number-of-comments] of posts
17
1
11

INPUTBOX
475
91
570
151
min-file-number
1.0
1
0
Number

MONITOR
268
168
411
213
NIL
max-number-of-comments
17
1
11

SWITCH
15
266
143
299
plotUpvotes?
plotUpvotes?
0
1
-1000

BUTTON
15
346
104
379
Close Files
file-close-all
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
421
168
541
213
Total Upvotes
sum [number-of-upvotes] of posts
17
1
11

MONITOR
549
168
697
213
NIL
max-number-of-upvotes
17
1
11

CHOOSER
536
11
674
56
visualize-object
visualize-object
"comments" "upvotes"
0

BUTTON
681
11
759
44
visualize
visualize
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
128
11
300
56
csv-file-dropdown
csv-file-dropdown
"starfield_sim/starfield_export"
0

MONITOR
268
218
411
263
Growth Comments %
growthComments
2
1
11

MONITOR
421
218
541
263
Growth Upvotes %
growthUpvotes
2
1
11

CHOOSER
932
11
1070
56
thresholdOptions
thresholdOptions
"factor" "totalAmount"
0

INPUTBOX
768
11
923
71
growthAlertThreshold
10000.0
1
0
Number

INPUTBOX
582
91
677
151
max-file-number
2.0
1
0
Number

CHOOSER
317
11
461
56
Model-Simulation
Model-Simulation
"Inner Log DS1" "Middle Log DS1" "Outer Log DS1" "Inner Log DS2" "Middle Log DS2" "Outer Log DS2" "Inner Neg B DS1" "Middle Neg B DS1" "Outer Neg B DS1" "Inner Neg B DS2" "Middle Neg B DS2" "Outer Neg B DS2" "Barabasi-Albert"
11

MONITOR
421
267
541
312
Diff to Upvotes in File
modell-counter-upvotes
17
1
11

MONITOR
268
268
411
313
Diff to Comments in File
modell-counter-comments
17
1
11

BUTTON
351
118
452
151
modell-go-anyway
modell-go-anyway
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
240
118
342
151
NIL
modell-go-anyway
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

Simulation or visualizition based on time-discrete reddit-data

## HOW IT WORKS

Load file in specific format and start simulation (go) or vizualization (model go)

## HOW TO USE IT

Data-files must end with numbers from 1 to X. E.g.: askreddit1, askreddit2, ....
edit csv-file-dropdown to add additional files.

## THINGS TO NOTICE

format for csv-files:
communityName,numberOfComments,upVotes,id,hasImage,titleLength,bodyLength,title_sentiment,body_sentiment,Successful_User,Type,MemberCount,Karma

r/Starfield,0,1,t3_16ic20g,0,67,128,-4,2,0,post,620000,0


Deactivate plots to speed up simulations.

## EXTENDING THE MODEL

Any calculation based on different coefficients can be added easily in the code section

## NETLOGO FEATURES

Weighted-one-of used to calculate probabilities for simulation. csv-package used to import csv-files
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

computer workstation
false
0
Rectangle -7500403 true true 60 45 240 180
Polygon -7500403 true true 90 180 105 195 135 195 135 210 165 210 165 195 195 195 210 180
Rectangle -16777216 true false 75 60 225 165
Rectangle -7500403 true true 45 210 255 255
Rectangle -10899396 true false 249 223 237 217
Line -16777216 false 60 225 120 225

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

letter sealed
false
0
Rectangle -7500403 true true 30 90 270 225
Rectangle -16777216 false false 30 90 270 225
Line -16777216 false 270 105 150 180
Line -16777216 false 30 105 150 180
Line -16777216 false 270 225 181 161
Line -16777216 false 30 225 119 161

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
NetLogo 6.3.0
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

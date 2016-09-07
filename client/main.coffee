Template.body.onRendered ->
  console.log ">>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<"
  console.log ">>>> WELCOME TO RX RUSSION ROULETTE <<<<"
  console.log ">>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<"

  gunSound = new Audio '/gun.mp3'
  shellSound = new Audio '/shell.mp3'
  rollSound = new Audio '/roll.mp3'
  dryFire = new Audio '/dry.mp3'
  Audio::playFromStart = ->
    @currentTime = 0
    @play()
  shootGunSound = ->
    gunSound.playFromStart()
    setTimeout ->
      shellSound.playFromStart()
      rollSound.playFromStart()
    , 400

  button = document.querySelector('button')

  # 죽은 러시안 스트림
  deadRussian$ = new Rx.Subject
  deadRussian$.map -> 1
  .scan (o)-> o+1
  .subscribe (o)->
    button.textContent = "Reload and Fire 1"
    document.querySelector('p.dead-count').textContent = "#{o} Russians Dead"

  # 방아쇠를 당긴 횟수 스트림
  triggerCount$ = new Rx.Subject
  triggerCount$.map -> 1
  .scan (tc)-> tc+1
  .subscribe (tc)->
    document.querySelector('p.triggered-count').textContent = "#{tc} Times Triggered"


  shotEvent$ = Rx.Observable.fromEvent(button, 'click')
  shotEvent$.subscribe (e)->
    $thisButton = $(e.currentTarget)
    $thisButton.addClass 'pressed'
    $thisButton.one 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', ->
      $thisButton.removeClass 'pressed'
  shotEvent$.subscribe ->
    triggerCount$.next('triggered')
  shot$ = ->
    shotEvent$.scan (status, e)->
      Object.assign status,
        count: status.count + 1
        e: e.currentTarget
        bullet: status.bullet
        rotation: status.rotation + 60
    ,
      count: 0
      bullet: Math.floor(Math.random() * (6 - 1 + 1)) + 1
      dead: 0
      rotation: 0
    .takeWhile (o)->
      # 이 Stream은 count 가 bullet 만큼 도달할 때 까지 유효함
      # false 시 complete
      o.count < o.bullet
    .subscribe
      next: (o)->
        console.log "Fired Bullet : #{o.count}"
        o.e.textContent = "Fire #{o.count + 1}"
        dryFire.playFromStart()
        TweenMax.to '#chamber', 0.1,
          rotation: o.rotation
      complete: ->
        # 총알이 나갔을 때
        ## Bang 하고
        console.log "!!!!! BANG !!!!!"
        TweenMax.to '#chamber', 1.2,
          rotation: 1800
          ease: Power4.easeOut
          onComplete: ->
            TweenMax.to '#chamber', 0,
              rotation: 0
        shootGunSound()
        ## 러시안이 죽는다.
        deadRussian$.next('die')
        ## 그리고 이 스트림은 종료되면서 새로운 스트림을 시작
        shot$()
  shot$()

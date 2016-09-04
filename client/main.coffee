Template.body.onRendered ->
  console.log ">>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<"
  console.log ">>>> WELCOME TO RX RUSSION ROULETTE <<<<"
  console.log ">>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<"

  shootGunSound = ->
    gunSound = new Audio '/gun.mp3'
    shellSound = new Audio '/shell.mp3'
    gunSound.play()
    setTimeout ->
      shellSound.play()
    , 400

  button = document.querySelector('button')

  # 죽은 러시안 스트림
  deadRussian$ = new Rx.Subject
  deadRussian$.map ->1
  .scan (o)-> o+1
  .subscribe (o)->
    button.textContent = "Reload and Fire 1"

    document.querySelector('p').textContent = "#{o} Russians Dead"

  shot$ = ->
    Rx.Observable.fromEvent(button, 'click')
    .scan (status, e)->
      _.extend status,
        count: status.count + 1
        e: e.currentTarget
        bullet: status.bullet
    ,
      count: 0
      bullet: Math.floor(Math.random() * (6 - 1 + 1)) + 1
      dead: 0
    .takeWhile (o)->
      # 이 Stream은 count 가 bullet 만큼 도달할 때 까지 유효함
      # false 시 complete
      o.count < o.bullet
    .subscribe
      next: (o)->
        console.log "Fired Bullet : #{o.count}"
        o.e.textContent = "Fire #{o.count + 1}"
      complete: ->
        # 총알이 나갔을 때
        ## Bang 하고
        console.log "!!!!! BANG !!!!!"
        shootGunSound()
        ## 러시안이 죽는다.
        deadRussian$.next('die')
        ## 그리고 이 스트림은 종료되면서 새로운 스트림을 시작
        shot$()
  shot$()
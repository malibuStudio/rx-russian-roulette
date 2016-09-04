Template.body.onRendered ->
  console.log ">>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<"
  console.log ">>>> WELCOME TO RX RUSSION ROULETTE <<<<"
  console.log ">>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<"

  reloadRevolver = (o)->
    console.log "Reload"
    o.e.textContent = "Reload and Fire 1"
    o.count = 0
    o.bullet = Math.floor(Math.random() * (6 - 1 + 1)) + 1

  shootGunSound = ->
    gunSound = new Audio '/gun.mp3'
    shellSound = new Audio '/shell.mp3'
    gunSound.play()
    setTimeout ->
      shellSound.play()
    , 400

  button = document.querySelector('button')

  clickButton = Rx.Observable.fromEvent(button, 'click')
    .scan (status, e)->
      _.extend status,
        count: status.count + 1
        e: e.currentTarget
        bullet: status.bullet
    ,
      count: 0
      bullet: Math.floor(Math.random() * (6 - 1 + 1)) + 1
      dead: 0
    .subscribe (o)->
      unless o.count is o.bullet
        console.log "Fired Bullet : #{o.count}"
        o.e.textContent = "Fire #{o.count + 1} "
      else
        console.log "!!!!! BANG !!!!!"
        shootGunSound()
        o.dead = o.dead + 1
        document.querySelector('p').textContent = "#{o.dead} Russians Dead"
        reloadRevolver(o)

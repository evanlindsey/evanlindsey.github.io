---
---

# Space Invaders game module
class @SpaceInvaders
	constructor: (@canvas, @onExit) ->
		@ctx = @canvas.getContext('2d')
		@canvas.width = 600
		@canvas.height = 400

		# Game state
		@player =
			x: @canvas.width / 2 - 15
			y: @canvas.height - 30
			width: 30
			height: 15
			speed: 5
			color: '#0F0'
			lives: 3
			isMovingLeft: false
			isMovingRight: false

		@bullets = []
		@enemies = []
		@stars = []
		@score = 0
		@level = 1
		@gameOver = false
		@lastEnemyMove = Date.now()
		@enemyDirection = 1
		@gameAnimationId = null

		# Bind event handlers so we can remove them later
		@handleKeyDown = @handleKeyDown.bind(this)
		@handleKeyUp = @handleKeyUp.bind(this)

	start: ->
		@initStars()
		@initEnemies()

		document.addEventListener 'keydown', @handleKeyDown
		document.addEventListener 'keyup', @handleKeyUp

		@gameLoop()

	stop: ->
		cancelAnimationFrame(@gameAnimationId) if @gameAnimationId
		document.removeEventListener 'keydown', @handleKeyDown
		document.removeEventListener 'keyup', @handleKeyUp
		@onExit?(@score, @level)

	handleKeyDown: (e) ->
		switch e.key
			when 'ArrowLeft' then @player.isMovingLeft = true
			when 'ArrowRight' then @player.isMovingRight = true
			when ' '
				@bullets.push
					x: @player.x + @player.width / 2 - 2
					y: @player.y
					width: 4
					height: 10
					speed: 7
			when 'Escape'
				@stop()
				e.preventDefault()

	handleKeyUp: (e) ->
		switch e.key
			when 'ArrowLeft' then @player.isMovingLeft = false
			when 'ArrowRight' then @player.isMovingRight = false

	initStars: ->
		for i in [0...50]
			@stars.push
				x: Math.random() * @canvas.width
				y: Math.random() * @canvas.height
				size: Math.random() * 2 + 1
				speed: Math.random() * 2 + 1

	initEnemies: ->
		@enemies = []
		rows = 3 + Math.min(2, Math.floor(@level / 3))
		cols = 8
		for row in [0...rows]
			for col in [0...cols]
				@enemies.push
					x: col * 50 + 50
					y: row * 40 + 50
					width: 30
					height: 20
					type: row
					alive: true

	drawPlayer: ->
		@ctx.fillStyle = @player.color
		@ctx.fillRect(@player.x, @player.y, @player.width, @player.height)
		@ctx.fillRect(@player.x + @player.width/2 - 2, @player.y - 5, 4, 5)

	drawBullets: ->
		@ctx.fillStyle = '#FFF'
		for bullet in @bullets
			@ctx.fillRect(bullet.x, bullet.y, bullet.width, bullet.height)

	drawEnemies: ->
		for enemy in @enemies when enemy.alive
			switch enemy.type
				when 0
					@ctx.fillStyle = '#FF0000'
					@ctx.fillRect(enemy.x, enemy.y, enemy.width, enemy.height)
					@ctx.fillRect(enemy.x + 5, enemy.y - 5, enemy.width - 10, 5)
				when 1
					@ctx.fillStyle = '#00FFFF'
					@ctx.fillRect(enemy.x, enemy.y, enemy.width, enemy.height)
					@ctx.fillRect(enemy.x, enemy.y - 8, 10, 8)
					@ctx.fillRect(enemy.x + enemy.width - 10, enemy.y - 8, 10, 8)
				else
					@ctx.fillStyle = '#FFFF00'
					@ctx.fillRect(enemy.x, enemy.y, enemy.width, enemy.height)
					@ctx.fillRect(enemy.x + 5, enemy.y + enemy.height, enemy.width - 10, 5)

	drawStars: ->
		@ctx.fillStyle = '#FFF'
		for star in @stars
			@ctx.beginPath()
			@ctx.arc(star.x, star.y, star.size, 0, Math.PI * 2)
			@ctx.fill()

	drawHUD: ->
		@ctx.fillStyle = '#FFF'
		@ctx.font = '16px VT323'
		@ctx.fillText("SCORE: #{@score}", 10, 20)
		@ctx.fillText("LEVEL: #{@level}", @canvas.width - 100, 20)
		@ctx.fillText("LIVES: #{@player.lives}", 10, @canvas.height - 10)

		if @gameOver
			@ctx.fillStyle = 'rgba(0, 0, 0, 0.7)'
			@ctx.fillRect(0, 0, @canvas.width, @canvas.height)

			@ctx.fillStyle = '#FF0000'
			@ctx.font = '36px VT323'
			@ctx.textAlign = 'center'
			@ctx.fillText('GAME OVER', @canvas.width / 2, @canvas.height / 2 - 20)

			@ctx.fillStyle = '#FFF'
			@ctx.font = '24px VT323'
			@ctx.fillText("FINAL SCORE: #{@score}", @canvas.width / 2, @canvas.height / 2 + 20)
			@ctx.fillText('Press ESC to exit', @canvas.width / 2, @canvas.height / 2 + 60)
			@ctx.textAlign = 'left'

	getEnemyMoveDelay: ->
		baseDelay = 800
		Math.max(100, baseDelay - (@level * 70))

	getEnemySidewaysSpeed: ->
		baseSpeed = 5
		baseSpeed + (@level * 2)

	updateGame: ->
		# Move player
		if @player.isMovingLeft and @player.x > 0
			@player.x -= @player.speed
		if @player.isMovingRight and @player.x < @canvas.width - @player.width
			@player.x += @player.speed

		# Move bullets
		for bullet, i in @bullets by -1
			bullet.y -= bullet.speed
			if bullet.y < 0
				@bullets.splice(i, 1)

		# Move enemies
		currentTime = Date.now()
		moveDelay = @getEnemyMoveDelay()
		enemySpeed = @getEnemySidewaysSpeed()

		if currentTime - @lastEnemyMove > moveDelay
			@lastEnemyMove = currentTime

			hitEdge = false
			for enemy in @enemies when enemy.alive
				nextX = enemy.x + enemySpeed * @enemyDirection
				if nextX <= 0 or nextX + enemy.width >= @canvas.width
					hitEdge = true
					break

			if hitEdge
				@enemyDirection *= -1
				downSpeed = 15 + @level * 2
				for enemy in @enemies when enemy.alive
					enemy.y += downSpeed
			else
				for enemy in @enemies when enemy.alive
					enemy.x += enemySpeed * @enemyDirection

		# Move stars
		for star in @stars
			star.y += star.speed
			if star.y > @canvas.height
				star.y = 0
				star.x = Math.random() * @canvas.width

		@checkCollisions()
		@checkGameStatus()

	checkCollisions: ->
		# Bullet-enemy collisions
		for bullet, bi in @bullets by -1
			collision = false
			for enemy in @enemies when enemy.alive
				if bullet.x < enemy.x + enemy.width and
				   bullet.x + bullet.width > enemy.x and
				   bullet.y < enemy.y + enemy.height and
				   bullet.y + bullet.height > enemy.y
					enemy.alive = false
					collision = true
					@score += (3 - enemy.type) * 10 * @level
					break

			if collision
				@bullets.splice(bi, 1)

		# Enemy-player collisions
		for enemy in @enemies when enemy.alive
			if enemy.y + enemy.height >= @player.y and
			   enemy.x < @player.x + @player.width and
			   enemy.x + enemy.width > @player.x
				@player.lives -= 1
				if @player.lives <= 0
					@gameOver = true
				@initEnemies() if !@gameOver
				break

		# Enemies reached bottom
		for enemy in @enemies when enemy.alive
			if enemy.y + enemy.height >= @canvas.height - 40
				@player.lives = 0
				@gameOver = true
				break

	checkGameStatus: ->
		allDestroyed = true
		for enemy in @enemies
			if enemy.alive
				allDestroyed = false
				break

		if allDestroyed
			@level += 1
			@initEnemies()

			@ctx.fillStyle = 'rgba(0, 0, 0, 0.7)'
			@ctx.fillRect(0, 0, @canvas.width, @canvas.height)

			@ctx.fillStyle = '#FFFF00'
			@ctx.font = '36px VT323'
			@ctx.textAlign = 'center'
			@ctx.fillText("LEVEL #{@level}!", @canvas.width / 2, @canvas.height / 2 - 20)
			@ctx.textAlign = 'left'

	gameLoop: =>
		@ctx.fillStyle = 'rgba(0, 0, 0, 0.2)'
		@ctx.fillRect(0, 0, @canvas.width, @canvas.height)

		unless @gameOver
			@updateGame()

		@drawStars()
		@drawEnemies()
		@drawBullets()
		@drawPlayer() unless @gameOver
		@drawHUD()

		@gameAnimationId = requestAnimationFrame(@gameLoop)

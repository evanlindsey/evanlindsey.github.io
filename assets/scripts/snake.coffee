---
---

# Snake game module
class @SnakeGame
	constructor: (@canvas, @onExit) ->
		@ctx = @canvas.getContext('2d')
		@canvas.width = 400
		@canvas.height = 400
		@gridSize = 20
		@tileCount = @canvas.width / @gridSize

		# Game state
		@snake = []
		@food = { x: 0, y: 0 }
		@direction = { x: 0, y: 0 }
		@nextDirection = { x: 0, y: 0 }
		@score = 0
		@highScore = parseInt(localStorage.getItem('snake_high_score')) || 0
		@gameOver = false
		@paused = true # Start paused until player presses a direction
		@speed = 150 # Starting speed (ms per frame) - slower = easier
		@minSpeed = 60 # Fastest possible speed
		@gameLoopId = null

		# Bind event handlers
		@handleKeyDown = @handleKeyDown.bind(this)

	start: ->
		@initSnake()
		@placeFood()
		document.addEventListener 'keydown', @handleKeyDown
		@drawLoop()

	stop: ->
		clearTimeout(@gameLoopId) if @gameLoopId
		document.removeEventListener 'keydown', @handleKeyDown
		# Save high score
		if @score > @highScore
			localStorage.setItem('snake_high_score', @score)
		@onExit?(@score, @highScore)

	handleKeyDown: (e) ->
		# Prevent all input from reaching terminal while game is active
		e.preventDefault()
		e.stopPropagation()

		switch e.key
			when 'ArrowUp', 'w', 'W'
				if @direction.y != 1
					@nextDirection = { x: 0, y: -1 }
					@startGame() if @paused
			when 'ArrowDown', 's', 'S'
				if @direction.y != -1
					@nextDirection = { x: 0, y: 1 }
					@startGame() if @paused
			when 'ArrowLeft', 'a', 'A'
				if @direction.x != 1
					@nextDirection = { x: -1, y: 0 }
					@startGame() if @paused
			when 'ArrowRight', 'd', 'D'
				if @direction.x != -1
					@nextDirection = { x: 1, y: 0 }
					@startGame() if @paused
			when 'Escape'
				@stop()

	startGame: ->
		@paused = false
		@gameLoop()

	initSnake: ->
		startX = Math.floor(@tileCount / 2)
		startY = Math.floor(@tileCount / 2)
		@snake = [
			{ x: startX, y: startY }
			{ x: startX - 1, y: startY }
			{ x: startX - 2, y: startY }
		]

	placeFood: ->
		loop
			@food.x = Math.floor(Math.random() * @tileCount)
			@food.y = Math.floor(Math.random() * @tileCount)
			# Make sure food doesn't spawn on snake
			onSnake = false
			for segment in @snake
				if segment.x == @food.x and segment.y == @food.y
					onSnake = true
					break
			break unless onSnake

	update: ->
		return if @gameOver

		# Apply direction change
		@direction = @nextDirection

		# Calculate new head position
		head = @snake[0]
		newHead =
			x: head.x + @direction.x
			y: head.y + @direction.y

		# Check wall collision
		if newHead.x < 0 or newHead.x >= @tileCount or newHead.y < 0 or newHead.y >= @tileCount
			@gameOver = true
			return

		# Check self collision
		for segment in @snake
			if segment.x == newHead.x and segment.y == newHead.y
				@gameOver = true
				return

		# Add new head
		@snake.unshift(newHead)

		# Check food collision
		if newHead.x == @food.x and newHead.y == @food.y
			@score += 10
			if @score > @highScore
				@highScore = @score
			@placeFood()
			# Speed up gradually - smaller increments for smoother difficulty curve
			@speed = Math.max(@minSpeed, @speed - 3)
		else
			# Remove tail if no food eaten
			@snake.pop()

	draw: ->
		# Clear canvas
		@ctx.fillStyle = '#000'
		@ctx.fillRect(0, 0, @canvas.width, @canvas.height)

		# Draw grid (subtle)
		@ctx.strokeStyle = 'rgba(0, 255, 255, 0.1)'
		@ctx.lineWidth = 0.5
		for i in [0...@tileCount]
			@ctx.beginPath()
			@ctx.moveTo(i * @gridSize, 0)
			@ctx.lineTo(i * @gridSize, @canvas.height)
			@ctx.stroke()
			@ctx.beginPath()
			@ctx.moveTo(0, i * @gridSize)
			@ctx.lineTo(@canvas.width, i * @gridSize)
			@ctx.stroke()

		# Draw food (pulsing effect)
		pulse = Math.sin(Date.now() / 200) * 0.3 + 0.7
		@ctx.fillStyle = "rgba(255, 0, 255, #{pulse})"
		@ctx.shadowBlur = 15
		@ctx.shadowColor = '#ff00ff'
		@ctx.beginPath()
		centerX = @food.x * @gridSize + @gridSize / 2
		centerY = @food.y * @gridSize + @gridSize / 2
		@ctx.arc(centerX, centerY, @gridSize / 2 - 2, 0, Math.PI * 2)
		@ctx.fill()
		@ctx.shadowBlur = 0

		# Draw snake
		for segment, i in @snake
			if i == 0
				# Head - brighter
				@ctx.fillStyle = '#00ffff'
				@ctx.shadowBlur = 10
				@ctx.shadowColor = '#00ffff'
			else
				# Body - gradient fade
				alpha = 1 - (i / @snake.length) * 0.5
				@ctx.fillStyle = "rgba(0, 255, 200, #{alpha})"
				@ctx.shadowBlur = 5
				@ctx.shadowColor = '#00ffc8'

			@ctx.fillRect(
				segment.x * @gridSize + 1
				segment.y * @gridSize + 1
				@gridSize - 2
				@gridSize - 2
			)
		@ctx.shadowBlur = 0

		# Draw HUD
		@ctx.fillStyle = '#fff'
		@ctx.font = '16px VT323'
		@ctx.fillText("SCORE: #{@score}", 10, 20)
		@ctx.fillText("HIGH: #{@highScore}", @canvas.width - 100, 20)

		# Paused/start screen
		if @paused
			@ctx.fillStyle = 'rgba(0, 0, 0, 0.5)'
			@ctx.fillRect(0, 0, @canvas.width, @canvas.height)

			@ctx.fillStyle = '#00ffff'
			@ctx.font = '24px VT323'
			@ctx.textAlign = 'center'
			@ctx.fillText('Press a direction to start', @canvas.width / 2, @canvas.height / 2)
			@ctx.textAlign = 'left'

		# Game over screen
		if @gameOver
			@ctx.fillStyle = 'rgba(0, 0, 0, 0.8)'
			@ctx.fillRect(0, 0, @canvas.width, @canvas.height)

			@ctx.fillStyle = '#ff0000'
			@ctx.font = '36px VT323'
			@ctx.textAlign = 'center'
			@ctx.fillText('GAME OVER', @canvas.width / 2, @canvas.height / 2 - 30)

			@ctx.fillStyle = '#fff'
			@ctx.font = '24px VT323'
			@ctx.fillText("SCORE: #{@score}", @canvas.width / 2, @canvas.height / 2 + 10)

			if @score >= @highScore and @score > 0
				@ctx.fillStyle = '#ffff00'
				@ctx.fillText('NEW HIGH SCORE!', @canvas.width / 2, @canvas.height / 2 + 40)

			@ctx.fillStyle = '#fff'
			@ctx.font = '18px VT323'
			@ctx.fillText('Press ESC to exit', @canvas.width / 2, @canvas.height / 2 + 80)
			@ctx.textAlign = 'left'

	drawLoop: =>
		# Just draw the initial state while paused
		@draw()
		if @paused and not @gameOver
			requestAnimationFrame(@drawLoop)

	gameLoop: =>
		@update()
		@draw()
		@gameLoopId = setTimeout(@gameLoop, @speed) unless @gameOver
		# Keep drawing if game over so screen stays visible
		if @gameOver
			@draw()

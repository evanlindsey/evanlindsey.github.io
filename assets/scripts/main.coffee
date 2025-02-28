---
---

# Terminal class and functionality
document.addEventListener 'DOMContentLoaded', ->
	terminal = new RetroTerminal()
	terminal.initialize()

class RetroTerminal
	constructor: ->
		@terminalInput = document.getElementById('terminal-input')
		@terminalOutput = document.getElementById('terminal-output')
		@projects = []
		@commands =
			'help': @showHelp.bind(this)
			'clear': @clearTerminal.bind(this)
			'projects': @listProjects.bind(this)
			'contact': @showContact.bind(this)
			'ascii': @showAsciiArt.bind(this)
			'date': @showDate.bind(this)
			'echo': @echo.bind(this)
			'matrix': @showMatrix.bind(this)
			'invaders': @showSpaceInvaders.bind(this)
			'ls': @listCommands.bind(this)

	initialize: ->
		# Load projects from GitHub
		@loadProjects()

		# Add event listener for the terminal input
		@terminalInput.addEventListener 'keydown', (event) =>
			if event.key == 'Enter'
				command = @terminalInput.value.trim().toLowerCase()
				@handleCommand(command)
				@terminalInput.value = ''

		# Focus the input field on page load
		@terminalInput.focus()

		# Focus the input field when clicking anywhere in the terminal
		document.querySelector('.terminal').addEventListener 'click', =>
			@terminalInput.focus()

		# Show welcome message
		@printOutput "Welcome to Evan Lindsey's personal terminal.", 'welcome-msg'
		@printOutput "Type <span class=\"cmd-highlight\">help</span> to see available commands.", 'help-hint'

	loadProjects: ->
		fetch('https://api.github.com/users/evanlindsey/repos')
			.then (response) -> response.json()
			.then (data) =>
				@projects = data.map (repo) ->
					name: repo.name
					description: repo.description || 'No description available'
					url: repo.homepage || repo.html_url
					stars: repo.stargazers_count
					language: repo.language
			.catch (error) =>
				console.error 'Error fetching projects:', error
				@printOutput 'Error loading projects from GitHub.', 'error'

	handleCommand: (command) ->
		# Add the command to the output
		@printOutput "<span class=\"terminal-prompt-text\">guest@evanlindsey:~$</span> #{command}", 'command'

		# Parse the command and arguments
		args = command.split(' ')
		cmd = args[0]
		cmdArgs = args.slice(1)

		# Execute the command if it exists
		if cmd && @commands[cmd]
			@commands[cmd](cmdArgs)
		else if cmd
			@printOutput "Command not found: #{cmd}. Try <span class=\"cmd-highlight\">help</span> for a list of commands.", 'error'

	scrollToBottom: ->
		lastChild = @terminalOutput.lastElementChild
		prompt = document.querySelector('.terminal-prompt')
		if lastChild && prompt
			lastChild.scrollIntoView(false)
			prompt.scrollIntoView(false)

	printOutput: (text, className = '') ->
		output = document.createElement('div')
		output.className = className
		output.innerHTML = text
		@terminalOutput.appendChild(output)

		# Auto-scroll after adding new content
		@scrollToBottom()

	clearTerminal: ->
		@terminalOutput.innerHTML = ''

	showHelp: ->
		commands = [
			{ cmd: 'ascii', desc: 'Show ASCII art' }
			{ cmd: 'clear', desc: 'Clear the terminal screen' }
			{ cmd: 'contact', desc: 'Show contact information and social links' }
			{ cmd: 'date', desc: 'Display current date and time' }
			{ cmd: 'echo [text]', desc: 'Display the [text] in the terminal' }
			{ cmd: 'help', desc: 'Show this help message' }
			{ cmd: 'invaders', desc: 'Play Space Invaders mini-game' }
			{ cmd: 'ls', desc: 'Alias for help' }
			{ cmd: 'matrix', desc: 'Show a Matrix-like animation' }
			{ cmd: 'projects', desc: 'List my GitHub projects' }
		]

		@printOutput '<span class="section-title">Available Commands:</span>', 'help-title'

		commandList = commands.map (item) ->
			"<div class=\"help-item\"><span class=\"cmd-highlight\">#{item.cmd}</span> - #{item.desc}</div>"
		.join('')

		@printOutput commandList, 'help-content'

	listCommands: ->
		@showHelp()

	listProjects: ->
		if @projects.length == 0
			@printOutput 'Loading projects...', 'loading'
			setTimeout (=> @listProjects()), 1000
			return

		@printOutput '<span class="section-title">My GitHub Projects:</span>', 'projects-title'

		projectsList = @projects.map (project) -> 
			"""
			  <div class="project-item">
			    <div><span class="project-name"><a href="#{project.url}" target="_blank">#{project.name}</a></span> 
			    <span class="project-lang">#{project.language || 'Unknown'}</span></div>
			    <div class="project-desc">#{project.description}</div>
			  </div>
			"""
		.join('')

		@printOutput projectsList, 'projects-list'

	showContact: ->
		contactText = 
			"""
			  <span class="section-title">Contact Information:</span>
			  <div class="contact-item"><span class="contact-label">GitHub:</span> <a href="https://github.com/evanlindsey" target="_blank"><i class="fab fa-github"></i> @evanlindsey</a></div>
			  <div class="contact-item"><span class="contact-label">LinkedIn:</span> <a href="https://linkedin.com/in/evan-lindsey" target="_blank"><i class="fab fa-linkedin"></i> evan-lindsey</a></div>
			"""
		@printOutput contactText, 'contact'

	showAsciiArt: ->
		asciiArts = [
			"""
			███████╗██╗   ██╗ █████╗ ███╗   ██╗
			██╔════╝██║   ██║██╔══██╗████╗  ██║
			█████╗  ██║   ██║███████║██╔██╗ ██║
			██╔══╝  ╚██╗ ██╔╝██╔══██║██║╚██╗██║
			███████╗ ╚████╔╝ ██║  ██║██║ ╚████║
			╚══════╝  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═══╝
			██╗     ██╗███╗   ██╗██████╗ ███████╗███████╗██╗   ██╗
			██║     ██║████╗  ██║██╔══██╗██╔════╝██╔════╝╚██╗ ██╔╝
			██║     ██║██╔██╗ ██║██║  ██║███████╗█████╗   ╚████╔╝ 
			██║     ██║██║╚██╗██║██║  ██║╚════██║██╔══╝    ╚██╔╝  
			███████╗██║██║ ╚████║██████╔╝███████║███████╗   ██║   
			╚══════╝╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚══════╝   ╚═╝   
			"""
		]

		randomArt = asciiArts[Math.floor(Math.random() * asciiArts.length)]
		@printOutput "<pre class=\"ascii-art\">#{randomArt}</pre>", 'ascii'

	showDate: ->
		now = new Date()
		options = 
			weekday: 'long'
			year: 'numeric'
			month: 'long'
			day: 'numeric'
			hour: '2-digit'
			minute: '2-digit'
			second: '2-digit'

		dateTimeString = now.toLocaleDateString('en-US', options)
		@printOutput "Current date and time: #{dateTimeString}", 'date'

	echo: (args) ->
		@printOutput args.join(' '), 'echo'

	showMatrix: ->
		matrixContainer = document.createElement('div')
		matrixContainer.className = 'matrix-container'
		matrixContainer.innerHTML = '<div class="matrix-text">Matrix mode activated. Press any key to exit.</div>'
		@terminalOutput.appendChild(matrixContainer)

		# Ensure container is in the DOM before creating canvas
		requestAnimationFrame =>
			canvas = document.createElement('canvas')
			canvas.className = 'matrix-canvas'
			matrixContainer.appendChild(canvas)

			# Create Matrix effect
			ctx = canvas.getContext('2d', { alpha: false })
			canvas.width = matrixContainer.clientWidth
			canvas.height = matrixContainer.clientHeight

			characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789$%&*#@!'
			fontSize = 16
			columns = Math.floor(canvas.width / fontSize)
			drops = Array(columns).fill(1)

			matrix = =>
				# Darker fade for more visible trails
				ctx.fillStyle = 'rgba(0, 0, 0, 0.05)'
				ctx.fillRect(0, 0, canvas.width, canvas.height)

				# Bright green characters with glow
				ctx.fillStyle = '#0F0'
				ctx.shadowBlur = 8
				ctx.shadowColor = '#0F0'
				ctx.font = "bold #{fontSize}px VT323"

				for i in [0...drops.length]
					# Random character
					char = characters[Math.floor(Math.random() * characters.length)]
					x = i * fontSize
					y = drops[i] * fontSize

					# Draw character
					ctx.fillText(char, x, y)

					# Reset drop to top with random delay
					if y > canvas.height && Math.random() > 0.975
						drops[i] = 0

					drops[i]++

			# Run matrix animation faster
			matrixInterval = setInterval(matrix, 33)

			# Exit Matrix mode with any key press
			exitMatrix = =>
				clearInterval(matrixInterval)
				@terminalOutput.removeChild(matrixContainer)
				document.removeEventListener('keydown', exitMatrix)

			document.addEventListener('keydown', exitMatrix)

			# Auto-scroll after adding new content
			@scrollToBottom()

	showSpaceInvaders: ->
		gameContainer = document.createElement('div')
		gameContainer.className = 'invaders-container'
		gameContainer.innerHTML = '<div class="invaders-text">Space Invaders activated. Use ← → to move, SPACE to shoot. Press ESC to exit.</div>'
		@terminalOutput.appendChild(gameContainer)

		# Ensure container is in the DOM before creating canvas
		requestAnimationFrame =>
			canvas = document.createElement('canvas')
			canvas.className = 'invaders-canvas'
			canvas.width = 600
			canvas.height = 400
			gameContainer.appendChild(canvas)

			# Create Space Invaders game
			ctx = canvas.getContext('2d')
			
			# Game variables
			player = 
				x: canvas.width / 2 - 15
				y: canvas.height - 30
				width: 30
				height: 15
				speed: 5
				color: '#0F0'
				lives: 3
				isMovingLeft: false
				isMovingRight: false
			
			bullets = []
			enemies = []
			stars = []
			score = 0
			level = 1
			gameOver = false
			lastEnemyMove = Date.now()
			enemyDirection = 1 # 1 for right, -1 for left
			
			# Initialize stars (background)
			for i in [0...50]
				stars.push
					x: Math.random() * canvas.width
					y: Math.random() * canvas.height
					size: Math.random() * 2 + 1
					speed: Math.random() * 2 + 1
			
			# Initialize enemies
			initEnemies = ->
				enemies = []
				rows = 3 + Math.min(2, Math.floor(level / 3))
				cols = 8
				for row in [0...rows]
					for col in [0...cols]
						enemies.push
							x: col * 50 + 50
							y: row * 40 + 50
							width: 30
							height: 20
							type: row # Different enemy types based on row
							alive: true
			
			initEnemies()
			
			# Event listeners for controls
			document.addEventListener 'keydown', (e) =>
				switch e.key
					when 'ArrowLeft' then player.isMovingLeft = true
					when 'ArrowRight' then player.isMovingRight = true
					when ' ' # Space key
						bullets.push
							x: player.x + player.width / 2 - 2
							y: player.y
							width: 4
							height: 10
							speed: 7
					when 'Escape'
						exitGame()
						e.preventDefault()

			document.addEventListener 'keyup', (e) =>
				switch e.key
					when 'ArrowLeft' then player.isMovingLeft = false
					when 'ArrowRight' then player.isMovingRight = false
			
			# Draw functions
			drawPlayer = ->
				# Draw ship
				ctx.fillStyle = player.color
				ctx.fillRect(player.x, player.y, player.width, player.height)
				# Draw ship details
				ctx.fillRect(player.x + player.width/2 - 2, player.y - 5, 4, 5)
				
			drawBullets = ->
				ctx.fillStyle = '#FFF'
				for bullet in bullets
					ctx.fillRect(bullet.x, bullet.y, bullet.width, bullet.height)
			
			drawEnemies = ->
				for enemy in enemies when enemy.alive
					switch enemy.type
						when 0
							ctx.fillStyle = '#FF0000' # Red for top row
							# Draw enemy shape (type 1)
							ctx.fillRect(enemy.x, enemy.y, enemy.width, enemy.height)
							ctx.fillRect(enemy.x + 5, enemy.y - 5, enemy.width - 10, 5)
						when 1
							ctx.fillStyle = '#00FFFF' # Cyan for middle row
							# Draw enemy shape (type 2)
							ctx.fillRect(enemy.x, enemy.y, enemy.width, enemy.height)
							ctx.fillRect(enemy.x, enemy.y - 8, 10, 8)
							ctx.fillRect(enemy.x + enemy.width - 10, enemy.y - 8, 10, 8)
						else
							ctx.fillStyle = '#FFFF00' # Yellow for bottom rows
							# Draw enemy shape (type 3)
							ctx.fillRect(enemy.x, enemy.y, enemy.width, enemy.height)
							ctx.fillRect(enemy.x + 5, enemy.y + enemy.height, enemy.width - 10, 5)
			
			drawStars = ->
				ctx.fillStyle = '#FFF'
				for star in stars
					ctx.beginPath()
					ctx.arc(star.x, star.y, star.size, 0, Math.PI * 2)
					ctx.fill()
			
			drawHUD = ->
				ctx.fillStyle = '#FFF'
				ctx.font = '16px VT323'
				ctx.fillText("SCORE: #{score}", 10, 20)
				ctx.fillText("LEVEL: #{level}", canvas.width - 100, 20)
				ctx.fillText("LIVES: #{player.lives}", 10, canvas.height - 10)
				
				if gameOver
					ctx.fillStyle = 'rgba(0, 0, 0, 0.7)'
					ctx.fillRect(0, 0, canvas.width, canvas.height)
					
					ctx.fillStyle = '#FF0000'
					ctx.font = '36px VT323'
					ctx.textAlign = 'center'
					ctx.fillText('GAME OVER', canvas.width / 2, canvas.height / 2 - 20)
					
					ctx.fillStyle = '#FFF'
					ctx.font = '24px VT323'
					ctx.fillText("FINAL SCORE: #{score}", canvas.width / 2, canvas.height / 2 + 20)
					ctx.fillText('Press ESC to exit', canvas.width / 2, canvas.height / 2 + 60)
					ctx.textAlign = 'left'
			
			# Calculate enemy move delay based on level (gets faster as level increases)
			getEnemyMoveDelay = ->
				baseDelay = 800
				return Math.max(100, baseDelay - (level * 70)) # Minimum 100ms delay even at high levels
			
			# Calculate enemy sideways movement speed based on level
			getEnemySidewaysSpeed = ->
				baseSpeed = 5
				return baseSpeed + (level * 2) # Increases by 2 each level
			
			# Update game state
			updateGame = ->
				# Move the player
				if player.isMovingLeft and player.x > 0
					player.x -= player.speed
				if player.isMovingRight and player.x < canvas.width - player.width
					player.x += player.speed
				
				# Move bullets
				for bullet, i in bullets by -1
					bullet.y -= bullet.speed
					if bullet.y < 0
						bullets.splice(i, 1)
				
				# Move enemies - with dynamic speed based on level
				currentTime = Date.now()
				moveDelay = getEnemyMoveDelay()
				enemySpeed = getEnemySidewaysSpeed()
				
				if currentTime - lastEnemyMove > moveDelay
					lastEnemyMove = currentTime
					
					# Check if enemies hit the edge
					hitEdge = false
					for enemy in enemies when enemy.alive
						nextX = enemy.x + enemySpeed * enemyDirection
						if nextX <= 0 or nextX + enemy.width >= canvas.width
							hitEdge = true
							break
					
					# Change direction and move down if hit edge
					if hitEdge
						enemyDirection *= -1
						downSpeed = 15 + level * 2 # Enemies move down faster at higher levels
						for enemy in enemies when enemy.alive
							enemy.y += downSpeed
					else
						# Move enemies sideways
						for enemy in enemies when enemy.alive
							enemy.x += enemySpeed * enemyDirection
				
				# Move stars (background)
				for star in stars
					star.y += star.speed
					if star.y > canvas.height
						star.y = 0
						star.x = Math.random() * canvas.width
				
				# Check collisions
				checkCollisions()
				
				# Check end game conditions
				checkGameStatus()
			
			# Handle collisions
			checkCollisions = ->
				# Check bullet-enemy collisions
				for bullet, bi in bullets by -1
					collision = false
					for enemy, ei in enemies when enemy.alive
						if bullet.x < enemy.x + enemy.width and
						   bullet.x + bullet.width > enemy.x and
						   bullet.y < enemy.y + enemy.height and
						   bullet.y + bullet.height > enemy.y
							enemy.alive = false
							collision = true
							score += (3 - enemy.type) * 10 * level
							break
					
					if collision
						bullets.splice(bi, 1)
				
				# Check enemy-player collisions
				for enemy in enemies when enemy.alive
					if enemy.y + enemy.height >= player.y and
					   enemy.x < player.x + player.width and
					   enemy.x + enemy.width > player.x
						player.lives -= 1
						if player.lives <= 0
							gameOver = true
						# Reset enemy positions
						initEnemies() if !gameOver
						break
				
				# Check if enemies reached bottom
				for enemy in enemies when enemy.alive
					if enemy.y + enemy.height >= canvas.height - 40
						player.lives = 0
						gameOver = true
						break
			
			# Check game status
			checkGameStatus = ->
				# Check if all enemies are destroyed
				allDestroyed = true
				for enemy in enemies
					if enemy.alive
						allDestroyed = false
						break
						
				# Level up if all enemies destroyed
				if allDestroyed
					level += 1
					initEnemies()
					
					# Display level up message
					ctx.fillStyle = 'rgba(0, 0, 0, 0.7)'
					ctx.fillRect(0, 0, canvas.width, canvas.height)
					
					ctx.fillStyle = '#FFFF00'
					ctx.font = '36px VT323'
					ctx.textAlign = 'center'
					ctx.fillText("LEVEL #{level}!", canvas.width / 2, canvas.height / 2 - 20)
					ctx.textAlign = 'left'
			
			# Main game loop
			gameLoop = ->
				ctx.fillStyle = 'rgba(0, 0, 0, 0.2)'
				ctx.fillRect(0, 0, canvas.width, canvas.height)
				
				unless gameOver
					updateGame()
				
				drawStars()
				drawEnemies()
				drawBullets()
				drawPlayer() unless gameOver
				drawHUD()
				
				gameAnimationId = requestAnimationFrame(gameLoop)
			
			# Start the game
			gameAnimationId = requestAnimationFrame(gameLoop)
			
			# Exit the game
			exitGame = =>
				cancelAnimationFrame(gameAnimationId)
				document.removeEventListener('keydown', exitGame)
				@terminalOutput.removeChild(gameContainer)
				
				# Show score when exiting
				@printOutput "Space Invaders game ended. Final score: #{score}, Level: #{level}", 'game-result'

			# Auto-scroll after adding new content
			@scrollToBottom()

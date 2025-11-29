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
			'snake': @showSnake.bind(this)
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

		# Scroll terminal input into view on mobile after a short delay
		setTimeout =>
			@terminalInput.scrollIntoView({ behavior: 'smooth', block: 'end' })
		, 100

	loadProjects: ->
		CACHE_KEY = 'github_projects_cache'
		CACHE_TTL = 1000 * 60 * 30 # 30 minutes

		# Check for cached data
		cached = localStorage.getItem(CACHE_KEY)
		if cached
			try
				{ data, timestamp } = JSON.parse(cached)
				if Date.now() - timestamp < CACHE_TTL
					@projects = data
					return
			catch e
				localStorage.removeItem(CACHE_KEY)

		# Fetch fresh data
		fetch('https://api.github.com/users/evanlindsey/repos')
			.then (response) -> response.json()
			.then (data) =>
				@projects = data.map (repo) ->
					name: repo.name
					description: repo.description || 'No description available'
					url: repo.homepage || repo.html_url
					stars: repo.stargazers_count
					language: repo.language
				# Cache the results
				localStorage.setItem CACHE_KEY, JSON.stringify
					data: @projects
					timestamp: Date.now()
			.catch (error) =>
				console.error 'Error fetching projects:', error
				@printOutput 'Error loading projects from GitHub.', 'error'

	handleCommand: (command) ->
		# Add the command to the output (escape user input to prevent XSS)
		escapedCommand = @escapeHtml(command)
		@printOutput "<span class=\"terminal-prompt-text\">guest@evanlindsey:~$</span> #{escapedCommand}", 'command'

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

	# Escape HTML to prevent XSS
	escapeHtml: (text) ->
		div = document.createElement('div')
		div.textContent = text
		div.innerHTML

	printOutput: (text, className = '', isHtml = true) ->
		output = document.createElement('div')
		output.className = className
		if isHtml
			output.innerHTML = text
		else
			output.textContent = text
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
			{ cmd: 'snake', desc: 'Play Snake mini-game' }
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
		# Use textContent to prevent XSS
		@printOutput args.join(' '), 'echo', false

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
		gameContainer.innerHTML = '<div class="invaders-text">Space Invaders activated. Use ← → or A/D to move, SPACE or W to shoot. Press ESC to exit.</div>'
		@terminalOutput.appendChild(gameContainer)

		# Ensure container is in the DOM before creating canvas
		requestAnimationFrame =>
			canvas = document.createElement('canvas')
			canvas.className = 'invaders-canvas'
			gameContainer.appendChild(canvas)

			# Create and start the game
			game = new SpaceInvaders canvas, (score, level) =>
				@terminalOutput.removeChild(gameContainer)
				@printOutput "Space Invaders game ended. Final score: #{score}, Level: #{level}", 'game-result'

			game.start()

			# Auto-scroll after adding new content
			@scrollToBottom()

	showSnake: ->
		gameContainer = document.createElement('div')
		gameContainer.className = 'snake-container'
		gameContainer.innerHTML = '<div class="snake-text">Snake activated. Use ← → ↑ ↓ or WASD to move. Press ESC to exit.</div>'
		@terminalOutput.appendChild(gameContainer)

		# Ensure container is in the DOM before creating canvas
		requestAnimationFrame =>
			canvas = document.createElement('canvas')
			canvas.className = 'snake-canvas'
			gameContainer.appendChild(canvas)

			# Create and start the game
			game = new SnakeGame canvas, (score, highScore) =>
				@terminalOutput.removeChild(gameContainer)
				@printOutput "Snake game ended. Score: #{score} | High Score: #{highScore}", 'game-result'

			game.start()

			# Auto-scroll after adding new content
			@scrollToBottom()

fs = require 'fs'
path = require 'path'

$ = require 'jquery'
season = require 'season'

StyleManager = require './style-manager'
DashboardView = require './dashboard-view'
CardView = require './card-view'
CardManager = require './card-manager'
DeckManager = require './deck-manager'
GameManager = require './game-manager'
AlertsView = require './alerts-view'

{Emitter} = require 'emissary'

module.exports = class HearthDash
	Emitter.includeInto this
	constructor: ->
		@rootPath = path.resolve path.join __dirname, '..', '..'
		@dataPath = @getDataPath()
		@nodePath = path.resolve path.join __dirname, '..', '..', (if process.platform is 'darwin' then 'node' else 'node.exe')

		unless fs.existsSync(@dataPath)
			fs.mkdirSync @dataPath

		@configPath = path.join @dataPath, 'config.cson'

		if fs.existsSync @configPath
			@config = season.readFileSync @configPath
		else
			@config = {}

	saveConfig: ->
		season.writeFileSync @configPath, @config

	setConfig: (key, value) ->
		@config[key] = value
		@saveConfig()
		@emit 'config-changed:' + key, value

	initialize: ->
		@cardManager = new CardManager this
		@deckManager = new DeckManager this

		@dashboardView = new DashboardView
		@dashboardView.deckEditorView.attachEvents()
		@dashboardView.append @alertsView = new AlertsView

		@styleManager = new StyleManager this

		@styleManager.loadLess path.join @rootPath, 'less', 'dash.less'

		@gameManager = new GameManager this

		$('body').append(@dashboardView)

	getDataPath: ->
		switch process.platform
			when 'darwin'
				path.join process.env.HOME, 'Library', 'Application Support', 'Hearthdash'
			else
				path.join process.env.HOME, '.hearthdash'

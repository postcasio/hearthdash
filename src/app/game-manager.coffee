PacketInterface = require './packet-interface'
_ = require 'underscore'

zones =
	INVALID: 0
	PLAY: 1
	DECK: 2
	HAND: 3
	GRAVEYARD: 4
	REMOVEDFROMGAME: 5
	SETASIDE: 6
	SECRET: 7

cardTypes =
	INVALID: 0
	GAME: 1
	PLAYER: 2
	HERO: 3
	MINION: 4
	ABILITY: 5
	ENCHANTMENT: 6
	WEAPON: 7
	ITEM: 8
	TOKEN: 9
	HERO_POWER: 10

module.exports = class GameManager
	entities: null
	finishedSetup: false
	turns: 0
	messageBuffer: null
	foundPlayers: false
	entityControllers = null

	constructor: (@dash) ->
		@packetInterface = new PacketInterface

		@packetInterface.on 'game-start', (message) => @onGameStart message
		@packetInterface.on 'tag-change', (message) => @onTagChange message
		@packetInterface.on 'show-entity', (message) => @onShowEntity message
		@packetInterface.on 'full-entity', (message) => @onFullEntity message
		@packetInterface.on 'create-game', (message) => @onCreateGame message
		@packetInterface.on 'ready', (message) => @onReady message

		@packetInterface.watch()

		@messageBuffer = []
		@entityControllers = []
		@unifiedHistory = dash.config.unifiedHistory
		@setHistoryTitle(@unifiedHistory)
		dash.on 'config-changed:unifiedHistory', @setHistoryTitle

	setHistoryTitle: (value) ->
		if value
			dash.dashboardView.gameView.historyView.setName 'History'
		else
			dash.dashboardView.gameView.historyView.setName 'Opponent\'s History'

	reset: ->
		@messageBuffer = []
		@entities = {}
		@entityControllers = {}
		@gameView = @dash.dashboardView.gameView

		deck = @dash.dashboardView.deckSelector.getSelectedDeck()

		if deck and deck isnt 'new'
			@gameView.playerDeckView.setDeck deck
		else
			@gameView.playerDeckView.empty()

		@gameView.playerHandView.empty()
		@gameView.opponentDeckView.empty()
		@gameView.opponentHandView.empty()
		@gameView.historyView.empty()

		@finishedSetup = false
		@turns = 0
		@foundPlayers = false



	onGameStart: (message) ->
		dash.alertsView.createAlert
			heading: 'Game'
			text: 'New game has started.'

		@reset()

	onTagChange: (message) ->
		unless @foundPlayers
			@messageBuffer.push onTagChange: message

			return

		if message.tag == 'TURN_START'
			if @gameView.opponentHandView.cardCount is 5 and not @finishedSetup
				@gameView.opponentHandView.removeCard ''
				@gameView.opponentHandView.addCard 'GAME_005'

			@finishedSetup = true

			@turns++
			@gameView.historyView.setTurn Math.floor(@turns / 2)

		entity = @getEntity message, false

		if message.tag == 'ZONE'
			if entity.getController() == @opponentControllerId
				switch entity.getZone()
					when zones.DECK
						size = @gameView.opponentDeckView.removeCard entity.name
					when zones.HAND
						size = @gameView.opponentHandView.removeCard entity.name
			else if entity.getController() == @playerControllerId
				switch entity.getZone()
					when zones.DECK
						size = @gameView.playerDeckView.removeCard entity.name
					when zones.HAND
						size = @gameView.playerHandView.removeCard entity.name

			entity.setTag message.tag, message.value

			if entity.getController() == @opponentControllerId
				switch entity.getZone()
					when zones.DECK
						size = @gameView.opponentDeckView.addCard entity.name
					when zones.HAND
						size = @gameView.opponentHandView.addCard entity.name
					when zones.PLAY
						if entity.getCardType() in [cardTypes.MINION, cardTypes.ABILITY, cardTypes.WEAPON]
							size = @gameView.historyView.addCard entity.name, true, 'opponent'

			else if entity.getController() == @playerControllerId
				switch entity.getZone()
					when zones.DECK
						size = @gameView.playerDeckView.addCard entity.name
					when zones.HAND
						size = @gameView.playerHandView.addCard entity.name
					when zones.PLAY
						if @unifiedHistory and entity.getCardType() in [cardTypes.MINION, cardTypes.ABILITY, cardTypes.WEAPON]
							size = @gameView.historyView.addCard entity.name, true, 'player'
		else
			entity.update message


	onShowEntity: (message) ->

		unless @foundPlayers
			@messageBuffer.push onShowEntity: message

			if message.name and message.tags.ZONE is zones.HAND

				@playerControllerId = @entityControllers[message.id]
				@opponentControllerId = if @playerControllerId == 1 then 2 else 1
				@foundPlayers = true

				for message in @messageBuffer
					for type, msg of message
						@[type] msg

				@messageBuffer = []

			return

		entity = @getEntity message, false

		if entity.getController() == @playerControllerId
			switch entity.getZone()
				when zones.DECK
					size = @gameView.playerDeckView.removeCard message.name
				when zones.HAND
					size = @gameView.playerHandView.removeCard entity.name
		else if entity.getController() == @opponentControllerId
			switch entity.getZone()
				when zones.DECK
					size = @gameView.opponentDeckView.removeCard message.name
				when zones.HAND
					if message.name == 'GAME_005'
						size = @gameView.opponentHandView.removeCard message.name
					else
						size = @gameView.opponentHandView.removeCard entity.name

		entity.update message

		if entity.getController() == @playerControllerId
			switch entity.getZone()
				when zones.DECK
					size = @gameView.playerDeckView.addCard entity.name
				when zones.HAND
					size = @gameView.playerHandView.addCard entity.name
		else if entity.getController() == @opponentControllerId
			switch entity.getZone()
				when zones.DECK
					size = @gameView.opponentDeckView.addCard entity.name
				when zones.HAND
					size = @gameView.opponentHandView.addCard entity.name
				when zones.PLAY
					if entity.getCardType() in [cardTypes.MINION, cardTypes.ABILITY, cardTypes.WEAPON]
						size = @gameView.historyView.addCard entity.name, true, 'opponent'



	onFullEntity: (message) ->

		unless @foundPlayers
			if message.tags.CONTROLLER
				@entityControllers[message.id] = message.tags.CONTROLLER
			@messageBuffer.push onFullEntity: message

			return


		entity = @getEntity message

		if entity.getController() == @playerControllerId
			switch entity.getZone()
				when zones.DECK
					if @finishedSetup
						size = @gameView.playerDeckView.addCard entity.name
				when zones.HAND
					size = @gameView.playerHandView.addCard entity.name

		if entity.getController() == @opponentControllerId
			switch entity.getZone()
				when zones.DECK
					size = @gameView.opponentDeckView.addCard entity.name
				when zones.HAND
					size = @gameView.opponentHandView.addCard entity.name

	onCreateGame: (message) ->

	getEntity: (entity, update=true) ->
		if @entities[entity.id]
			if update
				@entities[entity.id].update entity
		else
			@entities[entity.id] = new Entity entity

		@entities[entity.id]

	onReady: (message) ->
		dash.dashboardView.gameView.historyView.setTurn(1)


class Entity
	id: 0
	name: ''
	tags: {}

	constructor: (props) ->
		@id = props.id
		@name = props.name if props.name
		@tags = props.tags if props.tags

	update: (props) ->
		@name = props.name if props.name
		_.extend @tags, props.tags if props.tags

	setTag: (name, value) ->
		@tags[name] = value

	getZone: -> @tags.ZONE
	getController: -> @tags.CONTROLLER
	getCardType: -> @tags.CARDTYPE

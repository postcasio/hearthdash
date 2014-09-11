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

module.exports = class GameManager
	entities: {}
	finishedSetup: false
	turns: 0

	constructor: (@dash) ->
		@packetInterface = new PacketInterface

		@packetInterface.on 'game-start', (message) => @onGameStart message
		@packetInterface.on 'tag-change', (message) => @onTagChange message
		@packetInterface.on 'show-entity', (message) => @onShowEntity message
		@packetInterface.on 'full-entity', (message) => @onFullEntity message
		@packetInterface.on 'create-game', (message) => @onCreateGame message
		@packetInterface.on 'ready', (message) => @onReady message

		@packetInterface.watch()

	reset: ->
		@entities = {}
		@gameView = @dash.dashboardView.gameView

		deck = @dash.dashboardView.deckSelector.getSelectedDeck()

		if deck and deck isnt 'new'
			@gameView.playerDeckView.setDeck deck
		else
			@gameView.playerDeckView.empty()

		@gameView.playerHandView.empty()
		@gameView.opponentDeckView.empty()
		@gameView.opponentHandView.empty()
		@gameView.opponentHistoryView.empty()

		@finishedSetup = false
		@turns = 0



	onGameStart: (message) ->
		dash.alertsView.createAlert
			heading: 'Game'
			text: 'New game has started.'

		@reset()

	onTagChange: (message) ->
		if message.tag == 'TURN_START'
			if @gameView.opponentHandView.cardCount is 5 and not @finishedSetup
				@gameView.opponentHandView.removeCard ''
				@gameView.opponentHandView.addCard 'GAME_005'

			@finishedSetup = true

			@turns++
			@gameView.opponentHistoryView.setTurn Math.floor(@turns / 2)

		entity = @getEntity message, false

		if message.tag == 'ZONE'
			if entity.getController() == 2
				switch entity.getZone()
					when zones.DECK
						size = @gameView.opponentDeckView.removeCard entity.name
					when zones.HAND
						size = @gameView.opponentHandView.removeCard entity.name
			else if entity.getController() == 1
				switch entity.getZone()
					when zones.DECK
						size = @gameView.playerDeckView.removeCard entity.name
					when zones.HAND
						size = @gameView.playerHandView.removeCard entity.name

			entity.setTag message.tag, message.value

			if entity.getController() == 2
				switch entity.getZone()
					when zones.DECK
						size = @gameView.opponentDeckView.addCard entity.name
					when zones.HAND
						size = @gameView.opponentHandView.addCard entity.name
					when zones.PLAY
						size = @gameView.opponentHistoryView.addCard entity.name
			else if entity.getController() == 1
				switch entity.getZone()
					when zones.DECK
						size = @gameView.playerDeckView.addCard entity.name
					when zones.HAND
						size = @gameView.playerHandView.addCard entity.name
		else
			entity.update message


	onShowEntity: (message) ->
		entity = @getEntity message, false

		if entity.getController() == 1
			switch entity.getZone()
				when zones.DECK
					size = @gameView.playerDeckView.removeCard message.name
				when zones.HAND
					size = @gameView.playerHandView.removeCard entity.name
		else if entity.getController() == 2
			switch entity.getZone()
				when zones.DECK
					size = @gameView.opponentDeckView.removeCard message.name
				when zones.HAND
					if message.name == 'GAME_005'
						size = @gameView.opponentHandView.removeCard message.name
					else
						size = @gameView.opponentHandView.removeCard entity.name

		entity.update message

		if entity.getController() == 1
			switch entity.getZone()
				when zones.DECK
					size = @gameView.playerDeckView.addCard entity.name
				when zones.HAND
					size = @gameView.playerHandView.addCard entity.name
		else if entity.getController() == 2
			switch entity.getZone()
				when zones.DECK
					size = @gameView.opponentDeckView.addCard entity.name
				when zones.HAND
					size = @gameView.opponentHandView.addCard entity.name
				when zones.PLAY
					size = @gameView.opponentHistoryView.addCard entity.name



	onFullEntity: (message) ->
		entity = @getEntity message

		if entity.getController() == 1
			switch entity.getZone()
				when zones.DECK
					if @finishedSetup
						size = @gameView.playerDeckView.addCard entity.name
				when zones.HAND
					size = @gameView.playerHandView.addCard entity.name

		if entity.getController() == 2
			switch entity.getZone()
				when zones.DECK
					size = @gameView.opponentDeckView.addCard entity.name
				when zones.HAND
					size = @gameView.opponentHandView.addCard entity.name
				when zones.PLAY
					if @finishedSetup
						size = @gameView.opponentHistoryView.addCard entity.name

	onCreateGame: (message) ->

	getEntity: (entity, update=true) ->
		if @entities[entity.id]
			if update
				@entities[entity.id].update entity
		else
			@entities[entity.id] = new Entity entity

		@entities[entity.id]

	onReady: (message) ->
		dash.dashboardView.gameView.opponentHistoryView.setTurn(1)


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

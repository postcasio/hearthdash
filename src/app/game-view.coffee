{View} = require 'space-pen'
DeckView = require './deck-view'

module.exports = class GameView extends View
	@content: (params) ->
		@div class: 'view game-view', =>
			@div class: 'player', =>
				@subview 'playerDeckView', new DeckView name: 'Your Deck', keepCards: true, sorted: true
				@subview 'playerHandView', new DeckView name: 'Your Hand'
			@div class: 'opponent', =>
				@subview 'opponentHistoryView', new DeckView name: 'Opponent\'s History', trackTurns: true
				@subview 'opponentHandView', new DeckView name: 'Opponent\'s Hand'
				@subview 'opponentDeckView', new DeckView name: 'Opponent\'s Deck', keepCards: true

	getTitle: -> 'Game'

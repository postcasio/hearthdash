{View, $$, $} = require 'space-pen'

CardView = require './card-view'
_ = require 'underscore'

module.exports = class DeckView extends View
	@content: (params) ->
		@div class: 'deck-view', =>
			@div class: 'deck-name', outlet: 'deckName', params.name
			@div class: 'deck-list', outlet: 'deckList'

	cards: null
	cardCount: 0
	turn: 0
	defaults:
		keepCards: false
		trackTurns: false
		sorted: false

	initialize: (params) ->
		@params = _.extend {}, @defaults, params
		@cards = {}
		@cardCount = 0
		@turn = 0
		@currentTurn = null
		if @params.trackTurns
			@addClass 'track-turns'

	setTurn: (turn) ->
		if turn isnt @turn
			@turn = turn

			@deckList.prepend @currentTurn = $$ -> @div class: 'deck-turn', 'data-turn': turn
			@currentTurn.hide()

	addCard: (card, animate=true) ->
		@cardCount++
		cardView = new CardView id: card
		existed = false
		if @cards[card]
			existed = true
		else
			@cards[card] = cardView

		if @params.trackTurns
			@currentTurn.show()
			@currentTurn.prepend cardView
			cardView.slideDown() if animate
		else
			if existed
				@cards[card].increment()
			else
				if @params.sorted
					insertionPoint = _.find @deckList.children(), (b) ->
						[a, b] = [cardView, $(b).view()]
						ac = parseInt a.card.cost, 10
						bc = parseInt b.card.cost, 10

						if bc > ac
							return true

						else if bc == ac
							an = a.card.name
							bn = b.card.name
							if bn > an
								return true

						return false

					if insertionPoint
						$(insertionPoint).before cardView
					else
						@deckList.append cardView
				else
					@deckList.append cardView

		if animate
			cardView.slideDown()

		@update()

		@cardCount

	removeCard: (card) ->
		@cardCount--
		if @cards[card]
			@cards[card].decrement()
			unless @params.keepCards or @cards[card].count
				@cards[card].slideUp -> @remove()
				delete @cards[card]


		@update()

		@cardCount

	getCardList: ->
		cards = []
		for id, card of @cards
			for i in [0...card.count]
				cards.push id

		cards

	setDeck: (deck) ->
		@empty()

		for card in deck.cards
			@addCard card, false

		@update()

	empty: ->
		@deckList.empty()
		@cards = {}
		@cardCount = 0

		@update()

	update: ->
		@deckName.text @params.name + ' (' + @cardCount + ')'

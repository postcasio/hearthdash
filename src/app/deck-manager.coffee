fs = require 'fs'
season = require 'season'
path = require 'path'
_ = require 'underscore'

module.exports = class DeckManager
	constructor: (@dash) ->
		@deckPath = path.join(@dash.dataPath, 'decks.cson')
		if fs.existsSync @deckPath
			@decks = season.readFileSync @deckPath
		else
			@decks = {constructed: []}
	save: ->
		season.writeFileSync(@deckPath, @decks)

	getConstructedDecks: ->
		@decks.constructed

	saveConstructedDeck: (deck) ->
		for savedDeck in @decks.constructed
			if savedDeck.name == deck.name
				savedDeck.cards = deck.cards
				savedDeck.class = deck.class
				season.writeFileSync(path.join(@dash.dataPath, 'decks.cson'), @decks)

				dash.dashboardView.deckSelector.updateDeck deck
				return

		@decks.constructed.push deck

		@save()

		dash.dashboardView.deckSelector.addDeck deck

	deleteConstructedDeck: (deck) ->
		dash.dashboardView.deckSelector.removeDeck deck

		@decks.constructed = _.reject @decks.constructed, (candidate) ->
			candidate.name is deck.name

		@save()

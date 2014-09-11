{View} = require 'space-pen'
GameView = require './game-view'
DeckSelectorView = require './deck-selector-view'
DeckEditorView = require './deck-editor-view'
CardView = require './card-view'

module.exports = class DashboardView extends View
	@content: ->
		@div class: 'dashboard-view', =>
			@div class: 'dashboard-header', =>
				@button class: 'active', outlet: 'gameButton', =>
					@i class: 'fa fa-tachometer'
				@button outlet: 'decksButton', =>
					@i class: 'fa fa-list'
				@button outlet: 'settingsButton', =>
					@i class: 'fa fa-cog'

				@subview 'deckSelector', new DeckSelectorView()

				@h1 =>
					@span 'Hearthdash'
					@span class: 'subtitle', outlet: 'subTitle', 'Game'
			@div class: 'content', =>
				@subview 'gameView', new GameView()
				@subview 'deckEditorView', new DeckEditorView()

	setSubtitle: (text) ->
		@subTitle.text text

	initialize: ->
		@deckEditorView.hide()

		@gameButton.on 'click', (e) =>
			@decksButton.removeClass 'active'
			@gameButton.addClass 'active'
			@deckEditorView.hide()
			@gameView.show()
			@setSubtitle 'Game'
			e.preventDefault()

		@decksButton.on 'click', (e) =>
			@gameButton.removeClass 'active'
			@decksButton.addClass 'active'
			@gameView.hide()
			@deckEditorView.show()
			@setSubtitle 'Decks'
			e.preventDefault()

		@deckSelector.on 'new-deck', =>
			@gameView.hide()
			@deckEditorView.show()

		@deckSelector.on 'deck-changed', (event) =>
			if event.deck and event.deck isnt 'new'
				@gameView.playerDeckView.setDeck event.deck

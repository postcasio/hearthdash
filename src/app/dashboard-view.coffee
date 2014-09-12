{View, $} = require 'space-pen'
GameView = require './game-view'
DeckSelectorView = require './deck-selector-view'
DeckEditorView = require './deck-editor-view'
CardView = require './card-view'
SettingsView = require './settings-view'

module.exports = class DashboardView extends View
	@content: ->
		@div class: 'dashboard-view', =>
			@div class: 'dashboard-header', =>
				@button class: 'active', outlet: 'gameButton', 'data-view': 'gameView', =>
					@i class: 'fa fa-tachometer'
				@button outlet: 'deckEditorButton', 'data-view': 'deckEditorView', =>
					@i class: 'fa fa-list'
				@button outlet: 'settingsButton', 'data-view': 'settingsView', =>
					@i class: 'fa fa-cog'

				@subview 'deckSelector', new DeckSelectorView()

				@h1 class: 'title', outlet: 'title', 'Game'
			@div class: 'content', =>
				@subview 'gameView', new GameView()
				@subview 'deckEditorView', new DeckEditorView()
				@subview 'settingsView', new SettingsView()

	setTitle: (text) ->
		@title.text text

	initialize: ->
		@deckEditorView.hide()
		@settingsView.hide()
		@css 'display', 'none'

		@on 'click', '.dashboard-header button', (e) =>
			@find('.dashboard-header button').removeClass 'active'
			@find('.view').hide()
			button = $(e.target).closest('button')
			view = button.attr 'data-view'
			@[view].show()
			@setTitle @[view].getTitle()
			button.addClass 'active'


		@deckSelector.on 'new-deck', =>
			@gameView.hide()
			@deckEditorView.show()

		@deckSelector.on 'deck-changed', (event) =>
			if event.deck and event.deck isnt 'new'
				@gameView.playerDeckView.setDeck event.deck

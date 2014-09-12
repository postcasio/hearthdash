{View, $} = require 'space-pen'
DeckView = require './deck-view'
debounce = require 'debounce'

module.exports = class DeckEditorView extends View
	@content: (params) ->
		@div class: 'deck-editor-view view', =>
			@div class: 'deck-name-box', =>
				@input outlet: 'deckName', placeholder: 'Name', class: 'name-box'
				@select outlet: 'deckClass', class: 'class-select', =>
					for key, name of dash.cardManager.classes
						@option value: key, name
				@div class: 'button-group', =>
					@button outlet: 'deleteButton', class: 'delete', 'Delete'
					@button outlet: 'saveButton', class: 'save', 'Save'
			@div class: 'deck', =>
				@subview 'playerDeckView', new DeckView name: 'Deck', sorted: true
			@div class: 'search', =>
				@input outlet: 'search', placeholder: 'Search', class: 'search-box'
				@subview 'searchResults', new DeckView name: 'Search Results'

	getTitle: -> 'Decks'

	attachEvents: ->
		dash.dashboardView.deckSelector.on 'deck-changed', (event) =>
			if event.deck and event.deck isnt 'new'
				@playerDeckView.setDeck event.deck
				@deckName.val event.deck.name
				@deckClass.val event.deck.class

		dash.dashboardView.deckSelector.on 'new-deck', (event) =>
			@playerDeckView.empty()
			@deckName.val ''

		previous = ''

		search = =>
			val = @search.val()
			if val != previous
				@searchResults.setDeck
					name: 'Search Results'
					cards: dash.cardManager.search val, @deckClass.val()
				previous = val

		@playerDeckView.on 'click', '.card-view', (e) =>
			@playerDeckView.removeCard $(e.target).view().card.id
			@playerDeckView.update()

		@searchResults.on 'click', '.card-view', (e) =>
			@playerDeckView.addCard $(e.target).view().card.id
			@playerDeckView.update()


		@search.on 'keydown', debounce search, 200

		deck = dash.dashboardView.deckSelector.getSelectedDeck()

		if deck is 'new'
			@playerDeckView.empty()
			@deckName.val ''
		else
			@playerDeckView.setDeck deck
			@deckName.val deck.name
			@deckClass.val deck.class

		@saveButton.on 'click', =>
			dash.deckManager.saveConstructedDeck {
				name: @deckName.val()
				cards: @playerDeckView.getCardList()
				class: @deckClass.val()
			}

		@deleteButton.on 'click', =>
			name = @deckName.val()
			cards = @playerDeckView.getCardList()
			klass = @deckClass.val()

			dash.deckManager.deleteConstructedDeck dash.dashboardView.deckSelector.getSelectedDeck()

			dash.alertsView.createAlert
				heading: 'Deck deleted'
				text: "#{name} has been deleted."
				timeout: 8000
				undo: ->
					dash.deckManager.saveConstructedDeck {
						name: name
						cards: cards
						class: klass
					}

					dash.alertsView.createAlert
						heading: 'Deck restored'
						text: "#{name} has been restored."

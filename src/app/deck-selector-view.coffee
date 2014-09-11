{View, $} = require 'space-pen'
{Emitter} = require 'emissary'

module.exports = class DeckSelectorView extends View
	Emitter.includeInto this

	@content: ->
		@div class: 'deck-selector-view', =>
			@select outlet: 'deckList'

	initialize: ->
		@decks = dash.deckManager.getConstructedDecks()

		for deck, index in @decks
			@deckList.append $ '<option>',
				value: index
				text: deck.name + ' (' + dash.cardManager.classes[deck.class] + ')'
				'data-name': deck.name

		if not @decks.length
			@deckList.append $ '<option>',
				value: ''
				text: 'No decks'

		@newOption = $ '<option>',
			value: 'new'
			text: 'New...'

		@deckList.append @newOption

		@deckList.on 'change', =>
			if @deckList.val() is 'new'
				@emit 'new-deck'
			else
				deck = @decks[@deckList.val()]
				@emit 'deck-changed', deck: deck

	getSelectedDeck: ->
		@decks[@deckList.val()] ? 'new'

	addDeck: (deck) ->
		index = @decks.length
		@decks.push deck

		@newOption.before $ '<option>',
			value: index
			text: deck.name + ' (' + dash.cardManager.classes[deck.class] + ')'
			'data-name': deck.name

		@find('[data-no-decks]').remove()

		@deckList.val index

		@deckList.change()

	updateDeck: (deck) ->
		for opt in @find 'option'
			opt = $(opt)
			if opt.attr('data-name') == deck.name
				opt.text deck.name + ' (' + dash.cardManager.classes[deck.class] + ')'

	removeDeck: (deck) ->
		for opt in @find 'option'
			opt = $(opt)
			if opt.attr('data-name') == deck.name
				opt.remove()

		if @find('option').length == 1
			@deckList.prepend $ '<option>',
				value: ''
				text: 'No decks'
				'data-no-decks': true
		@deckList.change()

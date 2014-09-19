{View, $} = require 'space-pen'


rarity =
	1: 'Basic'
	2: 'Common'
	3: 'Rare'
	4: 'Epic'
	5: 'Legendary'

module.exports = class CardView extends View
	@content: (params) ->
		@div class: 'card-view', =>
			@div class: 'card-image', outlet: 'cardImage', =>
				@div class: 'fade'
			@div class: 'card-cost', outlet: 'cardCost'
			@div class: 'card-name', outlet: 'cardName'
			@div class: 'card-count', outlet: 'cardCount'
			@div class: 'card-description', =>
				@span outlet: 'cardDescription'
				@div class: 'card-stats', outlet: 'cardStats'


	card: null
	id: null
	art: null

	initialize: (params) ->
		@id = params.id
		if @id
			@card = dash.cardManager.find(@id)
		else
			@card =
				name: 'Unknown'
				id: false

		@count = 1

	afterAttach: (params) ->

		deckView = @closest '.deck-view'

		@find('.card-description').on 'transitionend', (e) =>
			index = deckView.find('.card-view').index(this)
			cards = ($(e.target).height() - 1) / @height()
			@blurredCards = deckView.find('.card-view:gt(' + index + ')').slice(0, cards)
			@blurredCards.addClass 'blur'

		@on 'mouseleave', =>
			if @blurredCards
				@blurredCards.removeClass 'blur'
		@update()

	update: ->
		if @card
			if @card.id
				@cardCost.text @card.cost ? 0

			if @card.rarity is '5' and @count <= 1
				@cardCount.html '&#9733;'
			else
				@cardCount.text @count

			if @card.text
				@cardDescription.html @card.text.replace(/\$(\d+)/, "$1").replace('\\n', "<br>");

			@cardName.text @card.name

			stats = []

			if @card.health
				stats.push "<div class=\"atk-health\">#{@card.atk}/#{@card.health}</div>"

			if rarity[@card.rarity]
				stats.push "<div class=\"rarity rarity-#{rarity[@card.rarity].toLowerCase()}\">#{rarity[@card.rarity]}</div>"

			@cardStats.html stats.join ""

		if @id and not @art
			@art = true
			dash.cardManager.getArtUrl @id, (url) =>
				@art = url
				if url
					@cardImage.css 'background-image': "url(\"" + url + "\")"
					@cardImage.fadeIn()

		if @count == 0
			@addClass 'used'
		else
			@removeClass 'used'

		if @card
			@attr
				'data-id': @card.id
				'data-name': @card.name
				'data-cost': @card.cost
		else
			@attr
				'data-id': ''
				'data-name': 'Unknown'
				'data-cost': ''

	remove: ->
		if @blurredCards
			@blurredCards.removeClass 'blur'
		super

	increment: ->
		@count++
		@update()

	decrement: ->
		@count--
		@update()

{View} = require 'space-pen'
$ = require 'jquery'

module.exports = class CardView extends View
	@content: (params) ->
		@div class: 'card-view', =>
			@div class: 'card-image', outlet: 'cardImage', =>
				@div class: 'fade'
			@div class: 'card-cost', outlet: 'cardCost'
			@div class: 'card-name', outlet: 'cardName'
			@div class: 'card-count', outlet: 'cardCount'

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

		@update()

	update: ->
		if @card
			if @card.id
				@cardCost.text @card.cost ? 0

			if @card.rarity is '5' and @count <= 1
				@cardCount.html '&#9733;'
			else
				@cardCount.text @count

			@cardName.text @card.name

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

	increment: ->
		@count++
		@update()

	decrement: ->
		@count--
		@update()

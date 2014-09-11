_ = require 'underscore'
{View} = require 'space-pen'
module.exports = class Alert extends View
	@content: (params) ->
		@div class: 'alert', =>
			if params.undo
				@button class: 'alert-undo', click: 'undoClicked', 'Undo'

			if params.heading
				@div class: 'alert-heading', params.heading

			@div class: 'alert-text' + (if params.class then ' ' + params.class else ''), =>
				@text params.text

	defaults:
		text: 'Alert text'
		heading: false
		undo: false
		timeout: 4000

	constructor: (params) ->
		@slideDown()

		@options = _.extend {}, @defaults, params
		super @options, Array::slice.call arguments, 1

		setTimeout (=> @slideUp(-> @remove())), @options.timeout

	undoClicked: ->
		@options.undo 'Undo'

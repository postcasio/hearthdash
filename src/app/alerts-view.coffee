{$$, View} = require 'space-pen'
Alert = require './alert'

module.exports = class AlertsView extends View
	@content: ->
		@div class: 'alert-panel'

	createAlert: (params) ->
		alert = new Alert params
		@append alert

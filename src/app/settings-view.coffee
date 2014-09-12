{View, $, $$} = require 'space-pen'
_ = require 'underscore'
{spawn} = require 'child_process'
path = require 'path'
module.exports = class DeckEditorView extends View
	@content: (params) ->
		@div class: 'settings-view view', =>
			@div class: 'setting', =>
				@label for: 'networkInterface', class: 'setting-name', 'Network interface'
				@select
					outlet: 'networkInterface'
					name: 'networkInterface'
					id: 'networkInterface'
					class: 'config-field'

	getTitle: -> 'Settings'

	initialize: ->

		capturePath = path.resolve path.join __dirname, '..', '..', 'capture'
		@proc = spawn '/usr/local/bin/coffee', [path.join(capturePath, 'src', 'capture.coffee'), '--list-devices'],
			cwd: capturePath
		buffer = ''

		formatDeviceName = (device) ->
			addresses = _.map device.addresses, (addr) -> addr.addr
			name = "#{device.name}"

			if addresses.length
				name += " (#{addresses.join ', '})"

			name

		@proc.stdout.on 'data', (data) ->
			buffer += data

		@proc.stdout.on 'close', =>
			devices = JSON.parse buffer
			for device, i in devices
				@networkInterface.append $$ ->
					attrs = value: device.name
					attrs.selected = true if i is 0 or device.name is dash.config.networkInterface
					@option attrs, formatDeviceName device

			unless dash.config.networkInterface
				@networkInterface.change()
				dash.saveConfig()


		@on 'change', '.config-field', ->
			dash.setConfig $(this).attr('name'), $(this).val()
			dash.saveConfig()

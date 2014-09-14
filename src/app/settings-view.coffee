{View, $, $$} = require 'space-pen'
_ = require 'underscore'
{spawn} = require 'child_process'
path = require 'path'
module.exports = class SettingsView extends View
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

		@setNetworkInterfaces()

		@on 'change', '.config-field', ->
			dash.setConfig $(this).attr('name'), $(this).val()
			dash.saveConfig()

		dash.on 'config-changed:nodePath', =>
			@setNetworkInterfaces()

	setNetworkInterfaces: ->
		capturePath = path.resolve path.join __dirname, '..', '..', 'capture'
		@proc = spawn dash.nodePath, [path.join(capturePath, 'src', 'capture.js'), '--list-devices'],
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
			@networkInterface.empty()
			devices = JSON.parse buffer
			for device, i in devices
				@networkInterface.append $$ ->
					attrs = value: device.name
					attrs.selected = true if i is 0 or device.name is dash.config.networkInterface
					@option attrs, formatDeviceName device

			unless dash.config.networkInterface
				@networkInterface.change()
				dash.saveConfig()

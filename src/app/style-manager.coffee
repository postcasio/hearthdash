fs = require 'fs'
path = require 'path'
crypto = require 'crypto'

less = require 'less'
{$} = require 'space-pen'

module.exports = class StyleManager
	lessCachePath: null

	constructor: (@dash) ->
		@lessCachePath = path.join @dash.getDataPath(), 'less-cache'

		unless fs.existsSync(@lessCachePath)
			fs.mkdirSync @lessCachePath

	loadLess: (sourcePath) ->
		options =
			paths: path.dirname sourcePath
			filename: path.basename sourcePath

		fs.readFile sourcePath, encoding: 'utf8', (err, src) =>
			hash = crypto.createHash 'md5'
			hash.update src
			digest = hash.digest('hex')
			cache = path.join(@lessCachePath, "#{digest}.css")

			if fs.existsSync(cache)
				@addLinkTag cache
			else
				less.render src, options, (err, css) =>
					fs.writeFileSync cache, css
					@addLinkTag cache

	addLinkTag: (cssPath) ->
		cacheBuster = (new Date).getTime()
		$('head').append("<link rel=\"stylesheet\" href=\"#{cssPath}?#{cacheBuster}\">")

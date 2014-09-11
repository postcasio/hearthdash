fs = require 'fs'
path = require 'path'
fuzzaldrin = require 'fuzzaldrin'
_ = require 'underscore'
http = require 'http'

module.exports = class CardManager
	classes:
		2: 'Druid'
		3: 'Hunter'
		4: 'Mage'
		5: 'Paladin'
		6: 'Priest'
		7: 'Rogue'
		8: 'Shaman'
		9: 'Warlock'
		10: 'Warrior'

	constructor: (@dash) ->
		@cards = JSON.parse fs.readFileSync path.join @dash.rootPath, 'data', 'cards.json'
		@collectibleCards = _.filter(@cards, (card) -> card.collectible and card.id.substr(0, 4) isnt 'HERO')


		@cachePath = path.join @dash.dataPath, 'art-cache'

		unless fs.existsSync @cachePath
			fs.mkdirSync @cachePath

	find: (id) -> @cards[id]

	search: (query, klass) ->
		results = fuzzaldrin.filter _.values(_.filter @collectibleCards, (card) -> not card.class or card.class == klass), query, key: 'name', maxResults: 20

		_.pluck results, 'id'

	getArtUrl: (id, callback) ->
		artPath = path.join @cachePath, "#{id}.png"

		if fs.existsSync artPath
			callback 'file://' + artPath
			return

		url = "http://wow.zamimg.com/images/hearthstone/cards/enus/medium/#{id}.png"

		file = fs.createWriteStream artPath

		request = http.get url, (response) ->
			response.pipe file
			file.on 'finish', ->
				file.close ->
					callback 'file://' + artPath

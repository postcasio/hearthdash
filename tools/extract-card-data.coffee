argv = require('yargs').argv
winston = require 'winston'
glob = require 'glob'
path = require 'path'
xml2js = require 'xml2js'
fs = require 'fs'

unless argv['card-dir']
	winston.error 'Please specify the card data directory.'
	process.exit()

lang = argv.lang ? 'enUS'

cards = fs.readFileSync path.resolve(path.join argv['card-dir'], lang + '.txt'), 'utf-8'
xml2js.parseString cards, (err, result) ->
	cardData = {}
	for card in result.CardDefs.Entity
		data =
			id: card.$.CardID

		for tag in card.Tag
			switch tag.$.enumID
				when '185'
					data.name = tag._
				when '184'
					data.text = tag._
				else
					data[tag.$.enumID] = tag.$.value

		cardData[data.id] = data

	fs.writeFileSync(path.join(__dirname, '..', 'data', 'cards.json'), JSON.stringify(cardData, null, "\t"))

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

pattern = path.resolve(path.join(argv['card-dir'], '*.txt'))

cards = glob.sync(pattern)

cardData = {}

total = cards.length
parsed = 0

for card in cards
	xml2js.parseString fs.readFileSync(card, 'utf-8'), (err, result) ->
		data =
			id: result.Entity.$.CardID

		for tag in result.Entity.Tag
			switch tag.$.name
				when 'CardName'
					data.name = tag[lang]?[0]
				when 'CardTextInHand'
					data.text = tag[lang]?[0]
				else
					data[tag.$.name.toLowerCase()] = tag.$.value

		cardData[data.id] = data

		if ++parsed == cards.length
			fs.writeFileSync(path.join(__dirname, '..', 'data', 'cards.json'), JSON.stringify(cardData, null, "\t"))
			process.exit()

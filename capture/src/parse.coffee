path = require 'path'
Protobuf = require 'node-protobuf'
fs = require 'fs'

packet_types =
	AUTH_RESPONSE: 106
	GAME_INFO: 107
	REMOVE_GAME: 108
	GOTO_SERVER: 109
	PLAYER_JOINED: 110
	PLAYER_LEFT: 111
	MESSAGE: 126
	GOTO_UTIL: 151
	QUEUE_EVENT: 161
	DEBUG_MESSAGE: 5
	START_GAMESTATE: 7
	FIN_GAMESTATE: 8
	TURN_TIMER: 9
	NACK_OPTION: 10
	GAME_CANCELED: 12
	ALL_OPTIONS: 14
	USER_UI: 15
	GAME_SETUP: 16
	ENTITY_CHOICE: 17
	PRELOAD: 18
	POWER_HISTORY: 19
	NOTIFICATION: 21
	GAME_STARTING: 114
	DECK_LIST: 202
	UTIL_AUTH: 204
	COLLECTION: 207
	GAMES_INFO: 208
	PROFILE_NOTICES: 212
	DECK_CONTENTS: 215
	DECK_ACTION: 216
	DECK_CREATED: 217
	DECK_DELETED: 218
	DECK_RENAMED: 219
	DECK_GAIN_CARD: 220
	DECK_LOST_CARD: 221
	BOOSTER_LIST: 224
	OPENED_BOOSTER: 226
	LAST_LOGIN: 227
	DECK_LIMIT: 231
	MEDAL_INFO: 232
	PROFILE_PROGRESS: 233
	MEDAL_HISTORY: 234
	BATTLE_PAY_CONFIG_RESPONSE: 238
	CLIENT_OPTIONS: 241
	DRAFT_BEGIN: 246
	DRAFT_RETIRE: 247
	DRAFT_CHOICES_AND_CONTENTS: 248
	DRAFT_CHOSEN: 249
	DRAFT_ERROR: 251
	ACHIEVE: 252
	CARD_QUOTE: 256
	CARD_SALE: 258
	CARD_VALUES: 260
	DISCONNECTED_GAME: 289
	PURCHASE_RESPONSE: 256
	ACCOUNT_BALANCE: 262
	FEATURES_CHANGED: 264
	BATTLEPAY_STATUS_RESPONSE: 265
	MASS_DISENCHANT_RESPONSE: 269
	PLAYER_RECORDS: 270
	REWARD_PROGRESS: 271
	PURCHASE_METHOD: 272
	PURCHASE_CANCELED_RESPONSE: 275
	CHECK_LICENSES_RESPONSE: 277
	GOLD_BALANCE: 278
	PURCHASE_WITH_GOLD_RESPONSE: 280
	QUEST_CANCELED: 282
	ALL_HERO_XP: 283
	ACHIEVE_VALIDATED: 285
	PLAY_QUEUE: 286
	DRAFT_ACK_REWARDS: 288
	NOT_AVAILABLE: 290
	DC_CONSOLE_CMD: 123
	DC_RESPONSE: 124
	AURORA_HANDSHAKE: 168
	BEGIN_PLAYING: 113
	CHOOSE_OPTION: 2

reverse_packet_types = {}
reverse_packet_types[val] = key for key, val of packet_types

p = (desc) -> { schema: desc, proto: new Protobuf fs.readFileSync path.join 'descriptors', desc + '.desc' }

protos =
	POWER_HISTORY: p 'PowerHistory'
	ALL_OPTIONS: p 'AllOptions'
	BEGIN_PLAYING: p 'BeginPlaying'
	CHOOSE_OPTION: p 'ChooseOption'
	GAME_SETUP: p 'GameSetup'
	START_GAMESTATE: p 'StartGameState'

stream = new Buffer 0

parsePacket = (type, buffer, size) ->
	if proto = protos[reverse_packet_types[type]]
		try
			process.stdout.write JSON.stringify
				type: reverse_packet_types[type]
				data: proto.proto.parse buffer, proto.schema
			process.stdout.write "\n"
		catch
			process.stderr.write "Packet type failed size #{size} #{reverse_packet_types[type]}\n#{buffer.toString 'hex'}\n"

module.exports = (buffer) ->
	stream = Buffer.concat [stream, buffer]

	while stream.length > 8
		type = stream.readUInt32LE 0
		size = stream.readUInt32LE 4

		if type > 1000 or size > 8000
			stream = new Buffer 0
			return

		else if stream.length >= 8 + size
			parsePacket type, stream.slice(8, 8 + size), size

			stream = stream.slice(8 + size)

		else
			return	# need to get more data

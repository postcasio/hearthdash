{Emitter} = require 'emissary'
{spawn} = require 'child_process'
path = require 'path'
{$} = require 'space-pen'
tags =
	204: 'STATE'
	20: 'TURN'
	19: 'STEP'
	198: 'NEXT_STEP'
	31: 'TEAM_ID'
	30: 'PLAYER_ID'
	29: 'STARTHANDSIZE'
	28: 'MAXHANDSIZE'
	176: 'MAXRESOURCES'
	7: 'TIMEOUT'
	8: 'TURN_START'
	9: 'TURN_TIMER_SLUSH'
	13: 'GOLD_REWARD_STATE'
	24: 'FIRST_PLAYER'
	23: 'CURRENT_PLAYER'
	27: 'HERO_ENTITY'
	26: 'RESOURCES'
	25: 'RESOURCES_USED'
	22: 'FATIGUE'
	17: 'PLAYSTATE'
	291: 'CURRENT_SPELLPOWER'
	305: 'MULLIGAN_STATE'
	348: 'HAND_REVEALED'
	185: 'CARDNAME'
	184: 'CARDTEXT_INHAND'
	200: 'CARDRACE'
	202: 'CARDTYPE'
	48: 'COST'
	45: 'HEALTH'
	47: 'ATK'
	187: 'DURABILITY'
	292: 'ARMOR'
	318: 'PREDAMAGE'
	325: 'TARGETING_ARROW_TEXT'
	18: 'LAST_AFFECTED_BY'
	330: 'ENCHANTMENT_BIRTH_VISUAL'
	331: 'ENCHANTMENT_IDLE_VISUAL'
	12: 'PREMIUM'
	1: 'IGNORE_DAMAGE'
	354: 'IGNORE_DAMAGE_OFF'
	53: 'ENTITY_ID'
	52: 'DEFINITION'
	51: 'OWNER'
	50: 'CONTROLLER'
	49: 'ZONE'
	43: 'EXHAUSTED'
	40: 'ATTACHED'
	39: 'PROPOSED_ATTACKER'
	38: 'ATTACKING'
	37: 'PROPOSED_DEFENDER'
	36: 'DEFENDING'
	35: 'PROTECTED'
	34: 'PROTECTING'
	33: 'RECENTLY_ARRIVED'
	44: 'DAMAGE'
	32: 'TRIGGER_VISUAL'
	190: 'TAUNT'
	192: 'SPELLPOWER'
	194: 'DIVINE_SHIELD'
	197: 'CHARGE'
	219: 'SECRET'
	293: 'MORPH'
	314: 'DIVINE_SHIELD_READY'
	306: 'TAUNT_READY'
	307: 'STEALTH_READY'
	308: 'CHARGE_READY'
	313: 'CREATOR'
	232: 'CANT_DRAW'
	231: 'CANT_PLAY'
	230: 'CANT_DISCARD'
	229: 'CANT_DESTROY'
	228: 'CANT_TARGET'
	227: 'CANT_ATTACK'
	226: 'CANT_EXHAUST'
	225: 'CANT_READY'
	224: 'CANT_REMOVE_FROM_GAME'
	223: 'CANT_SET_ASIDE'
	222: 'CANT_DAMAGE'
	221: 'CANT_HEAL'
	247: 'CANT_BE_DESTROYED'
	246: 'CANT_BE_TARGETED'
	245: 'CANT_BE_ATTACKED'
	244: 'CANT_BE_EXHAUSTED'
	243: 'CANT_BE_READIED'
	242: 'CANT_BE_REMOVED_FROM_GAME'
	241: 'CANT_BE_SET_ASIDE'
	240: 'CANT_BE_DAMAGED'
	239: 'CANT_BE_HEALED'
	253: 'CANT_BE_SUMMONING_SICK'
	314: 'CANT_BE_DISPELLED'
	238: 'INCOMING_DAMAGE_CAP'
	237: 'INCOMING_DAMAGE_ADJUSTMENT'
	236: 'INCOMING_DAMAGE_MULTIPLIER'
	235: 'INCOMING_HEALING_CAP'
	234: 'INCOMING_HEALING_ADJUSTMENT'
	233: 'INCOMING_HEALING_MULTIPLIER'
	260: 'FROZEN'
	261: 'JUST_PLAYED'
	262: 'LINKEDCARD'
	263: 'ZONE_POSITION'
	264: 'CANT_BE_FROZEN'
	266: 'COMBO_ACTIVE'
	267: 'CARD_TARGET'
	269: 'NUM_CARDS_PLAYED_THIS_TURN'
	270: 'CANT_BE_TARGETED_BY_OPPONENTS'
	271: 'NUM_TURNS_IN_PLAY'
	205: 'SUMMONED'
	212: 'ENRAGED'
	188: 'SILENCED'
	189: 'WINDFURY'
	216: 'LOYALTY'
	217: 'DEATH_RATTLE'
	191: 'STEALTH'
	218: 'BATTLECRY'
	272: 'NUM_TURNS_LEFT'
	273: 'OUTGOING_DAMAGE_CAP'
	274: 'OUTGOING_DAMAGE_ADJUSTMENT'
	275: 'OUTGOING_DAMAGE_MULTIPLIER'
	276: 'OUTGOING_HEALING_CAP'
	277: 'OUTGOING_HEALING_ADJUSTMENT'
	278: 'OUTGOING_HEALING_MULTIPLIER'
	279: 'INCOMING_ABILITY_DAMAGE_ADJUSTMENT'
	280: 'INCOMING_COMBAT_DAMAGE_ADJUSTMENT'
	281: 'OUTGOING_ABILITY_DAMAGE_ADJUSTMENT'
	282: 'OUTGOING_COMBAT_DAMAGE_ADJUSTMENT'
	283: 'OUTGOING_ABILITY_DAMAGE_MULTIPLIER'
	284: 'OUTGOING_ABILITY_DAMAGE_CAP'
	285: 'INCOMING_ABILITY_DAMAGE_MULTIPLIER'
	286: 'INCOMING_ABILITY_DAMAGE_CAP'
	287: 'OUTGOING_COMBAT_DAMAGE_MULTIPLIER'
	288: 'OUTGOING_COMBAT_DAMAGE_CAP'
	289: 'INCOMING_COMBAT_DAMAGE_MULTIPLIER'
	290: 'INCOMING_COMBAT_DAMAGE_CAP'
	294: 'IS_MORPHED'
	295: 'TEMP_RESOURCES'
	296: 'RECALL_OWED'
	297: 'NUM_ATTACKS_THIS_TURN'
	302: 'NEXT_ALLY_BUFF'
	303: 'MAGNET'
	304: 'FIRST_CARD_PLAYED_THIS_TURN'
	186: 'CARD_ID'
	311: 'CANT_BE_TARGETED_BY_ABILITIES'
	312: 'SHOULDEXITCOMBAT'
	316: 'PARENT_CARD'
	317: 'NUM_MINIONS_PLAYED_THIS_TURN'
	332: 'CANT_BE_TARGETED_BY_HERO_POWERS'
	220: 'COMBO'
	114: 'ELITE'
	183: 'CARD_SET'
	201: 'FACTION'
	203: 'RARITY'
	199: 'CLASS'
	6: 'MISSION_EVENT'
	208: 'FREEZE'
	215: 'RECALL'
	339: 'SILENCE'
	340: 'COUNTER'
	342: 'ARTISTNAME'
	351: 'FLAVORTEXT'
	352: 'FORCED_PLAY'
	353: 'LOW_HEALTH_THRESHOLD'
	356: 'SPELLPOWER_DOUBLE'
	357: 'HEALING_DOUBLE'
	358: 'NUM_OPTIONS_PLAYED_THIS_TURN'
	359: 'NUM_OPTIONS'
	360: 'TO_BE_DESTROYED'
	337: 'HEALTH_MINIMUM'
	362: 'AURA'
	363: 'POISONOUS'
	364: 'HOW_TO_EARN'
	365: 'HOW_TO_EARN_GOLDEN'
	370: 'AFFECTED_BY_SPELL_POWER'

module.exports = class PacketInterface
	Emitter.includeInto(this)

	constructor: (@dash) ->
		@proc = null
		@buffer = ''
		@errBuffer = ''

	watch: ->
		@capturePath = path.resolve path.join __dirname, '..', '..', 'capture'

		@proc = null

		@start()

		$(window).on 'onbeforeunload', =>
			console.log 'stopping interface'
			@stop()

		dash.on 'config-changed:networkInterface', (value) =>
			@restart()

	stop: ->
		if @proc
			@proc.kill 'SIGINT'

	restart: ->
		@stop()
		@start()

	start: ->
		if dash.config.networkInterface
			@proc = spawn '/usr/local/bin/coffee', [path.join(@capturePath, 'src', 'capture.coffee'), '--device=' + dash.config.networkInterface],
				cwd: @capturePath

			@proc.stdout.on 'data', (data) =>
				@buffer += data
				@checkBuffer()

			@proc.stderr.on 'data', (data) =>
				@errBuffer += data
				@checkBuffer()

			dash.alertsView.createAlert
				heading: 'Packet capturing'
				text: 'Listening on interface ' + dash.config.networkInterface

	checkBuffer: ->
		for bufferName in ['buffer', 'errBuffer']
			buffer = this[bufferName]

			nl = buffer.indexOf "\n"

			while nl > -1
				message = buffer.slice 0, nl + 1

				if bufferName is 'buffer'
					@processMessage JSON.parse message
				else
					dash.alertsView.createAlert
						heading: 'Packet capturing'
						text: message

				this[bufferName] = buffer = buffer.slice nl + 1

				nl = buffer.indexOf "\n"

		undefined

	humanizeTags: (tagset) ->
		humanized = {}
		for tag in tagset
			humanized[tags[tag.name]] = tag.value

		humanized

	processMessage: (message) ->
		switch message.type
			when 'BEGIN_PLAYING'
				if message.data.mode is 'COUNTDOWN'
					@emit 'game-start'
				else if message.data.mode is 'READY'
					@emit 'ready'

			when 'ALL_OPTIONS'
				@emit 'all-options', message.data

			when 'CHOOSE_OPTION'
				@emit 'choose-option', message.data

			when 'POWER_HISTORY'
				for power in message.data.list
					if power.tagChange
						@emit 'tag-change',
							id: power.tagChange.id
							tag: tags[power.tagChange.tag]
							value: power.tagChange.value

					if power.showEntity
						@emit 'show-entity',
							id: power.showEntity.id
							name: power.showEntity.name
							tags: @humanizeTags power.showEntity.tags

					if power.fullEntity
						@emit 'full-entity',
							id: power.fullEntity.id
							name: power.fullEntity.name
							tags: @humanizeTags power.fullEntity.tags

					if power.createGame
						@emit 'create-game', power.createGame

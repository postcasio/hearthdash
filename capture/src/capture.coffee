{Cap, decoders} = require 'cap'
minimist = require 'minimist'
parse = require './parse'

argv = minimist process.argv.slice 2

if argv['list-devices']
	process.stdout.write JSON.stringify c.deviceList()

else
	device = argv['device']
	cap = new Cap
	filter = 'tcp port 1119'
	bufSize = 10 * 1024 * 1024
	buffer = new Buffer 65535

	linkType = cap.open device, filter, bufSize, buffer

	if linkType isnt 'ETHERNET'
		process.stdout.write JSON.stringify error: "Invalid link type #{linkType}"
		cap.close()
		return

	cap.setMinBytes? 0

	cap.on 'packet', (bytes, trunc) ->
		if trunc
			process.stderr.write 'Encountered truncated packet.'
			return

		ethernet = decoders.Ethernet buffer
		if ethernet.info.type is decoders.PROTOCOL.ETHERNET.IPV4
			ipv4 = decoders.IPV4 buffer, ethernet.offset
			if ipv4.info.protocol is decoders.PROTOCOL.IP.TCP
				datalen = ipv4.info.totallen - ipv4.hdrlen
				tcp = decoders.TCP buffer, ipv4.offset
				datalen -= tcp.hdrlen

				parse buffer.slice tcp.offset, tcp.offset + datalen

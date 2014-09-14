fs = require 'fs'
request = require 'request'
Unzip = require 'decompress-zip'
path = require 'path'
{spawn} = require 'child_process'
minimist = require 'minimist'

argv = minimist(process.argv.slice(2))

buildTarget = argv.target ? process.platform

buildPath = path.join __dirname, '..', 'build'

unless fs.existsSync buildPath
	fs.mkdirSync buildPath

atomShellVersion = 'v0.16.2'
disunityVersion = 'v0.3.2'
nodeVersion = 'v' + process.versions.node

arch = if buildTarget is 'win32' then 'ia32' else process.arch
atomShellUrl = "https://github.com/atom/atom-shell/releases/download/#{atomShellVersion}/atom-shell-#{atomShellVersion}-#{buildTarget}-#{arch}.zip"

atomShellZipPath = path.join buildPath, "atom-shell-#{atomShellVersion}-#{buildTarget}-#{arch}.zip"
atomShellExtractPath = buildPath
disunityUrl = "https://github.com/ata4/disunity/releases/download/#{disunityVersion}/disunity_#{disunityVersion}.zip"
disunityZipPath = path.join buildPath, "disunity-#{disunityVersion}.zip"
disunityJarPath = path.join buildPath, "disunity.jar"


switch buildTarget
	when 'darwin'
		nodeUrl = "http://nodejs.org/dist/#{nodeVersion}/node-#{nodeVersion}-darwin-#{arch}.tar.gz"
		nodePath = path.join buildPath, "node-#{nodeVersion}-darwin-#{arch}.tar.gz"
		nodeExtractedPath = path.join buildPath, "node-#{nodeVersion}-darwin-#{arch}", 'bin', 'node'
		nodeRequiresExtraction = true
		cardXmlPath = argv['card-xml-path'] ? '/Applications/Hearthstone/Data/OSX/cardxml0.unity3d'
		cardXmlExtractedPath = path.join path.dirname(cardXmlPath), 'cardxml0', 'CAB-cardxml0', 'TextAsset'
		atomShellExecutablePath = path.join(atomShellExtractPath, 'Atom.app')
		executablePath = path.join(atomShellExtractPath, 'Hearthdash.app')
		atomShellResourcesPath = path.join(atomShellExecutablePath, 'Contents', 'Resources', 'app')
		nodeDestinationPath = atomShellResourcesPath
		apmPath = path.join(__dirname, '..', 'node_modules', 'atom-package-manager', 'bin', 'apm')
		disunityExecutablePath = path.join buildPath, 'disunity.sh'
		disunityShell = 'bash'

	when 'win32'
		nodeUrl = 'http://nodejs.org/dist/v0.10.31/node.exe'
		nodePath = path.join buildPath, 'node.exe'
		nodeRequiresExtraction = false
		cardXmlPath = argv['card-xml-path']
		cardXmlExtractedPath = path.join path.dirname(cardXmlPath), 'cardxml0', 'CAB-cardxml0', 'TextAsset'
		atomShellExecutablePath = path.join(atomShellExtractPath, 'atom.exe')
		executablePath = path.join(atomShellExtractPath, 'Hearthdash.exe')
		atomShellResourcesPath = path.join(atomShellExtractPath, 'resources/app')
		nodeDestinationPath = atomShellResourcesPath
		apmPath = path.join(__dirname, '..', 'node_modules', 'atom-package-manager', 'bin', 'apm.cmd')
		disunityExecutablePath = path.join buildPath, 'disunity.bat'
		disunityShell = 'cmd'

passthrough = (proc) ->
	proc.stdout.on 'data', (data) -> console.log data.toString('utf8')
	proc.stderr.on 'data', (data) -> console.log data.toString('utf8')

rename = ->
	proc = spawn 'mv', [atomShellExecutablePath, executablePath]
	proc.on 'exit', ->
		console.log 'Finished'
copyFiles = ->
	console.log "Copying files..."
	unless fs.existsSync atomShellResourcesPath
		fs.mkdirSync atomShellResourcesPath

	proc = spawn 'cp', [(if nodeRequiresExtraction then nodeExtractedPath else nodePath), nodeDestinationPath]
	passthrough proc
	proc.on 'exit', ->
		index = 0
		files = ['capture', 'data', 'images', 'less', 'node_modules', 'src', 'static', 'package.json']

		copy = ->
			unless files[index].indexOf '.'
				fs.mkdirSync path.join(atomShellResourcesPath, files[index])

			proc = spawn 'cp', ['-R', path.join(__dirname, '..', files[index]), path.join(atomShellResourcesPath, files[index])]

			proc.on 'exit', ->
				index++
				if index < files.length
					process.nextTick copy
				else
					rename()

		copy()

compileCapture = ->
	console.log 'Compiling capture sources...'
	proc = spawn 'coffee', ['-c', path.join(__dirname, '..', 'capture', 'src', 'capture.coffee')]
	proc.on 'exit', ->
		proc = spawn 'coffee', ['-c', path.join(__dirname, '..', 'capture', 'src', 'parse.coffee')]
		proc.on 'exit', ->
			copyFiles()

unzipAtomShell = ->
	proc = spawn 'unzip', ['-o', atomShellZipPath],
		cwd: atomShellExtractPath
	proc.stdout.on 'data', ->
	proc.on 'exit', ->
		compileCapture()

downloadAtomShell = ->
	if fs.existsSync atomShellZipPath
		console.log 'Unzipping atom-shell...'
		unzipAtomShell()
	else
		console.log "Downloading atom-shell..."

		pipe = request(atomShellUrl).pipe(fs.createWriteStream(atomShellZipPath))
		pipe.on 'error', (e) ->
			throw e
		pipe.on 'close', ->
			unzipAtomShell()

downloadDisunity = ->
	if fs.existsSync disunityZipPath
		console.log 'Unzipping disunity...'
		unzipDisunity()
	else
		console.log "Downloading disunity..."
		pipe = request(disunityUrl).pipe(fs.createWriteStream(disunityZipPath))
		pipe.on 'close', ->
			unzipDisunity()

unzipDisunity = ->
	proc = spawn 'unzip', ['-o', disunityZipPath],
		cwd: buildPath
	proc.on 'exit', ->
		extractCardData()

extractCardData = ->
	console.log 'Extracting card data...'

	proc = spawn disunityShell, [disunityExecutablePath, 'extract', cardXmlPath],
		cwd: buildPath

	proc.stdout.on 'data', ->

	proc.on 'exit', ->
		proc = spawn 'coffee', [path.join(__dirname, 'extract-card-data.coffee'), '--card-dir', path.join(cardXmlExtractedPath)]
		console.log 'Converting...'
		proc.on 'exit', ->
			downloadNode()

downloadNode = ->
	console.log 'Downloading node...'
	pipe = request(nodeUrl).pipe(fs.createWriteStream(nodePath))
	pipe.on 'close', ->
		if nodeRequiresExtraction

			console.log 'Extracting...'
			proc = spawn 'tar', ['-xzf', nodePath],
				cwd: buildPath
			passthrough proc
			proc.on 'exit', ->
				installApm()
		else
			installApm()

installApm = ->
	if fs.existsSync path.join __dirname , '..', 'node_modules', 'atom-package-manager'
		installCapture()
		return

	console.log "Installing apm..."

	proc = spawn 'npm', ['install', 'atom-package-manager'],
		cwd: path.join __dirname, '..'

	proc.on 'exit', ->
		proc = spawn apmPath, ['install', '.'],
			cwd: path.join __dirname, '..'

		proc.on 'exit', ->
			installCapture()

installCapture = ->
	console.log "Installing modules for packet capturing..."
	proc = spawn 'npm', ['install'],
		cwd: path.join __dirname, '..', 'capture'

	proc.on 'exit', ->
		downloadAtomShell()



downloadDisunity()

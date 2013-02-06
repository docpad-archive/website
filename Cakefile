# This file was originally created by Benjamin Lupton <b@lupton.cc> (http://balupton.com)
# and is currently licensed under the Creative Commons Zero (http://creativecommons.org/publicdomain/zero/1.0/)
# making it public domain so you can do whatever you wish with it without worry (you can even remove this notice!)
#
# If you change something here, be sure to reflect the changes in:
# - the scripts section of the package.json file
# - the .travis.yml file


# -----------------
# Variables

WINDOWS = process.platform.indexOf('win') is 0
NODE    = process.execPath
NPM     = if WINDOWS then process.execPath.replace('node.exe','npm.cmd') else 'npm'
EXT     = (if WINDOWS then '.cmd' else '')
ROOT    = process.cwd()
APP     = "#{ROOT}/app"
SITE    = "#{ROOT}/site"
BIN     = "#{ROOT}/node_modules/.bin"
CAKE    = "#{BIN}/cake#{EXT}"
COFFEE  = "#{BIN}/coffee#{EXT}"
DOCPAD  = "#{BIN}/docpad#{EXT}"
DOCPADS = "#{BIN}/docpad-server#{EXT}"
APPOUT  = "#{APP}/out"
APPSRC  = "#{APP}/src"
SITEOUT = "#{SITE}/out"
SITESRC = "#{SITE}/src"
DEBUG   = ('-d' in process.argv)


# -----------------
# Requires

pathUtil = require('path')
{exec,spawn} = require('child_process')

childProcesses = []
exit = (err,code) ->
	for childProcess in childProcesses
		childProcess.kill()
	process.exit(code)

safe = (next,fn) ->
	return (args...) ->
		err = args[0]
		return next(err)  if err
		return fn(args...)


# -----------------
# Actions

clean = (opts,next) ->
	(next = opts; opts = {})  unless next?
	args = [
		'-Rf'
		APPOUT
		SITEOUT
		pathUtil.join(ROOT,'node_modules')
		pathUtil.join(ROOT,'*out')
		pathUtil.join(ROOT,'*log')
	]
	spawn('rm', args, {env:process.env,stdio:'inherit',cwd:ROOT}).on('exit',next)

compile = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(COFFEE, ['-bco', APPOUT, APPSRC], {env:process.env,stdio:'inherit',cwd:ROOT}).on('exit',next)

watch = (opts,next) ->
	(next = opts; opts = {})  unless next?
	childProcesses.push spawn(COFFEE, ['-bwco', APPOUT, APPSRC], {env:process.env,stdio:'inherit',cwd:ROOT}).on('exit',exit)
	next()

run = (opts,next) ->
	(next = opts; opts = {})  unless next?
	if opts.debug ? DEBUG
		command = NODE
		args = ['--debug-brk', DOCPAD, 'run']
	else
		command = DOCPAD
		args = ['run']
	childProcesses.push spawn(command, args, {env:process.env,stdio:'inherit',cwd:ROOT}).on('exit',exit)
	next()

app = (opts,next) ->
	(next = opts; opts = {})  unless next?
	watch opts, safe next, ->
		run opts, next

install = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(NPM, ['install'], {env:process.env,stdio:'inherit',cwd:ROOT}).on('exit',next)

reset = (opts,next) ->
	(next = opts; opts = {})  unless next?
	clean opts, safe next, ->
		setup opts, next

server = (opts,next) ->
	(next = opts; opts = {})  unless next?
	compile opts, safe next, ->
		if opts.debug ? DEBUG
			command = NODE
			args = ['--debug-brk', DOCPADS]
		else
			command = DOCPADS
			args = []
		spawn(command, args, {env:process.env,stdio:'inherit',cwd:ROOT}).on('exit',next)

setup = (opts,next) ->
	(next = opts; opts = {})  unless next?
	install opts, safe next, ->
		compile opts, next

finish = (err) ->
	throw err  if err
	console.log('OK')


# -----------------
# Commands

# clean
task 'clean', 'clean up instance', ->
	clean finish

# compile
task 'compile', 'compile our files', ->
	compile finish

# run
task 'run', 'run our application', ->
	run finish

# watch
task 'watch', 'recompile our files when changed', ->
	watch finish

# dev/app
task 'dev', 'watch and run our application', ->
	app finish
task 'app', 'watch and run our application', ->
	app finish

# install
task 'install', 'install dependencies', ->
	install finish

# reset
task 'reset', 'reset instance', ->
	reset finish

# start
task 'server', 'start server instance', ->
	server finish

# setup
task 'setup', 'setup for development', ->
	setup finish

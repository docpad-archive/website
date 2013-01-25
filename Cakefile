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
APPOUT  = "#{APP}/out"
APPSRC  = "#{APP}/src"
SITEOUT = "#{SITE}/out"
SITESRC = "#{SITE}/src"


# -----------------
# Requires

pathUtil = require('path')
{exec,spawn} = require('child_process')
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
	spawn('rm', args, {stdio:'inherit',cwd:ROOT}).on('exit',next)

compile = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(COFFEE, ['-bco', APPOUT, APPSRC], {stdio:'inherit',cwd:ROOT}).on 'exit', safe next, ->
		spawn(DOCPAD, ['generate','--env','static'], {stdio:'inherit',cwd:ROOT}).on('exit',next)

watch = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(COFFEE, ['-bwco', APPOUT, APPSRC], {stdio:'inherit',cwd:ROOT})
	spawn(DOCPAD, ['run','--env','static'], {stdio:'inherit',cwd:ROOT})
	next()

install = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(NPM, ['install'], {stdio:'inherit',cwd:ROOT}).on('exit',next)

reset = (opts,next) ->
	(next = opts; opts = {})  unless next?
	clean opts, safe next, ->
		setup opts, next

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

# dev/watch
task 'dev', 'watch and recompile our files', ->
	watch finish
task 'watch', 'watch and recompile our files', ->
	watch finish

# install
task 'install', 'install dependencies', ->
	install finish

# reset
task 'reset', 'reset instance', ->
	reset finish

# setup
task 'setup', 'setup for development', ->
	setup finish

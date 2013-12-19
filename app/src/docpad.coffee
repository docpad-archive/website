# Require
fsUtil = require('fs')
pathUtil = require('path')
moment = require('moment')
strUtil = require('underscore.string')
{requireFresh} = require('requirefresh')
extendr = require('extendr')
#validator = require('validator')

# Prepare
rootPath = __dirname+'/../..'
appPath = __dirname
sitePath = rootPath+'/site'
textData = requireFresh(appPath+'/templateData/text')
navigationData = requireFresh(appPath+'/templateData/navigation')
websiteVersion = require(rootPath+'/package.json').version
siteUrl = if process.env.NODE_ENV is 'production' then "http://docpad.org" else "http://localhost:9778"
contributorsGetter = null
contributors = null


# =================================
# Helpers

# Titles
getName = (a,b) ->
	if b is null
		return textData[b] ? humanize(b)
	else
		return textData[a][b] ? humanize(b)
getProjectName = (project) ->
	getName('projectNames',project)
getCategoryName = (category) ->
	getName('categoryNames',category)
getLinkName = (link) ->
	getName('linkNames',link)
getLabelName = (label) ->
	getName('labelNames',label)

# Humanize
humanize = (text) ->
	text ?= ''
	return strUtil.humanize text.replace(/^[\-0-9]+/,'').replace(/\..+/,'')


# =================================
# Configuration


# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
docpadConfig =

	# =================================
	# DocPad Configuration

	# Paths
	rootPath: rootPath
	outPath: rootPath+'/site/out'
	srcPath: rootPath+'/site/src'
	reloadPaths: [
		appPath
	]

	# Regenerate each day
	regenerateEvery: 1000*60*60*24


	# =================================
	# Template Data
	# These are variables that will be accessible via our templates
	# To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

	templateData:

		# -----------------------------
		# Misc

		strUtil: strUtil
		moment: moment
		#sanitize: (input) -> validator.sanitize(input).xss()
		# disabled due to https://github.com/chriso/node-validator/issues/226 and https://github.com/chriso/node-validator/issues/206

		text: textData
		navigation: navigationData


		# -----------------------------
		# Site Properties

		site:
			# The production URL of our website
			url: siteUrl

			# The default title of our website
			title: "DocPad - Streamlined Web Development"

			# The website description (for SEO)
			description: """
				Empower your website frontends with layouts, meta-data, pre-processors (markdown, jade, coffeescript, etc.), partials, skeletons, file watching, querying, and an amazing plugin system. Use it either standalone, as a build script, or even as a module in a bigger system. Either way, DocPad will streamline your web development process allowing you to craft full-featured websites quicker than ever before.
				"""

			# The website keywords (for SEO) separated by commas
			keywords: """
				bevry, bevryme, balupton, benjamin lupton, docpad, node, node.js, javascript, coffeescript, query engine, queryengine, backbone.js, cson
				"""

			# Services
			services:
				ircwebchat: 'docpad'

				travisStatusButton: 'bevry/docpad'
				furyButton: 'docpad'
				gittipButton: 'docpad'
				flattrButton: '344188/balupton-on-Flattr'
				paypalButton: 'QB8GQPZAH84N6'

				facebookLikeButton:
					applicationId: '266367676718271'
				twitterTweetButton: 'docpad'
				twitterFollowButton: 'docpad'
				githubStarButton: 'bevry/docpad'

				disqus: 'docpad'
				gauges: '50dead2bf5a1f541d7000008'
				googleAnalytics: 'UA-35505181-2'
				inspectlet: '746529266'
				mixpanel: 'd0f9b33c0ec921350b5419352028577e'
				reinvigorate: '89t63-62ne18262h'

			# Styles
			styles: [
				'/vendor/normalize.css'
				'/vendor/h5bp.css'
				'/vendor/highlight.css'
				'/styles/style.css'
			].map (url) -> "#{url}?websiteVersion=#{websiteVersion}"

			# Script
			scripts: [
				# Vendor
				"/vendor/jquery.js"
				"/vendor/jquery-scrollto.js"
				"/vendor/modernizr.js"
				"/vendor/history.js"

				# Scripts
				"/vendor/historyjsit.js"
				"/scripts/bevry.js"
				"/scripts/script.js"
			].map (url) -> "#{url}?websiteVersion=#{websiteVersion}"

		# -----------------------------
		# Helper Functions

		# Names
		getName: getName
		getProjectName: getProjectName
		getCategoryName: getCategoryName
		getLinkName: getLinkName
		getLabelName: getLabelName

		# Get the prepared site/document title
		# Often we would like to specify particular formatting to our page's title
		# we can apply that formatting here
		getPreparedTitle: ->
			# if we have a title, we should use it suffixed by the site's title
			if @document.pageTitle isnt false and @document.title
				"#{@document.pageTitle or @document.title} | #{@site.title}"
			# if we don't have a title, then we should just use the site's title
			else if @document.pageTitle is false or @document.title? is false
				@site.title

		# Get the prepared site/document description
		getPreparedDescription: ->
			# if we have a document description, then we should use that, otherwise use the site's description
			@document.description or @site.description

		# Get the prepared site/document keywords
		getPreparedKeywords: ->
			# Merge the document keywords with the site keywords
			@site.keywords.concat(@document.keywords or []).join(', ')

		# Get Version
		getVersion: (v,places=1) ->
			return v.split('.')[0...places].join('.')

		# Read File
		readFile: (relativePath) ->
			path = @document.fullDirPath+'/'+relativePath
			result = fsUtil.readFileSync(path)
			if result instanceof Error
				throw result
			else
				return result.toString()

		# Code File
		codeFile: (relativePath,language) ->
			language ?= pathUtil.extname(relativePath).substr(1)
			contents = @readFile(relativePath)
			return """<pre><code class="#{language}">#{contents}</code></pre>"""

		# Get Contributors
		getContributors: -> contributors or []


	# =================================
	# Collections

	collections:

		# Fetch all documents that exist within the docs directory
		# And give them the following meta data based on their file structure
		# [\-0-9]+#{category}/[\-0-9]+#{name}.extension
		docs: (database) ->
			query =
				write: true
				relativeOutDirPath: $startsWith: 'learn/'
				body: $ne: ""
			sorting = [projectDirectory:1, categoryDirectory:1, filename:1]
			database.findAllLive(query, sorting).on 'add', (document) ->
				# Prepare
				a = document.attributes

				###
				learn/#{organisation}/#{project}/#{category}/#{filename}
				###
				pathDetailsExtractor = ///
					^
					.*?learn/
					(.+?)/        # organisation
					(.+?)/        # project
					(.+?)/        # category
					(.+?)\.       # basename
					(.+?)         # extension
					$
				///

				pathDetails = pathDetailsExtractor.exec(a.relativePath)

				# Properties
				layout = 'doc'
				standalone = true
				organisationDirectory = organisation = organisationName =
					projectDirectory = project = projectName =
					categoryDirectory = category = categoryName =
					title = pageTitle = null

				# Check if we are correctly structured
				if pathDetails?
					organisationDirectory = pathDetails[1]
					projectDirectory = pathDetails[2]
					categoryDirectory = pathDetails[3]
					basename = pathDetails[4]

					organisation = organisationDirectory.replace(/[\-0-9]+/, '')
					organisationName = humanize(project)

					project = projectDirectory.replace(/[\-0-9]+/, '')
					projectName = getProjectName(project)

					category = categoryDirectory.replace(/^[\-0-9]+/, '')
					categoryName = getCategoryName(category)

					name = basename.replace(/^[\-0-9]+/,'')

					title = "#{a.title or humanize name}"
					pageTitle = "#{title} | DocPad"  # changed from bevry website

					urls = ["/docs/#{name}", "/docs/#{category}-#{name}", "/docpad/#{name}"]

					githubEditUrl = "https://github.com/#{organisationDirectory}/#{projectDirectory}/edit/master/"
					proseEditUrl = "http://prose.io/##{organisationDirectory}/#{projectDirectory}/edit/master/"
					editUrl = githubEditUrl + a.relativePath.replace("learn/#{organisationDirectory}/#{projectDirectory}/", '')

					# Apply
					document
						.setMetaDefaults({
							layout
							standalone

							name
							title
							pageTitle

							url: urls[0]

							editUrl

							organisationDirectory
							organisation
							organisationName

							projectDirectory
							project
							projectName

							categoryDirectory
							category
							categoryName
						})
						.addUrl(urls)

				# Otherwise ignore this document
				else
					console.log "The document #{a.relativePath} was at an invalid path, so has been ignored"
					document.setMetaDefaults({
						ignore: true
						render: false
						write: false
					})

		partners: (database) ->
			database.findAllLive({relativeOutDirPath:'learn/docpad/documentation/partners'}, [filename:1]).on 'add', (document) ->
				document.setMetaDefaults(write: false)

		pages: (database) ->
			database.findAllLive({relativeOutDirPath:'pages'}, [filename:1])


	# =================================
	# Plugins

	# Alias stylus highlighting to css and there is no inbuilt stylus support
	plugins:
		highlightjs:
			aliases:
				stylus: 'css'

		feedr:
			feeds:
				latestPackage: url: "#{siteUrl}/latest.json"
				exchange: url: "#{siteUrl}/exchange.json"
				#'twitter-favorites': url: 'https://api.twitter.com/1.1/favorites/list.json?screen_name=docpad&count=200&include_entities=true'

		repocloner:
			repos: [
				name: 'DocPad Documentation'
				path: 'src/documents/learn/docpad/documentation'
				url: 'https://github.com/bevry/docpad-documentation.git'
			]


	# =================================
	# Environments

	# Disable analytic services on the development environment
	environments:
		development:
			templateData:
				site:
					services:
						gauges: false
						googleAnalytics: false
						mixpanel: false
						reinvigorate: false


	# =================================
	# Events

	events:

		# Generate Before
		generateBefore: (opts) ->
			# Reset contributors if we are a complete generation (not a partial one)
			contributors = null

			# Return
			return true

		# Fetch Contributors
		renderBefore: (opts,next) ->
			# Prepare
			docpad = @docpad

			# Check
			return next()  if contributors

			# Log
			docpad.log('info', 'Fetching your latest contributors for display within the website')

			# Prepare contributors getter
			contributorsGetter ?= require('getcontributors').create(
				#log: docpad.log
				github_client_id: process.env.BEVRY_GITHUB_CLIENT_ID
				github_client_secret: process.env.BEVRY_GITHUB_CLIENT_SECRET
			)

			# Fetch contributors
			contributorsGetter.fetchContributorsFromUsers ['bevry','docpad','webwrite'], (err,_contributors=[]) ->
				# Check
				return next(err)  if err

				# Apply
				contributors = _contributors
				docpad.log('info', "Fetched your latest contributors for display within the website, all #{_contributors.length} of them")

				# Complete
				return next()

			# Return
			return true

		# Server Extend
		# Used to add our own custom routes to the server before the docpad routes are added
		serverExtend: (opts) ->
			# Extract the server from the options
			{server} = opts
			docpad = @docpad
			request = require('request')
			codeSuccess = 200
			codeBadRequest = 400
			codeRedirectPermanent = 301
			codeRedirectTemporary = 302


			# Pushover - Optional
			# Called by the 404 page to alert our mobile phone of missing pages
			server.all '/pushover', (req,res) ->
				return res.send(codeSuccess)  if 'development' in docpad.getEnvironments() or process.env.BEVRY_PUSHOVER_TOKEN? is false
				request(
					{
						url: "https://api.pushover.net/1/messages.json"
						method: "POST"
						form: extendr.extend(
							{
								device: process.env.BEVRY_PUSHOVER_DEVICE or null
								token: process.env.BEVRY_PUSHOVER_TOKEN
								user: process.env.BEVRY_PUSHOVER_USER_KEY
								message: req.query
							}
							req.query
						)
					}
					(_req,_res,body) ->
						res.send(body)
				)

			# DocPad Regenerate Hook
			# Automatically regenerate when new changes are pushed to our documentation
			server.all '/regenerate', (req,res) ->
				if req.query?.key is process.env.WEBHOOK_KEY
					docpad.log('info', 'Regenerating for documentation change')
					docpad.action('generate', {populate:true, reload:true})
					res.send(codeSuccess, 'regenerated')
				else
					res.send(codeBadRequest, 'key is incorrect')

			# DocPad Exchange
			# http://docpad.org/exchange.json?version=6.32.0
			server.get '/exchange.json', (req,res) ->
				# Prepare
				branch = 'master'

				# Determine branch based on docpad version
				version = (req.query.version or '').split('.')
				if version
					if version[0] is '5'
						if version[1] is '3'
							branch = 'docpad-5.3.x'
						else
							branch = 'docpad-5.x'
					else if version[0] is '6'
						branch = 'docpad-6.x'

				# Redirect
				res.redirect(codeRedirectPermanent, "https://raw.github.com/bevry/docpad-extras/#{branch}/exchange.json")

			# Latest
			server.get '/latest.json', (req,res) ->
				res.redirect(codeRedirectPermanent, "https://raw.github.com/bevry/docpad/master/package.json")

			# Short Links
			server.get /^\/(plugins|upgrade|install|troubleshoot)\/?$/, (req,res) ->
				relativeUrl = req.params[0] or ''
				res.redirect(codeRedirectPermanent, "#{siteUrl}/docs/#{relativeUrl}")

			# Content
			server.get /^\/docpad(?:\/(.*))?$/, (req,res) ->
				relativeUrl = req.params[0] or ''
				res.redirect(codeRedirectPermanent, "#{siteUrl}/docs/#{relativeUrl}")

			# Bevry Content
			server.get /^\/((?:tos|terms|privacy|node|joe|query-?engine).*)$/, (req,res) ->
				relativeUrl = req.params[0] or ''
				res.redirect(codeRedirectPermanent, "http://bevry.me/#{relativeUrl}")

			# GitHub
			# /(g|github|bevry/docpad)/#{path}
			server.get /^\/(?:g|github|bevry\/docpad)(?:\/(.*))?$/, (req,res) ->
				relativeUrl = req.params[0] or ''
				res.redirect(codeRedirectPermanent, "https://github.com/bevry/docpad/#{relativeUrl}")

			# Issues
			# /(i|issue)/#{issue}
			server.get /^\/(?:i|issues)(?:\/(.*))?$/, (req,res) ->
				relativeUrl = req.params[0] or ''
				res.redirect(codeRedirectPermanent, "https://github.com/bevry/docpad/issues/#{relativeUrl}")

			# Edit
			server.get /^\/(?:e|edit)(?:\/docs)?\/(.+)$/, (req,res,next) ->
				fileRelativeUrl = '/docs/'+req.params[0]
				console.log 'edit', fileRelativeUrl
				docpad.getFileByRoute fileRelativeUrl, (err, file) ->
					console.log 'err', file
					return docpad.serverMiddleware404(req, res, next)  if err or !file
					fileEditUrl = file.get('editUrl')
					console.log 'url', fileEditUrl
					return docpad.serverMiddleware500(req, res, next)  if !fileEditUrl
					return res.redirect(codeRedirectPermanent, fileEditUrl)

			# Plugins
			# /(p|plugin)/#{pluginName}
			server.get /^\/(?:p|plugin)\/(.+)$/, (req,res) ->
				plugin = req.params[0]
				res.redirect(codeRedirectPermanent, "https://github.com/docpad/docpad-plugin-#{plugin}")

			# Plugins via Full
			# /(docs/)?docpad-plugin-#{pluginName}
			server.get /^\/(?:docs\/)?docpad-plugin-(.+)$/, (req,res) ->
				plugin = req.params[0]
				res.redirect(codeRedirectPermanent, "https://github.com/docpad/docpad-plugin-#{plugin}")

			# License
			server.get '/license', (req,res) ->
				res.redirect(codeRedirectPermanent, "https://github.com/bevry/docpad/blob/master/LICENSE.md#readme")

			# Changes
			server.get '/changes', (req,res) ->
				res.redirect(codeRedirectPermanent, "https://github.com/bevry/docpad/blob/master/HISTORY.md#readme")

			# Chat Guidelines
			server.get '/chat-guidelines', (req,res) ->
				res.redirect(codeRedirectPermanent, "https://github.com/bevry/docpad/issues/384")

			# Chat Logs
			server.get '/chat-logs', (req,res) ->
				res.redirect(codeRedirectPermanent, "https://botbot.me/freenode/docpad/")

			# Chat
			server.get '/chat', (req,res) ->
				res.redirect(codeRedirectPermanent, "http://webchat.freenode.net/?channels=docpad")

			# Donate
			# /(donate|gittip)
			server.get /^\/(?:donate|gittip)$/, (req,res) ->
				res.redirect(codeRedirectPermanent, "https://www.gittip.com/docpad/")

			# Gittip Community
			server.get '/gittip-community', (req,res) ->
				res.redirect(codeRedirectPermanent, "https://www.gittip.com/for/docpad/")

			# Google+
			# /(google+|+)
			server.get /^\/(?:google\+|\+)$/, (req,res) ->
				res.redirect(codeRedirectPermanent, "https://plus.google.com/communities/102027871269737205567")

			# Forum
			# /(forum|stackoverflow)
			server.get /^\/(?:forum|stackoverflow)$/, (req,res) ->
				res.redirect(codeRedirectPermanent, "http://stackoverflow.com/questions/tagged/docpad")

			# Done
			return


# Export our DocPad Configuration
module.exports = docpadConfig
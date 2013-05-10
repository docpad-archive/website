# Require
fsUtil = require('fs')
pathUtil = require('path')
moment = require('moment')
strUtil = require('underscore.string')
getContributors = require('getcontributors')
balUtil = require('bal-util')
extendr = require('extendr')

# Prepare
rootPath = __dirname+'/../..'
appPath = __dirname
sitePath = rootPath+'/site'
textData = balUtil.requireFresh(appPath+'/templateData/text')
navigationData = balUtil.requireFresh(appPath+'/templateData/navigation')
websiteVersion = require(rootPath+'/package.json').version



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

		text: textData
		navigation: navigationData


		# -----------------------------
		# Site Properties

		site:
			# The production URL of our website
			url: "http://docpad.org"

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
				facebookLikeButton:
					applicationId: '266367676718271'
				twitterTweetButton: 'docpad'
				twitterFollowButton: 'docpad'
				disqus: 'docpad'
				ircwebchat: 'docpad'
				gauges: '50dead2bf5a1f541d7000008'
				googleAnalytics: 'UA-35505181-2'
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


	# =================================
	# Collections

	collections:

		# Fetch all documents that exist within the docs directory
		# And give them the following meta data based on their file structure
		# [\-0-9]+#{category}/[\-0-9]+#{name}.extension
		docs: (database) ->
			query =
				relativeOutDirPath: $startsWith: 'docs'
				body: $ne: ""
			sorting = [categoryDirectory:1, filename:1]
			database.findAllLive(query,sorting).on 'add', (document) ->
				# Prepare
				a = document.attributes

				# Properties
				layout = 'doc'
				standalone = true
				categoryDirectory = pathUtil.basename pathUtil.dirname(a.fullPath)
				category = categoryDirectory.replace(/^[\-0-9]+/,'')
				categoryName = getCategoryName(category)
				name = a.basename.replace(/^[\-0-9]+/,'')
				urls = ["/docs/#{name}", "/docs/#{category}-#{name}", "/docpad/#{name}"]
				title = "#{a.title or humanize name}"
				pageTitle = "#{title} | #{categoryName}"
				editUrl = "https://github.com/bevry/docpad-documentation/edit/master/" + a.relativePath.replace('docs/','')

				# Apply
				document.setMetaDefaults({
					title
					pageTitle
					layout
					categoryDirectory
					category
					categoryName
					url: urls[0]
					standalone
					editUrl
				}).addUrl(urls)

		pages: (database) ->
			database.findAllLive({relativeOutDirPath:'pages'},[filename:1])


	# =================================
	# Plugins

	# Alias stylus highlighting to css and there is no inbuilt stylus support
	plugins:
		highlightjs:
			aliases:
				stylus: 'css'
		feedr:
			feeds:
				latestPackage: url: 'http://docpad.org/latest.json'
				exchange: url: 'http://docpad.org/exchange.json'
				#'twitter-favorites': url: 'https://api.twitter.com/1.1/favorites/list.json?screen_name=docpad&count=200&include_entities=true'

		repocloner:
			repos: [
				name: 'DocPad Documentation'
				path: 'src/documents/docs'
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

		# Add Contributors to the Template Data
		extendTemplateData: (opts,next) ->
			# Prepare
			docpad = @docpad
			contributors = {}
			opts.templateData.contributors = []

			# Fetch Contributors
			getContributors(
				users: ['bevry','docpad']
				github_client_id: process.env.BEVRY_GITHUB_CLIENT_ID
				github_client_secret: process.env.BEVRY_GITHUB_CLIENT_ID
				log: docpad.log
				next: (err,contributors) ->
					return next(err)  if err
					opts.templateData.contributors = contributors.filter (item) -> item.username isnt 'balupton'
					return next()
			)

			# Done
			return

		# Server Extend
		# Used to add our own custom routes to the server before the docpad routes are added
		serverExtend: (opts) ->
			# Extract the server from the options
			{server,express} = opts
			docpad = @docpad
			request = require('request')

			# Pushover - Optional
			# Called by the 404 page to alert our mobile phone of missing pages
			server.all '/pushover', (req,res) ->
				return res.send(200)  if 'development' in docpad.getEnvironments() or process.env.BEVRY_PUSHOVER_TOKEN? is false
				request(
					{
						url: "https://api.pushover.net/1/messages.json"
						method: "POST"
						form: extendr.extend(
							{
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
					docpad.action('generate')
					res.send(200, 'regenerated')
				else
					res.send(400, 'key is incorrect')

			# DocPad Exchange
			# http://docpad.org/exchange.json?version=6.32.0
			server.get '/exchange.json', (req,res) ->
				# Prepare
				branch = 'master'

				# Determine branch based on docpad version
				version = req.query.version.split('.')
				if version
					if version[0] is '5'
						if version[1] is '3'
							branch = 'docpad-5.3.x'
						else
							branch = 'docpad-5.x'
					else if version[0] is '6'
						branch = 'docpad-6.x'

				# Redirect
				res.redirect(301, "https://raw.github.com/bevry/docpad-extras/#{branch}/exchange.json")

			# DocPad Short Links
			server.get /^\/(plugins|upgrade|install|troubleshoot)\/?$/, (req,res) ->
				relativeUrl = req.params[0] or ''
				res.redirect(301, "http://docpad.org/docs/#{relativeUrl}")

			# DocPad Content
			server.get /^\/docpad(?:\/(.*))?$/, (req,res) ->
				relativeUrl = req.params[0] or ''
				res.redirect(301, "http://docpad.org/docs/#{relativeUrl}")

			# Bevry Content
			server.get /^\/((?:support|node|joe|query-?engine).*)$/, (req,res) ->
				relativeUrl = req.params[0] or ''
				res.redirect(301, "http://bevry.me/#{relativeUrl}")

			# GitHub
			server.get /^\/(?:g|github)(?:\/(.*))?$/, (req,res) ->
				issueQuery = req.params[0] or ''
				res.redirect(301, "https://github.com/bevry/docpad/#{issueQuery}")

			# Issues
			server.get /^\/(?:i|issues)(?:\/(.*))?$/, (req,res) ->
				issueQuery = req.params[0] or ''
				res.redirect(301, "https://github.com/bevry/docpad/issues/#{issueQuery}")

			# Plugins
			server.get /^\/(?:p|plugin)(?:\/(.*))?$/, (req,res) ->
				plugin = req.params[0] or ''
				res.redirect(301, "https://github.com/docpad/docpad-plugin-#{plugin}")

			# Done
			return


# Export our DocPad Configuration
module.exports = docpadConfig
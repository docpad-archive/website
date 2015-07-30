# Require
fsUtil = require('fs')
pathUtil = require('path')

# Prepare
textData =
	heading: "DocPad"
	copyright: '''
		DocPad is a <a href="http://bevry.me" title="Bevry - An open company and community dedicated to empowering developers everywhere.">Bevry</a> creation.
		'''

	linkNames:
		main: "Website"
		learn: "Learn"
		email: "Email"
		twitter: "Twitter"

		support: "Support"
		showcase: "Showcase"

	projectNames:
		docpad: "DocPad"
		node: "Node.js"
		queryengine: "Query Engine"

	categoryNames:
		start: "Getting Started"
		community: "Community"
		core: "Core"
		extend: "Extend"
		handsonnode: "Hands on with Node"
navigationData =
	top:
		'Intro': '/docs/intro'
		'Install': '/docs/install'
		'Start': '/docs/start'
		'Showcase': '/docs/showcase'
		'Plugins': '/docs/plugins'
		'Documentation': '/docs'

	bottom:
		'DocPad': '/'
		'GitHub': 'https://github.com/docpad/docpad'
		'Support': '/support'
websiteVersion = require('./package.json').version
docpadVersion = require('./package.json').dependencies.docpad.toString().replace('~', '').replace('^', '')
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
	return require('underscore.string').humanize text.replace(/^[\-0-9]+/,'').replace(/\..+/,'')


# =================================
# Configuration


# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
docpadConfig =

	# =================================
	# DocPad Configuration

	# Regenerate each day
	regenerateEvery: 1000*60*60*24


	# =================================
	# Template Data
	# These are variables that will be accessible via our templates
	# To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

	templateData:

		# -----------------------------
		# Misc

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

				travisStatusButton: 'docpad/docpad'
				furyButton: 'docpad'
				gittipButton: 'docpad'
				flattrButton: '344188/balupton-on-Flattr'
				paypalButton: 'QB8GQPZAH84N6'

				facebookLikeButton:
					applicationId: '266367676718271'
				twitterTweetButton: 'docpad'
				twitterFollowButton: 'docpad'
				githubStarButton: 'docpad/docpad'

				#disqus: 'docpad'
				#gauges: '50dead2bf5a1f541d7000008'
				googleAnalytics: 'UA-35505181-2'
				#inspectlet: '746529266'
				#mixpanel: 'd0f9b33c0ec921350b5419352028577e'
				#reinvigorate: '89t63-62ne18262h'

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


	# =================================
	# Plugins

	# Alias stylus highlighting to css and there is no inbuilt stylus support
	plugins:
		highlightjs:
			aliases:
				stylus: 'css'

		feedr:
			feeds:
				latestPackage:
					url: "http://helper.docpad.org/latest.json"
					parse: 'json'
				exchange:
					url: "http://helper.docpad.org/exchange.cson?version=6.78.0"# #{docpadVersion}"
					parse: 'cson'
				#'twitter-favorites': url: 'https://api.twitter.com/1.1/favorites/list.json?screen_name=docpad&count=200&include_entities=true'

		repocloner:
			repos: [
				name: 'DocPad Documentation'
				path: 'src/documents/learn/docpad/documentation'
				url: 'https://github.com/bevry/docpad-documentation.git'
			]

		cleanurls:
			# Common Redirects
			simpleRedirects:
				'/license': '/g/blob/master/LICENSE.md#readme'
				'/chat-logs': 'https://botbot.me/freenode/docpad/'
				'/chat': 'http://webchat.freenode.net/?channels=docpad'
				'/changelog': '/g/blob/master/HISTORY.md#readme'
				'/changes': '/changelog'
				'/history': '/changelog'
				'/bug-report': '/docs/support#bug-reports-via-github-s-issue-tracker'
				'/forum': 'http://stackoverflow.com/questions/tagged/docpad'
				'/stackoverflow': '/forum'
				'/google+': 'https://plus.google.com/communities/102027871269737205567'
				'/+': '/google+'
				'/gittip-community': '/gratipay-community'
				'/gittip': '/gratipay'
				'/donate': '/gratipay'
				'/gratipay-community': 'https://www.gratipay.com/for/docpad/'
				'/gratipay': 'https://www.gratipay.com/docpad/'
				'/flattr': 'http://flattr.com/thing/344188/balupton-on-Flattr'
				'/praise': 'https://twitter.com/docpad/favorites'
				'/growl': 'http://growl.info/downloads'
				'/partners': '/docs/support#support-consulting-partners'
				'/contributors': '/docs/participate#contributors'
				'/docs/start': '/docs/begin'
				'/get-started': '/docs/overview'
				'/chat-guidelines': '/i/384'
				'/unstable-node': '/i/725'
				'/render-early-via-include': '/i/378'
				'/extension-not-rendering': '/i/192'
				'/plugin-conventions': '/i/313'
				'/plugin-uncompiled': '/i/925'

			advancedRedirects: [
				# Old URLs
				[/^https?:\/\/(?:refresh\.docpad\.org|herokuapp\.com|docpad\.github\.io\/website)(.*)$/, 'https://docpad.org$1']

				# Short Links
				[/^\/(plugins|upgrade|install|troubleshoot)\/?$/, '/docs/$1']

				# Content
				# /docpad[/#{relativeUrl}]
				[/^\/docpad(?:\/(.*))?$/, '/docs/$1']

				# Bevry Content
				[/^\/((?:tos|terms|privacy).*)$/, 'https://bevry.me/$1']

				# Learning Centre Content
				[/^\/((?:node|joe|query-?engine).*)$/, 'https://learn.bevry.me/$1']

				# GitHub
				# /(g|github|bevry/docpad)[/#{path}]
				[/^\/(?:g|github|bevry\/docpad)(?:\/(.*))?$/, 'https://github.com/docpad/docpad/$1']

				# Twitter
				[/^\/(?:t|twitter|tweet)(?:\/(.*))?$/, 'https://twitter.com/docpad']

				# Issues
				# /(i|issue)[/#{issue}]
				[/^\/(?:i|issues)(?:\/(.*))?$/, 'https://github.com/docpad/docpad/issues/$1']

				# Plugins
				# /(p|plugin)/#{pluginName}
				[/^\/(?:p|plugin)\/(.+)$/, 'https://github.com/docpad/docpad-plugin-$1']

				# Plugins via Full (legacy)
				# /(docs/)?docpad-plugin-#{pluginName}
				[/^\/(?:docs\/)?docpad-plugin-(.+)$/, 'https://github.com/docpad/docpad-plugin-$1']
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

		# Extend Template data
		extendTemplateData: (opts) ->
			opts.templateData.moment = require('moment')
			opts.templateData.strUtil = require('underscore.string')

			# Return
			return true

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

# Export our DocPad Configuration
module.exports = docpadConfig

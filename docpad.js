/* eslint camelcase:0 */
'use strict'

// Require
const moment = require('moment')
const strUtil = require('underscore.string')
const fsUtil = require('fs')
const pathUtil = require('path')

// Prepare
const textData = {
	heading: 'DocPad',
	copyright: 'DocPad is a <a href="http://bevry.me" title="Bevry - An open company and community dedicated to empowering developers everywhere.">Bevry</a> creation.',

	linkNames: {
		main: 'Website',
		learn: 'Learn',
		email: 'Email',
		twitter: 'Twitter',

		support: 'Support',
		showcase: 'Showcase'
	},

	projectNames: {
		docpad: 'DocPad',
		node: 'Node.js',
		queryengine: 'Query Engine'
	},

	categoryNames: {
		start: 'Getting Started',
		community: 'Community',
		core: 'Core',
		extend: 'Extend',
		handsonnode: 'Hands on with Node'
	}
}

const navigationData = {
	top: {
		Intro: '/docs/intro',
		Install: '/docs/install',
		Start: '/docs/start',
		Showcase: '/docs/showcase',
		Plugins: '/docs/plugins',
		Documentation: '/docs/'
	},

	bottom: {
		DocPad: '/',
		GitHub: 'https://github.com/docpad/docpad',
		Support: '/support'
	}
}

const websiteVersion = require('./package.json').version
const docpadVersion = require('./package.json').dependencies.docpad.toString().replace('~', '').replace('^', '')
const exchangeUrl = `http://helper.docpad.org/exchange.cson?version=${docpadVersion}`
const siteUrl = process.env.NODE_ENV === 'production' ? 'http://docpad.org' : 'http://localhost:9778'



// =================================
// Helpers

// Humanize
function humanize (text = '') {
	return require('underscore.string').humanize(
		text.replace(/^[-0-9]+/, '').replace(/\..+/, '')
	)
}

// Titles
function getName (a, b) {
	if ( b == null ) {
		return textData[b] || humanize(b)
	}
	else {
		return textData[a][b] || humanize(b)
	}
}
function getProjectName (project) {
	return getName('projectNames', project)
}
function getCategoryName (category) {
	return getName('categoryNames', category)
}
function getLinkName (link) {
	return getName('linkNames', link)
}
function getLabelName (label) {
	return getName('labelNames', label)
}


// =================================
// Configuration


// The DocPad Configuration File
// It is simply a CoffeeScript Object which is parsed by CSON
const docpadConfig = {

	// =================================
	// Template Data
	// These are variables that will be accessible via our templates
	// To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

	templateData: {

		// -----------------------------
		// Misc

		text: textData,
		navigation: navigationData,
		moment,
		strUtil,

		// The URL we use to fetch the exchange data, included in template data for debugging
		exchangeUrl,


		// -----------------------------
		// Site Properties

		site: {
			// The production URL of our website
			url: siteUrl,

			// The default title of our website
			title: 'DocPad - Streamlined Web Development',

			// The website description (for SEO)
			description: 'Empower your website frontends with layouts, meta-data, pre-processors (markdown, jade, coffeescript, etc.), partials, skeletons, file watching, querying, and an amazing plugin system. Use it either standalone, as a build script, or even as a module in a bigger system. Either way, DocPad will streamline your web development process allowing you to craft full-featured websites quicker than ever before.',

			// The website keywords (for SEO) separated by commas
			keywords: 'bevry, bevryme, balupton, benjamin lupton, docpad, node, node.js, javascript, coffeescript, query engine, queryengine, backbone.js, cson',

			// Styles
			styles: [
				'/vendor/normalize.css',
				'/vendor/h5bp.css',
				'/vendor/highlight.css',
				'/styles/style.css'
			].map(function (url) {
				return `${url}?websiteVersion=${websiteVersion}`
			}),

			// Script
			scripts: [
				'//cdnjs.cloudflare.com/ajax/libs/anchor-js/3.2.2/anchor.min.js'
			]
		},

		// -----------------------------
		// Helper Functions

		// Names
		getName,
		getProjectName,
		getCategoryName,
		getLinkName,
		getLabelName,

		// Get the prepared site/document title
		// Often we would like to specify particular formatting to our page's title
		// we can apply that formatting here
		getPreparedTitle () {
			// if we have a title, we should use it suffixed by the site's title
			if ( this.document.pageTitle !== false && this.document.title ) {
				return `${this.document.pageTitle || this.document.title} | ${this.site.title}`
			}
			// if we don't have a title, then we should just use the site's title
			else if ( this.document.pageTitle === false || this.document.title == null ) {
				return this.site.title
			}
		},

		// Get the prepared site/document description
		getPreparedDescription () {
			// if we have a document description, then we should use that, otherwise use the site's description
			return this.document.description || this.site.description
		},

		// Get the prepared site/document keywords
		getPreparedKeywords () {
			// Merge the document keywords with the site keywords
			this.site.keywords.concat(this.document.keywords || []).join(', ')
		},

		// Get Version
		getVersion (v, places = 1) {
			return v.split('.').slice(0, places).join('.')
		},

		// Read File
		readFile (relativePath) {
			/* eslint no-sync:0 */
			const path = this.document.fullDirPath + '/' + relativePath
			const result = fsUtil.readFileSync(path)
			if ( result instanceof Error ) {
				throw result
			}
			else {
				return result.toString()
			}
		},

		// Code File
		codeFile (relativePath, language) {
			language = language || pathUtil.extname(relativePath).substr(1)
			const contents = this.readFile(relativePath)
			return `<pre><code class="${language}">${contents}</code></pre>`
		}
	},


	// =================================
	// Collections

	collections: {

		// Fetch all documents that exist within the docs directory
		// And give them the following meta data based on their file structure
		// [\-0-9]+#{category}/[\-0-9]+#{name}.extension
		docs (database) {
			const query = {
				write: true,
				relativeOutDirPath: {
					$startsWith: 'learn/'
				},
				body: {
					$ne: ''
				}
			}
			const sorting = [
				{projectDirectory: 1},
				{categoryDirectory: 1},
				{filename: 1}
			]

			return database.findAllLive(query, sorting).on('add', function (document) {
				// Prepare
				const a = document.attributes

				// learn/#{organisation}/#{project}/#{category}/#{filename}
				const pathDetailsRegexString = `
					^
					.*?learn/
					(.+?)/        // organisation
					(.+?)/        // project
					(.+?)/        // category
					(.+?)\\.      // basename
					(.+?)         // extension
					$
				`.replace(/\/\/.+/g, '').replace(/\s/g, '')
				const pathDetailsRegex = new RegExp(pathDetailsRegexString)
				const pathDetails = pathDetailsRegex.exec(a.relativePath)

				// Properties
				const layout = 'doc'
				const standalone = true

				// Check if we are correctly structured
				if ( pathDetails != null ) {
					const organisationDirectory = pathDetails[1]
					const projectDirectory = pathDetails[2]
					const categoryDirectory = pathDetails[3]
					const basename = pathDetails[4]

					const organisation = organisationDirectory.replace(/[-0-9]+/, '')
					const organisationName = humanize(organisation)

					const project = projectDirectory.replace(/[-0-9]+/, '')
					const projectName = getProjectName(project)

					const category = categoryDirectory.replace(/^[-0-9]+/, '')
					const categoryName = getCategoryName(category)

					const name = basename.replace(/^[-0-9]+/, '')

					const title = `${a.title || humanize(name)}`
					const pageTitle = `${title} | DocPad`  // changed from bevry website

					const urls = [`/docs/${name}`, `/docs/${category}-${name}`, `/docpad/${name}`]

					const githubEditUrl = `https://github.com/${organisationDirectory}/${projectDirectory}/edit/master/`
					// const proseEditUrl = `http://prose.io/#${organisationDirectory}/${projectDirectory}/edit/master/`
					const editUrl = githubEditUrl + a.relativePath.replace(`learn/${organisationDirectory}/${projectDirectory}/`, '')

					// Apply
					document.setMetaDefaults({
						layout,
						standalone,

						name,
						title,
						pageTitle,

						url: urls[0],

						editUrl,

						organisationDirectory,
						organisation,
						organisationName,

						projectDirectory,
						project,
						projectName,

						categoryDirectory,
						category,
						categoryName
					}).addUrl(urls)
				}

				// Otherwise ignore this document
				else {
					/* eslint no-console:0 */
					console.log(`The document ${a.relativePath} was at an invalid path, so has been ignored`)
					document.setMetaDefaults({
						ignore: true,
						render: false,
						write: false
					})
				}
			})
		},

		partners (database) {
			const query = {relativeOutDirPath: 'learn/docpad/documentation/partners'}
			const sort = [{filename: 1}]
			return database.findAllLive(query, sort).on('add', function (document) {
				document.setMetaDefaults({write: false})
			})
		}
	},


	// =================================
	// Plugins

	// Alias stylus highlighting to css and there is no inbuilt stylus support
	plugins: {
		highlightjs: {
			aliases: {
				stylus: 'css'
			}
		},

		feedr: {
			feeds: {
				latestPackage: {
					url: 'http://helper.docpad.org/latest.json',
					parse: 'json'
				},
				exchange: {
					url: exchangeUrl,
					parse: 'cson'
				}
				// 'twitter-favorites': url: 'https://api.twitter.com/1.1/favorites/list.json?screen_name=docpad&count=200&include_entities=true'
			}
		},

		downloader: {
			downloads: [{
				name: 'HTML5 Boilerplate',
				path: 'src/raw/vendor/h5bp.css',
				url: 'https://rawgit.com/h5bp/html5-boilerplate/5.3.0/dist/css/main.css'
			}, {
				name: 'Normalize CSS',
				path: 'src/raw/vendor/normalize.css',
				url: 'https://rawgit.com/h5bp/html5-boilerplate/5.3.0/dist/css/normalize.css'
			}, {
				name: 'Highlight.js XCode Theme',
				path: 'src/raw/vendor/highlight.css',
				url: 'https://rawgit.com/isagalaev/highlight.js/8.0/src/styles/xcode.css'
			}]
		},

		repocloner: {
			repos: [{
				name: 'DocPad Documentation',
				path: 'src/documents/learn/docpad/documentation',
				url: 'https://github.com/bevry/docpad-documentation.git'
			}]
		},

		cleanurls: {
			// enable this for surge.sh deployment
			trailingSlashes: true,

			// Common Redirects
			simpleRedirects: {
				'/license': 'https://github.com/docpad/docpad/blob/master/LICENSE.md#readme',
				'/changelog': 'https://github.com/docpad/docpad/blob/master/HISTORY.md#readme',
				'/changes': '/changelog',
				'/history': '/changelog',
				'/chat-logs': 'https://botbot.me/freenode/docpad/',
				'/chat': 'https://discuss.bevry.me/tags/chat',
				// use /support-channels, as there is a /support documentation page
				'/support-channels': 'https://discuss.bevry.me/t/official-bevry-support-channels/63',
				'/bug-report': '/support-channels',
				'/forum': 'https://discuss.bevry.me/tags/docpad',
				'/stackoverflow': 'https://discuss.bevry.me/t/official-stack-overflow-support/61/3',
				'/donate': 'https://bevry.me/donate',
				'/gittip-community': '/donate',
				'/gittip': '/donate',
				'/gratipay-community': '/donate',
				'/gratipay': '/donate',
				'/flattr': '/donate',
				'/praise': 'https://twitter.com/docpad/favorites',
				'/growl': 'http://growl.info/downloads',
				'/partners': '/docs/support#support-consulting-partners',
				'/docs/start': '/docs/begin',
				'/get-started': '/docs/overview',
				'/chat-guidelines': '/i/384',
				'/unstable-node': '/i/725',
				'/render-early-via-include': '/i/378',
				'/extension-not-rendering': '/i/192',
				'/plugin-conventions': '/i/313',
				'/plugin-uncompiled': '/i/925',
				'/twitter': 'https://twitter.com/docpad',
				'/tweet': '/twitter',
				'/t': '/twitter'
			},

			advancedRedirects: [
				// Old URLs
				[/^https?:\/\/(?:refresh\.docpad\.org|docpad\.herokuapp\.com|docpad\.github\.io\/website)(.*)$/, 'https://docpad.org$1'],

				// Short Links
				[/^\/(plugins|upgrade|install|troubleshoot)\/?$/, '/docs/$1'],

				// Content
				// /docpad[/#{relativeUrl}]
				[/^\/docpad(?:\/(.*))?$/, '/docs/$1'],

				// Bevry Content
				[/^\/((?:tos|terms|privacy).*)$/, 'https://bevry.me/$1'],

				// Learning Centre Content
				[/^\/((?:node|joe|query-?engine).*)$/, 'https://learn.bevry.me/$1'],

				// GitHub
				// /(g|github|bevry/docpad)[/#{path}]
				[/^\/(?:g|github|bevry\/docpad)(?:\/(.*))?$/, 'https://github.com/docpad/docpad/$1'],

				// Issues
				// /(i|issue)[/#{issue}]
				[/^\/(?:i|issues)(?:\/(.*))?$/, 'https://github.com/docpad/docpad/issues/$1'],

				// Plugins
				// /(p|plugin)/#{pluginName}
				[/^\/(?:p|plugin)\/(.+)$/, 'https://github.com/docpad/docpad-plugin-$1'],

				// Plugins via Full (legacy)
				// /(docs/)?docpad-plugin-#{pluginName}
				[/^\/(?:docs\/)?docpad-plugin-(.+)$/, 'https://github.com/docpad/docpad-plugin-$1']
			]
		}
	}

}

// Don't use debug log level on travis as it outputs too much and travis complains
// https://travis-ci.org/docpad/website/builds/104133494
if ( process.env.TRAVIS ) {
	docpadConfig.logLevel = 6
}

// Export our DocPad Configuration
module.exports = docpadConfig

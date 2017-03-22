'use strict'

// Require
const helpers = require('outpatient')

// Prepare
const websiteVersion = require('./package.json').version
const docpadVersion = require('./package.json').dependencies.docpad.toString().replace('~', '').replace('^', '')
const exchangeUrl = `https://helper.docpad.org/exchange.cson?version=${docpadVersion}`
const siteUrl = process.env.NODE_ENV === 'production' ? 'https://docpad.org' : 'http://localhost:9778'


// =================================
// Configuration

// The DocPad Configuration File
const docpadConfig = {

	// =================================
	// Template Data
	// These are variables that will be accessible via our templates
	// To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

	templateData: {

		// -----------------------------
		// Misc

		text: {
			heading: 'DocPad',
			copyright: 'DocPad is a <a href="https://bevry.me" title="Bevry - An open company and community dedicated to empowering developers everywhere.">Bevry</a> creation.',

			linkNames: {
				main: 'Website',
				learn: 'Learn',
				email: 'Email',
				twitter: 'Twitter',

				support: 'Support',
				showcase: 'Showcase'
			}
		},

		navigation: {
			top: {
				Intro: '/docs/intro',
				Install: '/docs/install',
				Start: '/docs/begin',
				Showcase: '/docs/showcase',
				Plugins: '/docs/plugins',
				Documentation: '/docs/',
				Fund: '/donate/'
			},

			bottom: {
				DocPad: '/',
				GitHub: 'https://github.com/docpad/docpad',
				Support: '/support',
				Donate: '/donate/'
			}
		},

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

		services: {
			googleSearch: '000711355494423975011:mvl83obfzvq'
		}
	},


	// =================================
	// Collections

	collections: {
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
		feedr: {
			feeds: {
				latestPackage: {
					url: 'https://helper.docpad.org/latest.json',
					parse: 'json'
				},
				exchange: {
					url: exchangeUrl,
					parse: 'cson'
				}
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
				// community
				'/chat-guidelines': 'http://learn.bevry.me/community/chat-guidelines',
				'/chat-logs': 'https://botbot.me/freenode/docpad/',
				'/chat': 'https://discuss.bevry.me/tags/chat',
				'/support-channels': 'https://discuss.bevry.me/t/official-bevry-support-channels/63',
				'/bug-report': '/support-channels',
				'/forum': 'https://discuss.bevry.me/tags/docpad',
				'/stackoverflow': 'https://discuss.bevry.me/t/official-stack-overflow-support/61/3',
				'/donate': 'https://bevry.me/donate',
				
				// aliases
				'/gittip-community': '/donate',
				'/gittip': '/donate',
				'/gratipay-community': '/donate',
				'/gratipay': '/donate',
				'/flattr': '/donate',
				'/praise': 'https://twitter.com/docpad/favorites',
				'/growl': 'http://growl.info/downloads',
				'/plugins': '/docs/plugins',
				'/upgrade': '/docs/upgrade',
				'/install': '/docs/install',
				'/troubleshoot': '/docs/troubleshoot',
				'/partners': '/docs/support#support-consulting-partners',
				'/docs/start': '/docs/begin',
				'/get-started': '/docs/overview',
				
				// docpad
				'/license': 'https://github.com/docpad/docpad/blob/master/LICENSE.md#readme',
				'/changelog': 'https://github.com/docpad/docpad/blob/master/HISTORY.md#readme',
				'/changes': '/changelog',
				'/history': '/changelog',
				
				// issues
				'/unstable-node': 'https://github.com/docpad/docpad/issues/725',
				'/render-early-via-include': 'https://github.com/docpad/docpad/issues/378',
				'/extension-not-rendering': 'https://github.com/docpad/docpad/issues/192',
				'/plugin-conventions': 'https://github.com/docpad/docpad/issues/313',
				'/plugin-uncompiled': 'https://github.com/docpad/docpad/issues/925',
				
				// social
				'/twitter': 'https://twitter.com/docpad'
			},

			advancedRedirects: [
				// Old URLs
				[/^https?:\/\/(?:refresh\.docpad\.org|docpad\.herokuapp\.com|docpad\.github\.io\/website)(.*)$/, 'https://docpad.org$1'],

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

// Apply our helpers to the docpad configuration
helpers({
	config: {
		getUrl ({ name }) {
			return `/docs/${name}`
		},
		docs: {
			title: 'Documentation',
			url: '/docs/'
		},
		projects: {
			documentation: {
				title: 'DocPad Documentation',
				url: '/docs/',
				categories: {
					start: {
						title: 'Getting Started'
					},
					community: {
						title: 'Community'
					},
					core: {
						title: 'Core'
					},
					extend: {
						title: 'Extend'
					}
				}
			}
		}
	},
	docpadConfig
})

// Don't use debug log level on travis as it outputs too much and travis complains
// https://travis-ci.org/docpad/website/builds/104133494
if ( process.env.TRAVIS ) {
	docpadConfig.logLevel = 6
}

// Export our DocPad Configuration
module.exports = docpadConfig

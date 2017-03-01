/* global window, document, $, History */
/* eslint no-console:0, new-cap:0 */
'use strict'

// Prepare
function wait (delay, callback) {
	return setTimeout(callback, delay)
}

// BevryApp
class BevryApp {
	constructor () {
		// Prepare
		this.config = {}
		this.config.articleScrollOpts = {}
		this.config.sectionScrollOpts = {}

		// Bind all the functions
		const me = this
		Object.keys(this).forEach(function (method) {
			if ( me[method] && me[method].bind ) {
				me[method] = me[method].bind(me)
			}
		})

		// On dom ready
		$(this.onDomReady)
	}

	onDomReady () {
		// Prepare
		this.$document = $(document)
		this.$body = $(document.body)
		this.$window = $(window)
		this.$docnav = $('.docnav')
		this.$docnavUp = this.$docnav.find('.up')
		this.$docnavDown = this.$docnav.find('.down')
		this.$docSectionWrapper = $('<div class="section-wrapper">')
		this.$article = null
		this.$docHeaders = null

		// Link Click Events
		this.$body
			.on('click', 'a[href]:external', this.externalLinkClick)
			.on('click', '[data-href]', this.linkClick)

		// Anchor Change Event
		this.$window.on('anchorchange', this.anchorChange)

		// State Change Event
		this.$window.on('statechangecomplete', this.stateChange)

		// Always trigger initial page change
		this.$window.trigger('anchorchange')
		this.$window.trigger('statechangecomplete')

		// ScrollSpy
		if ( this.scrollSpy != null ) {
			setInterval(this.scrollSpy, 500)
		}

		// Resize
		if ( this.resize != null ) {
			$(window).on('resize', this.resize)
			this.resize()
		}
	}

	// Open Link
	// Open the URL in a specific way depending on the action
	openLink ({url, action}) {
		// Open the link in a new or current window depending on the action
		if ( action === 'new' ) {
			window.open(url, '_blank')
		}
		else if ( action === 'same' ) {
			wait(100, function () {
				document.location.href = url
			})
		}
		else if ( action === 'default' ) {
			// ignore, and handle by the browser
		}
		else {
			console.log('unknown link action', action)
		}

		// Chain
		return this
	}

	// Open Outbound Link
	// Open an outbound link and track the event
	openOutboundLink ({url, action}) {
		// https://developers.google.com/analytics/devguides/collection/gajs/eventTrackerGuide
		const hostname = url.replace(/^.+?\/+([^/]+).*$/, '$1')
		if ( window._gaq ) {
			window._gaq.push(['_trackEvent', 'Outbound Links', hostname, url, 0, true])
			this.openLink({url, action})
		}

		// Chain
		return this
	}

	// External Link Click
	// The handler for when an external link is clicked
	externalLinkClick (event) {
		// Prepare
		const $link = $(event.target)
		const url = $link.attr('href')
		let action = null
		if ( !url )  return this

		// Discover how we should handle the link
		if ( event.which === 2 || event.metaKey || event.shiftKey ) {
			action = 'default'
		}
		else {
			action = 'new'
			event.preventDefault()
		}

		// Open the link
		this.openOutboundLink({url, action})

		// Chain
		return this
	}

	// Link CLick
	// The handler for when a link is clicked
	linkClick (event) {
		// Prepare
		const $link = $(event.target)
		const url = $link.data('href')
		let action = null
		if ( !url )  return this

		// Discover how we should handle the link
		if ( event.which === 2 || event.metaKey ) {
			action = 'new'
		}
		else {
			action = 'same'
			event.preventDefault()
		}

		// Open the link
		if ( $link.is(':internal') ) {
			this.openLink({url, action})
		}
		else {
			this.openOutboundLink({url, action})
		}

		// Chain
		return this
	}

	// Previous Section
	// Go to the previous section in our documentation
	previousSection () {
		// Prepare
		const $docHeaders = this.$docHeaders
		if ( !$docHeaders )  return this

		// Handle
		const $current = $docHeaders.filter('.current')
		if ( $current.length ) {
			const $prev = $current.prevAll('h2:first')
			if ( $prev.length ) {
				$prev.click()
			}
			else {
				$docHeaders.filter('.current').removeClass('current')
				$docHeaders.last().click()
			}
		}

		// Chain
		return this
	}

	// Next Section
	// Go to the next section in our documentation
	nextSection () {
		// Prepare
		const $docHeaders = this.$docHeaders
		if ( !$docHeaders )  return this

		// Handle
		const $current = $docHeaders.filter('.current')
		if ( $current.length ) {
			const $next = $current.nextAll('h2:first')
			if ( $next.length ) {
				$next.click()
			}
			else {
				// $current.click()
				$docHeaders.first().click()
			}
		}
		else {
			$docHeaders.first().click()
		}

		// Chain
		return this
	}

	// Anchor Change
	anchorChange () {
		const hash = History.getHash()
		if ( !hash )  return this
		const el = document.getElementById(hash)
		if ( !el )  return this
		if ( el.className.indexOf('anchor-link') !== -1 ) {
			$(el).trigger('select')
		}
		else {
			$(el).ScrollTo(this.config.sectionScrollOpts)
		}
		return this
	}

	// State Change
	stateChange () {
		// Prepare
		const config = this.config
		const $docSectionWrapper = this.docSectionWrapper

		// Special handling for long docs
		const $article = this.$article = $('#content article:first')

		// Anchors
		if ( $article.is('.block.doc, .block.page') ) {
			$article.find('h1,h2,h3,h4,h5,h6').each(function () {
				if ( this.id ) {
					return
				}
				const id = (this.textContent || this.innerText || '').toLowerCase()
					.replace(/\s+/g, ' ')
					.replace(/[^a-zA-Z0-9]+/g, '-')
					.replace(/--+/g, '-')
					.replace(/^-|-$/g, '')
				if ( !id || document.getElementById(id) ) {
					return
				}
				this.id = id
				if ( !this.getAttribute('data-href') ) {
					this.setAttribute('data-href', '#' + id)
				}
				if ( this.className.indexOf('hover-link') === -1 ) {
					this.className += 'hover-link'
				}
			})
		}

		// Documentation
		if ( $article.is('.block.doc') ) {
			const $docHeaders = this.$docHeaders = $article.find('h2')

			// Compact
			if ( $article.is('.compact') ) {
				$docHeaders
					.addClass('hover-link anchor-link')
					.each(function (index) {
						const $header = $(this)
						$header.nextUntil('h2').wrapAll($docSectionWrapper.clone().attr('id', 'h2-' + index))
					})
					.on('select', function (event, opts) {
						$docHeaders.filter('.current').removeClass('current')
						const $header = $(this)
							.addClass('current')
							.stop(true, false).css({opacity: 0.5}).animate({opacity: 1}, 1000)
							.prevAll('.section-wrapper')
								.addClass('active')
								.end()
							.next('.section-wrapper')
								.addClass('active')
								.end()
						if ( !opts || opts.scroll !== false ) {
							$header.ScrollTo(config.sectionScrollOpts)
						}
					})
					.first().trigger('select', {scroll: false})
			}

			// Non-Compact
			else {
				$docHeaders
					.addClass('hover-link anchor-link')
					.on('select', function (event, opts) {
						$docHeaders.filter('.current').removeClass('current')
						const $header = $(this)
							.addClass('current')
							.stop(true, false).css({opacity: 0.5}).animate({opacity: 1}, 1000)
						if ( !opts || opts.scroll !== false ) {
							$header.ScrollTo(config.sectionScrollOpts)
						}
					})
			}
		}

		else {
			this.$docHeaders = null
		}

		// Scroll to the article
		$article.ScrollTo(config.articleScrollOpts)

		// Chain
		return this
	}

	// Scroll Spy
	scrollSpy () {
		// Handle
		const pageLeftToRead = document.height - (window.scrollY + window.innerHeight)
		const $articleNav = this.$article.find('.prev-next a.next')
		if ( pageLeftToRead <= 50 ) {
			$articleNav.css('opacity', 1)
		}
		else {
			$articleNav.removeAttr('style')
		}

		// Chain
		return this
	}
}

// Export
window.BevryApp = BevryApp

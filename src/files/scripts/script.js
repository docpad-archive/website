/* global window, document, $ */
/* eslint no-console:0, new-cap:0 */
'use strict'

// App
class App extends window.BevryApp {

	// Constructor
	constructor () {
		// Prepare
		super()

		// Apply
		this.config.articleScrollOpts = Object.assign(this.config.articleScrollOpts || {}, {
			offsetTop: 100
		})
		this.config.sectionScrollOpts = Object.assign(this.config.sectionScrollOpts || {}, {
			offsetTop: 80
		})
	}

	onDomReady (...args) {
		const me = this

		// On touch devices make clicking docpad show the sidebar
		if ( $('html').hasClass('no-touch') === false ) {
			$(document.body)
				.on('click touchstart', '.logo', function (e) {
					me.resize()
					$('.sidebar').addClass('active')
					e.preventDefault()
					return false
				})
				.on('click touchstart', '.container', function (e) {
					if ( $(e.target).parents('.topbar').length === 0 ) {
						$('.sidebar').removeClass('active')
					}
					return true
				})
		}

		// Forward
		return super.onDomReady(...args)
	}

	resize () {
		// Prepare
		const $sidebar = $('.sidebar')

		// Apply
		if ( $('html').hasClass('no-touch') ) {
			const $topbar = $('.topbar')
			const topbarHeight = $topbar.outerHeight()
			$sidebar.find('.list-menu').height($(window).height() - topbarHeight)
			$sidebar.css({top: topbarHeight})
		}
		else {
			$sidebar.find('.list-menu').height(parseInt($(window).height(), 10) + 50)
			$sidebar.css({top: 0})
		}

		// Chain
		return this
	}

	// State Change
	stateChange (event, data) {
		// Fetch
		const $sidebar = $('.sidebar').removeClass('active')

		// Ensure our sidebar activity is the same as the remote
		const $sidebarRemote = data && data.$dataBody && data.$dataBody.find('.sidebar')
		let $activeItemLocal = null
		if ( $sidebarRemote && $sidebarRemote.length ) {
			// Remove active menu and item
			$sidebar.find('.active').removeClass('active').addClass('inactive')

			// Discover active menu and item in rmeote
			const $activeMenuRemote = $sidebarRemote.find('.list-menu-category.active')
			const $activeItemRemote = $activeMenuRemote.find('.list-menu-item.active')

			// Update corresponding local menu and item to be active
			if ( $activeItemRemote && $activeItemRemote.length ) {
				const $activeMenuLocal = $sidebar.find('.list-menu-category').eq($activeMenuRemote.index()).removeClass('inactive').addClass('active')
				$activeItemLocal = $activeMenuLocal.find('.list-menu-item').eq($activeItemRemote.index()).removeClass('inactive').addClass('active')
			}
		}
		else {
			// Discover active menu and item in rmeote
			const $activeMenuLocal = $sidebar.find('.list-menu-category.active')
			$activeItemLocal = $activeMenuLocal.find('.list-menu-item.active')
		}

		// Resize
		this.resize()

		// Scroll to the active menu item
		if ( !$activeItemLocal || $activeItemLocal.length === 0 ) {
			$activeItemLocal = $sidebar.find('.list-menu-category:first').addClass('active')
		}
		$activeItemLocal.ScrollTo({
			onlyIfOutside: true
		})

		// Forward
		return super.stateChange(event, data)
	}
}

// Create
window.app = new App()

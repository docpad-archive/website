###
standalone: true
###

# App
class App extends BevryApp

	# Constructor
	constructor: ->
		# Prepare
		@config ?= {}
		@config.articleScrollOpts ?= {}
		@config.sectionScrollOpts ?= {}

		# Apply
		@config.articleScrollOpts.offsetTop = 100
		@config.sectionScrollOpts.offsetTop = 80

		# Forward
		super

	onDomReady: =>
		# On touch devices make clicking docpad show the sidebar
		if $('html').hasClass('no-touch') is false
			$(document.body)
				.on 'click touchstart', '.logo', (e) =>
					@resize()
					$('.sidebar').addClass('active')
					e.preventDefault()
					return false
				.on 'click touchstart', '.container', (e) ->
					if $(e.target).parents('.topbar').length is 0
						$('.sidebar').removeClass('active')
					return true

		# Forward
		super

	resize: =>
		# Prepare
		$sidebar = $('.sidebar')

		# Apply
		if $('html').hasClass('no-touch')
			$topbar = $('.topbar')
			topbarHeight = $topbar.outerHeight()
			$sidebar.find('.list-menu').height($(window).height() - topbarHeight)
			$sidebar.css(top: topbarHeight)
		else
			$sidebar.find('.list-menu').height(parseInt($(window).height(),10) + 50)
			$sidebar.css(top: 0)

		# Chain
		@

	# State Change
	stateChange: (event,data) =>
		# Fetch
		$sidebar = $('.sidebar').removeClass('active')

		# Ensure our sidebar activity is the same as the remote
		$sidebarRemote = data?.$dataBody?.find('.sidebar')
		if $sidebarRemote and $sidebarRemote.length isnt 0
			# Remove active menu and item
			$sidebar.find('.active').removeClass('active').addClass('inactive')

			# Discover active menu and item in rmeote
			$activeMenuRemote = $sidebarRemote.find('.list-menu-category.active')
			$activeItemRemote = $activeMenuRemote.find('.list-menu-item.active')

			# Update corresponding local menu and item to be active
			if $activeItemRemote and $activeItemRemote.length isnt 0
				$activeMenuLocal = $sidebar.find('.list-menu-category').eq($activeMenuRemote.index()).removeClass('inactive').addClass('active')
				$activeItemLocal = $activeMenuLocal.find('.list-menu-item').eq($activeItemRemote.index()).removeClass('inactive').addClass('active')
		else
			# Discover active menu and item in rmeote
			$activeMenuLocal = $sidebar.find('.list-menu-category.active')
			$activeItemLocal = $activeMenuLocal.find('.list-menu-item.active')

		# Resize
		@resize()

		# Scroll to the active menu item
		$activeItemLocal = $sidebar.find('.list-menu-category:first').addClass('active')  if !$activeItemLocal or $activeItemLocal.length is 0
		$activeItemLocal.ScrollTo({
			onlyIfOutside: true
		})

		# Forward
		super


# Create
app = new App()
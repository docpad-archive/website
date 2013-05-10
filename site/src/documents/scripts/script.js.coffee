###
standalone: true
###

# App
class App extends BevryApp

	# Constructor
	constructor: (args...) ->
		super args...
		@config.articleScrollOpts.offsetTop = 100
		@config.sectionScrollOpts.offsetTop = 80
		@

	# State Change
	stateChange: (event,data) =>
		# Check
		return super  unless data

		# Prepare
		$sidebarRemote = data.$dataBody.find('.sidebar')
		$sidebar = $('.sidebar')

		# Height Adjust
		if $sidebar.length isnt 0
			$bottombar = $('.bottombar')
			$sidebar.height $bottombar.offset().top - $sidebar.offset().top

		# Remote does not have sidebar so ensure we don't have it locally
		if $sidebarRemote.length is 0
			$sidebar.remove()

		# Remote has sidebar so ensure we have it locally
		else
			# Add our sidebar
			if $sidebar.length is 0
				$('.container').prepend($sidebarRemote)

			# Update our active menu and item
			else
				# Remove active menu and item
				$sidebar.find('.active').removeClass('active').addClass('inactive')

				# Discover active menu and item in rmeote
				$activeMenuRemote = $sidebarRemote.find('.list-menu-category.active')
				$activeItemRemote = $activeMenuRemote.find('.list-menu-item.active')

				# Update corresponding local menu and item to be active
				$activeMenuLocal = $sidebar.find('.list-menu-category').eq($activeMenuRemote.index()).removeClass('inactive').addClass('active')
				$activeItemLocal = $activeMenuLocal.find('.list-menu-item').eq($activeItemRemote.index()).removeClass('inactive').addClass('active')

		# Super
		super

	# Scroll Spy
	scrollSpy: =>
		# Handle
		sidebarFixed = window.scrollY > $('#content').offset().top
		$('.sidebar').toggleClass('fixed', sidebarFixed)

		# Super
		super


# Create
app = new App()
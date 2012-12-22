###
standalone: true
###

# App
class App extends BevryApp

	# State Change
	stateChange: (event,data) =>
		# Check
		return super  unless data

		# Prepare
		$navSecondaryRemote = data.$dataBody.find('.nav-secondary')
		$navSecondaryLocal = $('.nav-secondary')

		# Remote does not have navSecondary so ensure we don't have it locally
		if $navSecondaryRemote.length is 0
			$navSecondaryLocal.remove()

		# Remote has navSecondary so ensure we have it locally
		else
			# Add our navSecondary
			if $navSecondaryLocal.length is 0
				$('.container').prepend($navSecondaryRemote)

			# Update our active menu and item
			else
				# Remove active menu and item
				$navSecondaryLocal.find('.active').removeClass('active').addClass('inactive')

				# Discover active menu and item in rmeote
				$activeMenuRemote = $navSecondaryRemote.find('.list-menu-category.active')
				$activeItemRemote = $activeMenuRemote.find('.list-menu-item.active')

				# Update corresponding local menu and item to be active
				$activeMenuLocal = $navSecondaryLocal.find('.list-menu-category').eq($activeMenuRemote.index()).removeClass('inactive').addClass('active')
				$activeItemLocal = $activeMenuLocal.find('.list-menu-item').eq($activeItemRemote.index()).removeClass('inactive').addClass('active')

		# Super
		super

	# Scroll Spy
	scrollSpy: =>
		# Handle
		sidebarFixed = window.scrollY > $('#content').offset().top
		$('.nav-secondary').toggleClass('fixed', sidebarFixed)

		# Super
		super


# Create
app = new App()
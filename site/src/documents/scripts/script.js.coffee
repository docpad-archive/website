###
standalone: true
###

# App
class App extends BevryApp

	# Dom Ready
	onDomReady: =>
		$webchat = $('.webchat')
		$iframe = $webchat.find('iframe')
		$wrapper = $webchat.find('.wrapper')
		$close = $webchat.find('.close')
		$open = $webchat.find('.open')

		normalizeHeights = ->
			wrapperIsVisible = $wrapper.is(':visible')
			if wrapperIsVisible
				$webchat.add($iframe,$wrapper)
					.height Math.max($iframe.height(),500)
					.width  Math.max($iframe.width(),350)
			else
				$webchat.add($iframe,$wrapper)
					.height $open.height()
					.width  $open.width()

		$wrapper
			.hide()
			.resizable(
				alsoResize: $iframe
				handles: "e"
			)
			.on 'resizestart', ->
				$iframe.hide()
			.on 'resizestop', (event,ui) ->
				$webchat.add($iframe).height(ui.size.height)
				$webchat.add($iframe).width(ui.size.width)
				$iframe.show()
		$close.add($open)
			.on 'click', (event) ->
				event.preventDefault()
				event.stopImmediatePropagation()
				$wrapper.toggle()
				$open.toggle()
				normalizeHeights()

		$webchat.show()
		normalizeHeights()

		# Super
		super

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
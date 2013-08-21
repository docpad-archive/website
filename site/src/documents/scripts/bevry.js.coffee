###
standalone: true
###

# Prepare
wait = (delay,callback) -> setTimeout(callback,delay)

# BevryApp
class BevryApp

	config: null

	constructor: ->
		# Prepare
		@config ?= {}
		@config.articleScrollOpts ?= {}
		@config.sectionScrollOpts ?= {}

		# On dom ready
		$(@onDomReady)

		# Chain
		@

	onDomReady: =>
		# Prepare
		@$document = $(document)
		@$body = $(document.body)
		@$window = $(window)
		@$docnav = $('.docnav')
		@$docnavUp = @$docnav.find('.up')
		@$docnavDown = @$docnav.find('.down')
		@$docSectionWrapper = $('<div class="section-wrapper">')
		@$article = null
		@$docHeaders = null

		# Link Click Events
		@$body
			.on('click', 'a[href]:external', @externalLinkClick)
			.on('click', '[data-href]', @linkClick)

		# Anchor Change Event
		@$window.on('anchorchange', @anchorChange)

		# State Change Event
		@$window.on('statechangecomplete', @stateChange)

		# Always trigger initial page change
		@$window.trigger('anchorchange')
		@$window.trigger('statechangecomplete')

		# ScrollSpy
		if @scrollSpy?
			setInterval(@scrollSpy, 500)

		# Resize
		if @resize?
			$(window).on('resize', @resize)
			@resize()

		# Chain
		@

	# Open Link
	# Open the URL in a specific way depending on the action
	openLink: ({url,action}) ->
		# Open the link in a new or current window depending on the action
		if action is 'new'
			window.open(url,'_blank')
		else if action is 'same'
			wait(100, -> document.location.href = url)
		else if action is 'default'
			# ignore, and handle by the browser
		else
			console?.log?('unknown link action', action)

		# Chain
		@

	# Open Outbound Link
	# Open an outbound link and track the event
	openOutboundLink: ({url,action}) ->
		# https://developers.google.com/analytics/devguides/collection/gajs/eventTrackerGuide
		hostname = url.replace(/^.+?\/+([^\/]+).*$/,'$1')
		window._gaq?.push(['_trackEvent', "Outbound Links", hostname, url, 0, true])
		@openLink({url,action})

		# Chain
		@

	# External Link Click
	# The handler for when an external link is clicked
	externalLinkClick: (event) =>
		# Prepare
		$link = $(event.target)
		url = $link.attr('href')
		return @  unless url

		# Discover how we should handle the link
		if event.which is 2 or event.metaKey or event.shiftKey
			action = 'default'
		else
			action = 'new'
			event.preventDefault()

		# Open the link
		@openOutboundLink({url,action})

		# Chain
		@

	# Link CLick
	# The handler for when a link is clicked
	linkClick: (event) =>
		# Prepare
		$link = $(event.target)
		url = $link.data('href')
		return  unless url

		# Discover how we should handle the link
		if event.which is 2 or event.metaKey
			action = 'new'
		else
			action = 'same'
			event.preventDefault()

		# Open the link
		if $link.is(':internal')
			@openLink({url,action})
		else
			@openOutboundLink({url,action})

		# Done
		return

	# Previous Section
	# Go to the previous section in our documentation
	previousSection: ->
		# Prepare
		{$docHeaders} = @

		# Check
		return  unless $docHeaders?

		# Handle
		$current = $docHeaders.filter('.current')
		if $current.length
			$prev = $current.prevAll('h2:first')
			if $prev.length
				$prev.click()
			else
				$docHeaders.filter('.current').removeClass('current')
				$docHeaders.last().click()

		# Chain
		@

	# Next Section
	# Go to the next section in our documentation
	nextSection: ->
		# Prepare
		{$docHeaders} = @

		# Check
		return  unless $docHeaders?

		# Handle
		$current = $docHeaders.filter('.current')
		if $current.length
			$next = $current.nextAll('h2:first')
			if $next.length
				$next.click()
			else
				#$current.click()
				$docHeaders.first().click()
		else
			$docHeaders.first().click()

		# Chain
		@

	# Anchor Change
	anchorChange: =>
		hash = History.getHash()
		return  unless hash
		el = document.getElementById(hash)
		return  unless el
		if el.tagName.toLowerCase() is 'h2'
			$(el).trigger('select')
		else
			$(el).ScrollTo(@config.sectionScrollOpts)

	# State Change
	stateChange: =>
		# Prepare
		{$docHeaders,$docSectionWrapper,config} = @

		# Special handling for long docs
		@$article = $article = $('#content article:first')

		# Documentation
		if $article.is('.block.doc')
			$article.find('h1,h2,h3,h4,h5,h6').each ->
				return  if @id
				id = (@textContent or @innerText or '').toLowerCase().replace(/\s+/g,' ').replace(/[^a-zA-Z0-9]+/g,'-').replace(/--+/g,'-').replace(/^-|-$/g,'')
				return  if !id or document.getElementById(id)
				@id = id
				@setAttribute('data-href', '#'+@id)  unless @getAttribute('data-href')
				@className += 'hover-link'  unless @className.indexOf('hover-link') isnt -1

			@$docHeaders = $docHeaders = $article.find('h2')

			# Compact
			if $article.is('.compact')
				$docHeaders
					.addClass('hover-link')
					.each (index) ->
						$header = $(this)
						$header.nextUntil('h2').wrapAll($docSectionWrapper.clone().attr('id','h2-'+index))
					.on 'select', (event,opts) ->
						$docHeaders.filter('.current').removeClass('current')
						$header = $(this)
							.addClass('current')
							.stop(true,false).css({'opacity':0.5}).animate({opacity:1},1000)
							.prevAll('.section-wrapper')
								.addClass('active')
								.end()
							.next('.section-wrapper')
								.addClass('active')
								.end()
						$header.ScrollTo(config.sectionScrollOpts)  if !opts or opts.scroll isnt false
					.first()
						.trigger('select',{scroll:false})

			# Non-Compact
			else
				$docHeaders
					.addClass('hover-link')
					.on 'select', (event,opts) ->
						$docHeaders.filter('.current').removeClass('current')
						$header = $(this)
							.addClass('current')
							.stop(true,false).css({'opacity':0.5}).animate({opacity:1},1000)
						$header.ScrollTo(config.sectionScrollOpts)  if !opts or opts.scroll isnt false

		else
			@$docHeaders = $docHeaders = null

		# Scroll to the article
		$article.ScrollTo(config.articleScrollOpts)

		# Chain
		@

	# Scroll Spy
	scrollSpy: =>
		# Handle
		pageLeftToRead = document.height - (window.scrollY + window.innerHeight)
		$articleNav = @$article.find('.prev-next a.next')
		if pageLeftToRead <= 50
			$articleNav.css('opacity',1)
		else
			$articleNav.removeAttr('style')

		# Chain
		@

# Export
@BevryApp = BevryApp
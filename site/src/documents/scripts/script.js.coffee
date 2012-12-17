###
standalone: true
###

# History.js
# Prepare
History = window.History

return unless History?.enabled

$ = window.jQuery
document = window.document

$ ->
	# Prepare
	$document = $(document)
	$body = $(document.body)
	$window = $(window)
	$mainnav = $('#nav-main')
	$secondarynav = $('#nav-secondary')
	$footernav = $('#nav-footer')
	$docnav = $('.docnav')
	$docnavUp = $docnav.find('.up')
	$docnavDown = $docnav.find('.down')
	$docSectionWrapper = $('<div class="section-wrapper">')
	$article = null
	$docHeaders = null
	wait = (delay,callback) -> setTimeout(callback,delay)

	rootUrl = History.getRootUrl()
	scrollOptions = {
		duration: 400
		easing: 'swing'
	}

	# History.js It! Helpers
	# HTML helper
	documentHtml = (html) ->
		return String(html)
			.replace(/<\!DOCTYPE[^>]*>/i, '')
			.replace(/<(html|head|body|title|meta|script)([\s\>])/gi,'<div class="document-$1"$2')
			.replace(/<\/(html|head|body|title|meta|script)\>/gi,'</div>')

	# Internal Link Helper
	isInternalLink = (url) ->
		return url.substring(0, rootUrl.length) is rootUrl or url.indexOf(':') is -1

	# jQuery Internal Link Selector Helper
	$.expr[':'].internal = (obj, index, meta, stack) ->
		$this = $(obj)
		url = $this.attr('href') or $this.data('href') or ''

		return isInternalLink(url)

	# jQuery External Link Selector Helper
	$.expr[':'].external = (obj, index, meta, stack) ->
		return not $.expr[':'].internal(obj, index, meta, stack)

	# jQuery Ajaxify helper
	$.fn.ajaxify = ->
		# Prepare
		$this = $(@)
		# Ajaxify
		$this.on 'click', 'a:internal:not(.no-ajaxy)', (event) ->
			# Prepare
			$this = $(@)
			url = $this.attr('href')
			title = $this.attr('title') or null

			# Continue as normal for Cmd Clicks, etc
			return true if event.which is 2 or event.metaKey

			# Ajaxify this link
			History.pushState(null, title, url)
			event.preventDefault()
			return false

		# Chain
		$this


	# Links
	# jQuery Fix Legacy Links Helper
	$.fn.fixLegacyLinks = ->
		legacyUrls = {
			'/docpad': '/docs'
			'/node': 'http://bevry.me/node'
			'/query-engine': 'http://bevry.me/query-engine'
			'/joe': 'http://bevry.me/joe'
		}

		# Prepare
		$this = $(@)

		for own oldUrl, newUrl of legacyUrls
			# Replace the old URL with the new URL
			$this.find("a[href^=\"#{oldUrl}\"]").each ->
				$link = $(@)
				oldHref = $link.attr('href')
				newHref = newUrl + oldHref.substring(oldUrl.length)
				$link.attr('href', newHref)

		# Chain
		$this

	# Ajaxify the internal links
	$body.fixLegacyLinks().ajaxify()

	# Change active link in menu helper
	activateLinksInMenu = ($menu, activeUrlPart) ->
		$menu.find('a.active').removeClass('active')
		$activeMenuLink = $menu.find("a[href=\"#{activeUrlPart}\"]")
		if $activeMenuLink.length is 1
			$activeMenuLink.addClass('active')
		else
			$activeMenuLink = $menu.find("a[href^=\"#{activeUrlPart}\"]")
			if $activeMenuLink.length is 1
				$activeMenuLink.addClass('active')

		# Done
		return

	openLink = (url, event) ->
		return  unless url and event

		# Discover how we should handle the link
		if event.which is 2 or event.metaKey
			action = 'default'
		else
			action = 'same'
			event.preventDefault()

		if isInternalLink(url)
			openInternalLink(url, action)
		else
			openOutboundLink(url, action)

		# Done
		return

	openInternalLink = (url,action) ->
		if action is 'new'
			window.open(url,'_blank')
		else if action is 'same'
			wait(100, -> document.location.href = url)
		return

	openOutboundLink = (url,action) ->
		hostname = url.replace(/^.+?\/+([^\/]+).*$/,'$1')
		_gaq?.push(['_trackEvent', "Outbound Links", hostname, url, 0, true])
		openInternalLink(url,action)
		return

	$body.on 'click', 'a[href]:external', (event) ->
		# Prepare
		$this = $(this)
		url = $this.attr('href')

		openLink(url, event)

		# Done
		return

	$body.on 'click', '[data-href]', (event) ->
		# Prepare
		$this = $(this)
		url = $this.data('href')

		openLink(url, event)

		# Done
		return



	# Document Nav
	upSection = ->
		return  unless $docHeaders?
		$current = $docHeaders.filter('.current')
		if $current.length
			$prev = $current.prevAll('h2:first')
			if $prev.length
				$prev.click()
			else
				$docHeaders.filter('.current').removeClass('current')
				$docHeaders.last().click()
		return

	downSection = ->
		return  unless $docHeaders?
		$current = $docHeaders.filter('.current')
		if $current.length
			$next = $current.nextAll('h2:first')
			if $next.length
				$next.click()
			else
				$docHeaders.first().click()
		else
			$docHeaders.first().click()
		return

	# Key-based Navigation
	navKeyUp = (event) ->
		if event.shiftKey
			if event.keyCode is 220  # \
				$('.block-footer a.up').click()
			else if event.keyCode is 219  # [
				$('.block-footer a.prev').click()
			else if event.keyCode is 221  # ]
				$('.block-footer a.next').click()
		else
			if event.keyCode is 220 # \
				$mainnav.ScrollTo(scrollOptions)
			else if event.keyCode is 219  # [
				upSection()
			else if event.keyCode is 221  # ]
				downSection()
		return
	
	$document.on 'keyup', navKeyUp

	# Disable key-based Navigation in inputs
	$document.on 'focus', 'input', (event) ->
		$document.off 'keyup', navKeyUp

	$document.on 'blur', 'input', (event) ->
		$document.on 'keyup', navKeyUp



	# Listen to history.js page changes
	$window.on 'statechange', ->
		# Prepare
		url = History.getState().url

		relativeUrl = url.replace(rootUrl,'')
		activeUrlPart = '/'+relativeUrl.split('/')[0]

		# Set Loading
		$body.addClass('loading')

		# Start Fade Out
		# Animating to opacity to 0 still keeps the element's height intact
		# Which prevents that annoying pop bang issue when loading in new content
		$article.animate({opacity:0}, 800)

		$.ajax({
			url
			success: (data, textStatus, jqXHR) ->
				# Prepare
				$data = $(documentHtml(data))
				$dataBody = $data.find('.document-body:first')
				$dataContent = $dataBody.find('article:first')
				
				# Fetch the scripts
				$scripts = $dataContent.find('.document-script')
				$scripts.detach()  if $scripts.length

				# Fetch the content
				contentHtml = $dataContent.html() or $data.html()
				unless contentHtml
					documentation.location.href = url
					return false

				$article.stop(true, true)
				$article.html(contentHtml)
					.fixLegacyLinks()
					.ajaxify()
					.css('opacity', 100)
					.show()

				document.title = $data.find('.document-title:first').text()
				try
					escapedTitle = document.title
						.replace('<','&lt;')
						.replace('>','&gt;')
						.replace('&','&amp;')
					document.getElementsByTagName('title')[0].innerHTML = escapedTitle

				# Add the scripts
				$scripts.each ->
					$script = $(@)
					scriptText = $script.length
					scriptNode = document.createElement('script')
					scriptNode.appendChild(document.createTextNode(scriptText))
					contentNode.appendChild(scriptNode)

				$body.removeClass('loading')

				$window.trigger('statechangecomplete')

				# Inform Google Analytics of the change
				window._gaq.push(['_trackPageview', relativeUrl])  if window._gaq?

				# Inform Gauges
				window._gauges.push(['track'])  if window._gauages?

				# Inform ReInvigorate of a state change
				if window.reinvigorate? and window.reinvigorate.ajax_track?
					# Uses the full URL as ReInvigorate only supports that
					reinvigorate.ajax_track(url)

				# Done
				return
			error: (jqXHR, textStatus, errorThrown) ->
				document.location.href = url
				return false
		})
		# State Change Done
		return

	$window.on 'statechangecomplete', ->
		# Prepare
		url = History.getState().url

		relativeUrl = url.replace(rootUrl,'')
		activeUrlPart = '/'+relativeUrl.split('/')[0]

		# Scroll to top
		$mainnav.ScrollTo(scrollOptions)

		# Update the main and footer menu
		activateLinksInMenu($mainnav, activeUrlPart)
		activateLinksInMenu($footernav, activeUrlPart)

		# Update the secondary menu
		if $secondarynav
			activeUrlPart = '/' + relativeUrl
			$activeMenuLink = $secondarynav.find("a[href=\"#{activeUrlPart}\"]")
			$secondarynav.find('li.list-menu-item.active')
				.addClass('inactive')
				.removeClass('active')
			$secondarynav.find('li.list-menu-category.active')
				.addClass('inactive')
				.removeClass('active')
			if $activeMenuLink.length is 1
				$activeMenuLink.parents('li.list-menu-category')
					.addClass('active')
					.removeClass('inactive')
				$activeMenuLink.parent('li')
					.addClass('active')
					.removeClass('inactive')

		$article = $('article:first')

		# Documentation
		if $article.is('.block.doc')
			$docHeaders = $article.find('h2')

			# Compact
			if $article.is('.compact')
				$docHeaders
					.addClass('hover-link')
					.each (index) ->
						$header = $(@)
						$header.nextUntil('h2').wrapAll($docSectionWrapper.clone().attr('id','h2-'+index))
					.click (event,opts) ->
						$docHeaders.filter('.current').removeClass('current')
						$header = $(@)
							.addClass('current')
							.stop(true,false).css({'opacity':0.5}).animate({opacity:1},1000)
							.prevAll('.section-wrapper')
								.addClass('active')
								.end()
							.next('.section-wrapper')
								.addClass('active')
								.end()
						$header.ScrollTo(scrollOptions)  if !opts or opts.scroll isnt false
					.first()
						.trigger('click',{scroll:false})

			# Non-Compact
			else
				$docHeaders
					.addClass('hover-link')
					.click (event,opts) ->
						$docHeaders.filter('.current').removeClass('current')
						$header = $(@)
							.addClass('current')
							.stop(true,false).css({'opacity':0.5}).animate({opacity:1},1000)
						$header.ScrollTo(scrollOptions)  if !opts or opts.scroll isnt false

		else
			$docHeaders = null
		# State Change Complete - Done
		return

	$window.trigger('statechangecomplete')

	# Toggle side navigation categories
	if $secondarynav
		$secondarynav.on 'click', 'li.list-menu-category', ->
			$this = $(@)
			if not $this.hasClass('active')
				$collection = $this.find('ul')
				$collection.hide()
				$this.toggleClass('inactive expanded')
				$collection.show()

	# Scroll Spy
	_scrollSpy = ->
		pageLeftToRead = document.height - (window.scrollY + window.innerHeight)
		$articleNav = $article.find('.prev-next a.next')
		if pageLeftToRead <= 170
			$articleNav.css('opacity',1)
		else
			$articleNav.css('opacity',.5)

	setInterval(_scrollSpy, 500)

	# Chain
	return $

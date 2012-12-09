###
layout: default
###

nav '#nav-main', ->
	a '#logo', href: '/', title: @text['heading'], ->
		@text['heading']

	for own page, url of @navigation.top
		a href: url, -> text page

	form '#search', action: 'http://google.com/search', method: 'get', ->
		input type: 'hidden', name: 'q', value: 'site:docpad.org'
		input '#search-text', type: 'text', name: 'q', placeholder: 'Search via Google'
	
if @document.splash
	text @content
else
	div '.container.clearfix', -> text @content

footer '.clearfix', ->
	span -> @text['copyright']

	nav '#nav-footer', ->
		for own page, url of @navigation.bottom
			a href: url, -> page

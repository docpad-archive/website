###
layout: default
###

nav '.topbar', ->
	a '.logo', href: '/', title: @text['heading'], ->
		@text['heading']

	div '.links', ->
		for own page, url of @navigation.top
			a href: url, -> text page

	form '.search', action: 'http://google.com/search', method: 'get', ->
		input type: 'hidden', name: 'q', value: 'site:docpad.org'
		input '.search-text', type: 'text', name: 'q', placeholder: 'Search via Google'

div '.mainbar', ->
	text @content

footer '.bottombar', ->
	div '.about', -> @text['copyright']
	div '.links', ->
		for own page, url of @navigation.bottom
			a href: url, -> page

a '.webchat', href:'http://webchat.freenode.net/?channels=docpad', target:'_blank', -> 'IRC Chat'
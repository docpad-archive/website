###
layout: default
###

nav '.topbar', ->
	a '.logo', href: '/', title: @text['heading'], ->
		@text['heading']

	div '.links', ->
		for own page, url of @navigation.top
			a href: url, -> text page

	text @partial 'content/search'

div '.mainbar', ->
	text @content

footer '.bottombar', ->
	div '.about', -> @text['copyright']
	div '.links', ->
		for own page, url of @navigation.bottom
			a href: url, -> page

a '.webchat', href:'http://webchat.freenode.net/?channels=docpad', target:'_blank', -> 'IRC Chat'
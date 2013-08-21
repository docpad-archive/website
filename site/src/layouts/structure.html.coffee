###
layout: default
###

docsCollection = @getCollection('docs')
for item,index in docsCollection.models
	if item.id is @document.id
		break

div '.topbar', ->
	nav '.topnav', ->
		div '.links', ->

			a '.logo.primary', href: '/', title: @text['heading'], ->
				@text['heading']

			for own page, url of @navigation.top
				a '.secondary', href: url, -> text page

		text @partial 'content/search'

	nav '.sidebar', ->
		text @partial('menu/menu.html.coffee',{
			collection: docsCollection
			activeItem: @document
			partial: @partial
			moment: @moment
			underscore: @underscore
			getCategoryName: @getCategoryName
		})

div '.mainbar', ->
	text @content

footer '.bottombar', ->
	div '.about', -> @text['copyright']
	div '.links', ->
		for own page, url of @navigation.bottom
			a href: url, -> page

a '.webchat', href:'http://webchat.freenode.net/?channels=docpad', target:'_blank', -> 'IRC Chat'
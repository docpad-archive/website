###
title: Documentation
layout: structure
url: '/docs/'
standalone: true
###

# Prepare
_ = @underscore
docsCollection = @getCollection('docs')


section '#content', ->
	div '.page.nonav.docs', ->
		header ->
			a '.permalink.hover-link', href: '/docs/', ->
				h1 'Documentation'

		# Menu
		text @partial('menu/menu.html.coffee',{
			collection: docsCollection
			activeItem: @document
			partial: @partial
			moment: @moment
			underscore: @underscore
			getCategoryName: @getCategoryName
		})
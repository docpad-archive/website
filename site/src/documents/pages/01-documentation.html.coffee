### cson
title: "Documentation"
layout: "structure"
url: "/docs/"
urls: ["/docs"]
standalone: true
###

# Prepare
docsCollection = @getCollection('docs')

# Render
section '#content', ->
	div '.page.docs', ->
		header ->
			a '.permalink.hover-link', href: '/docs/', ->
				h1 'Documentation'

		# Menu
		text @partial('menu/menu.html.coffee',{
			collection: docsCollection
			activeItem: @document
			partial: @partial
			moment: @moment
			getCategoryName: @getCategoryName
		})
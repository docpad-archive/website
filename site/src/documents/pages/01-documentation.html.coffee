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
	div '.page.nonav', ->
		header ->
			a '.permalink.hover-link', href: '/docs/', ->
				h1 'Documentation'

		# Categories
		categories = _.uniq docsCollection.pluck('category')
		for category in categories
			# Category Items
			categoryItems = docsCollection.findAll({category})

			# First Category Item
			_item = categoryItems.at(0)

			div '.column', ->
				a href: _item.get('url'), ->
					h2 _item.get('categoryName')
				div '.block', ->
					ul '.list-menu-items', @partial('menu/items', {
						type: 'menu'
						items: categoryItems
						showDescription: false
						showDate: false
					})

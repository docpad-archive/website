# Prepare
{ itemSort, collection } = @
return  unless collection

_ = @underscore

# Menu
nav '.list-menu', ->
	ul '.list-menu-categories', typeof:'dc:collection', ->

		# Categories
		categories = _.uniq collection.pluck('category')
		for category in categories
			# Category Items
			categoryItems = collection.findAll({category},itemSort)

			# Category with Items
			text @partial('menu/category',{
				type: 'menu'
				items: categoryItems
				activeItem: @activeItem
				showDescription: false
				showDate: false
				partial: @partial
				moment: @moment
			})

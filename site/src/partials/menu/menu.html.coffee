# Prepare
{itemSort, collection } = @
return  unless collection

# Menu
nav '.list-menu', ->
	ul '.list-menu-categories', typeof:'dc:collection', ->

		text """
			<li class="list-menu-category list-menu-home" typeof="soic:page" about="/">
			  <a class="list-menu-link" href="/">
			    <h3 class="list-menu-title" property="dc:title">
			      HOME
			    </h3>
			  </a>
			</li>
			"""

		# Categories
		occuredCategories = []
		categories = collection.pluck('category')
		for category in categories
			# Check
			continue  if category in occuredCategories
			occuredCategories.push(category)

			# Category Items
			categoryItems = collection.findAll({category}, itemSort)

			# Category with Items
			text @partial('menu/category', {
				type: 'menu'
				items: categoryItems
				activeItem: @activeItem
				showDescription: false
				showDate: false
				partial: @partial
				moment: @moment
			})

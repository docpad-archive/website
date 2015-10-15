# Prepare
{itemSort, collection, partial} = @
return  unless collection

try
# Categories
	occuredCategories = []
	categories = collection.pluck('category')
	output = []
	for category in categories
		# Check
		if category != "partners"
			continue  if category in occuredCategories
			occuredCategories.push(category)

			# Category Items
			categoryItems = collection.findAll({category}, itemSort)
			if category in ["1-start","start"]
				category = "Getting Started"
			category =  category[0].toUpperCase() + category.slice(1)
			
			output.push({title:category,categoryItems:categoryItems.toJSON()})

	text partial('menu/category-grid',{items:output})
catch err
	text err

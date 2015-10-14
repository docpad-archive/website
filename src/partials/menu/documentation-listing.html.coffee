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
			if category in ["1-start","start"]
				category = "Getting Started"
			category =  category[0].toUpperCase() + category.slice(1)
			categoryItems = collection.findAll({category}, itemSort)
			output.push({title:category,categoryItems:categoryItems})

	text partial('menu/category-grid',{items:output})
catch err
	text err

# Prepare
{activeCssClasses, inactiveCssClasses, type, activeItem, items, categoryCssClasses} = @
activeCssClasses ?= ['active']
inactiveCssClasses ?= ['inactive']
type or= 'items'
_categoryItem = items.at(0)

_categoryCssClasses = [".list-#{type}-category"]
_categoryCssClasses.push(if activeItem?.category is _categoryItem.get('category') then activeCssClasses else inactiveCssClasses)
_categoryCssClasses.concat(categoryCssClasses?)

# Category
li '.'+_categoryCssClasses.join('.'), typeof:'dc:collection', ->
	a ".list-#{type}-link", href:_categoryItem.get('url'), ->
		h2 ".list-#{type}-title", property:'dc:title', ->
			text h(_categoryItem.get('categoryName'))
	ul ".list-#{type}-items", @partial('menu/items', @)

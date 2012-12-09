# Prepare
{activeCssClasses, inactiveCssClasses, type, activeItem, items, categoryCssClasses} = @
activeCssClasses ?= ['active']
inactiveCssClasses ?= ['inactive']
type or= 'items'
_categoryItem = items.models[0].attributes

_categoryCssClasses = [".list-#{type}-category"]
_categoryCssClasses.push(if activeItem?.category is _categoryItem.category then activeCssClasses else inactiveCssClasses)
_categoryCssClasses.concat(categoryCssClasses?)

# Category
li '.'+_categoryCssClasses.join('.'), typeof:'dc:collection', ->
	a href:'#', -> span ".list-#{type}-category-title", property:'dc:title', -> text _categoryItem.categoryName
	ul @partial('menu/items.html.coffee', @)

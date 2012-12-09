###
layout: structure
###

docsCollection = @getCollection('docs')
for item,index in docsCollection.models
	if item.id is @document.id
		break

prevModel = docsCollection.models[index-1] ? null
nextModel = docsCollection.models[index+1] ? null

nav '#nav-secondary', ->
	text @partial('menu/menu.html.coffee',{
		collection: docsCollection
		activeItem: @document
		partial: @partial
		moment: @moment
		underscore: @underscore
		getCategoryName: @getCategoryName
	})

section '#content', ->
	text @partial('content/block.html.coffee',{
		cssClasses: ["doc"].concat(@document.cssClasses or [])
		permalink: @document.url
		heading: @document.title
		subheading: @document.subheading
		content: @content
		document: @document
		partial: @partial
		prev:
			if prevModel
				url: prevModel.attributes.url
				title: prevModel.attributes.title
		next:
			if nextModel
				url: nextModel.attributes.url
				title: nextModel.attributes.title
	})

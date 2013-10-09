###
layout: structure
###

docsCollection = @getCollection('docs')
for item,index in docsCollection.models
	if item.id is @document.id
		break

prevModel = docsCollection.models[index-1] ? null
nextModel = docsCollection.models[index+1] ? null

section '#content', ->
	div '.page', ->
		text @partial('content/block.html.coffee', {
			partial: @partial
			cssClasses: ["doc"].concat(@document.cssClasses or [])
			permalink: @document.url
			heading: @document.title
			subheading: @document.subheading
			content: @content
			document: @document
			prev:
				if prevModel
					url: prevModel.attributes.url
					title: prevModel.attributes.title
			next:
				if nextModel
					url: nextModel.attributes.url
					title: nextModel.attributes.title
			up:
				url: "/docs/"
				title: 'Documentation'
		})

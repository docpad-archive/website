###
layout: default
###

docsCollection = @getCollection('docs')
for item,index in docsCollection.models
	if item.id is @document.id
		break
header '.transparent.light', role: 'banner', ->
	div '.row', ->
		div '.nav-inner.row-content.buffer-left.buffer-right.even.clear-after', ->
			div id: 'brand', ->
				h1 '.reset', ->
					a href: '/', title: @text['heading'], ->
						@text['heading']
			a id: 'menu-toggle', href: '#', ->
				i '.fa.fa-bars.fa-lg', ''
			nav ->
				ul '.reset', role: 'navigation', ->
					for own page, url of @navigation.top
						li '.menu-item', ->
							a  href: url, -> text page
main role: 'contentinfo', ->
	text @content
	
footer role: 'contentinfo', ->
	div '.row', ->
		div '.row-content.buffer.clear-after', ->
			section id: 'top-footer', ->
				div '.widget.column.three', ->
					h4 -> text 'Menu'
					ul '.plain', ->
						for own page, url of @navigation.bottom
							li ->
								a href: url, -> page
				div '.widget.column.three', ->
					h4 -> text 'Archives'
					ul '.plain', ->
						li ->
							a href: '#', -> text 'March 2015'
				div '.widget.column.three', ->
					h4 -> text 'About'
					p -> @text['copyright']
				div '.widget.meta-social.column.three', ->
					h4 -> text 'Follow Us'
					ul '.inline', ->
						li ->
							a '.twitter-share.border-box', href:'https://twitter.com/docpad', ->
								i '.fa.fa-twitter.fa-lg', ''
						li ->
							a '.facebook-share.border-box', href:'#', ->
								i '.fa.fa-facebook.fa-lg', ''
						li ->
							a '.pinterest-share.border-box', href:'#', ->
								i '.fa.fa-pinterest.fa-lg', ''
# Prepare
{permalink,comments,date,heading,subheading,author,content,cssClasses,prev,next,up,document,partial} = @

# Render
article ".block"+(if cssClasses then '.'+cssClasses.join('.') else ""), ->
	header ".block-header", ->
		if permalink
			a '.permalink.hover-link', href:permalink, ->
				h1 h(heading)
		else
			h1 h(heading)
		if subheading
			h2 h(subheading)
		if date
			span '.date', -> date
		if author
			a '.author', href:"/people/#{author}", -> author

	section ".block-content", content

	footer ".block-footer", ->

		if comments
			aside '.comments', ->
				text partial('services/disqus', {document})

		if prev or up or next
			nav ".prev-next", ->
				if prev
					a ".prev", href:h(prev.url), ->
						span ".icon", ->
						span ".title", -> h(prev.title)
				if up
					a '.up', href:h(up.url), ->
						span '.icon', ->
						span '.title', -> h(up.title)
				if next
					a ".next", href:h(next.url), ->
						span ".icon", ->
						span ".title", -> h(next.title)

if document.editUrl
	aside '.block-edit', ->
		a href:document.editUrl, "Edit and improve this page!"

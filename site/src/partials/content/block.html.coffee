# Prepare
{permalink,comments,date,heading,subheading,author,content,cssClasses,prev,next,up,document,partial} = @

# Render
article ".block"+(if cssClasses then '.'+cssClasses.join('.') else ""), ->
	header ".block-header", ->
		if permalink
			a '.permalink.hover-link', href:permalink, ->
				h1 heading
		else
			h1 heading
		if subheading
			h2 subheading
		if date
			span '.date', -> date
		if author
			a '.author', href:"/people/#{author}", -> author

	section ".block-content", content

	footer ".block-footer", ->

		if comments
			aside '.comments', ->
				text partial('services/disqus.html.eco', {document})

		if prev or up or next
			nav ".prev-next", ->
				if prev
					a ".prev", href:prev.url, ->
						span ".icon", ->
						span ".title", -> prev.title
				if up
					a '.up', href:up.url, ->
						span '.icon', ->
						span '.title', -> up.title
				if next
					a ".next", href:next.url, ->
						span ".icon", ->
						span ".title", -> next.title

###
layout: default
###

div '.topbar', ->
	nav '.topnav', ->
		div '.links', ->

			a '.logo.primary', href: '/', title: @text['heading'], ->
				@text['heading']

			for own page, url of @navigation.top
				a '.secondary', href: url, -> text page

		text @renderGoogleSearch()

	nav '.sidebar', ->
		text @renderMenu({render: 'projects'})

div '.mainbar', ->
	div '.contentbar', ->
		text @content

	footer '.bottombar', ->
		div '.about', -> @text['copyright']
		div '.links', ->
			for own page, url of @navigation.bottom
				a href: url, -> page

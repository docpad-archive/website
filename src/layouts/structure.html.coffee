###
layout: default
###

docsCollection = @getCollection('docs')
for item,index in docsCollection.models
	if item.id is @document.id
		break

div '.topbar', ->
	nav '.topnav', ->
		div '.links', ->

			a '.logo.primary', href: '/', title: @text['heading'], ->
				@text['heading']

			for own page, url of @navigation.top
				a '.secondary', href: url, -> text page

		text """<script>
			(function() {
			var cx = '000711355494423975011:mvl83obfzvq';
			var gcse = document.createElement('script');
			gcse.type = 'text/javascript';
			gcse.async = true;
			gcse.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') +
				'//www.google.com/cse/cse.js?cx=' + cx;
			var s = document.getElementsByTagName('script')[0];
			s.parentNode.insertBefore(gcse, s);
			})();
			</script>
			<div class="search">
				<gcse:search></gcse:search>
			</div>
			"""

	nav '.sidebar', ->
		text @partial('menu/menu.html.coffee',{
			collection: docsCollection
			activeItem: @document
			partial: @partial
			moment: @moment
			underscore: @underscore
			getCategoryName: @getCategoryName
		})

div '.mainbar', ->
	text @content

footer '.bottombar', ->
	div '.about', -> @text['copyright']
	div '.links', ->
		for own page, url of @navigation.bottom
			a href: url, -> page

a '.webchat', href:'http://webchat.freenode.net/?channels=docpad', target:'_blank', -> 'IRC Chat'

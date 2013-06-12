form '.search', action: 'http://google.com/search', method: 'get', ->
	input type: 'hidden', name: 'q', value: 'site:docpad.org'
	input '.search-text', type: 'text', name: 'q', placeholder: 'Search via Google'

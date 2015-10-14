### cson
title: "Documentation"
layout: "post"
standalone: true
bodyClass: "blog masonry-style"
###

# Prepare
docsCollection = @getCollection('docs')
text @partial('menu/documentation-listing',{collection: docsCollection,partial:@partial})

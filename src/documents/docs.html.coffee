### cson
title: "Documentation"
layout: "post"
standalone: true
bodyClass: "blog masonry-style"
###

# Prepare
listing = @getDocumentationListing()
text @partial('menu/category-grid',{items:listing})
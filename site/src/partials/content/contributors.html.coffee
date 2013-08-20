ul '.contributors', ->
	for contributor in @contributors or []
		li '.contributor', ->
			span '.contributor-name', ->
				if contributor.url
					a href:contributor.url, title:'visit their github', ->
						contributor.name
				else
					text contributor.name
			span '.contributor-repos', ->
				text " contributed to: "
				for own key,value of contributor.repos
					repoUrl = value
					if contributor.username
						contributionUrl = "#{repoUrl}/commits?author=#{contributor.username}"
						a '.contributor-repo', title:'view their contributions', href:contributionUrl, key
					else
						a '.contributor-repo', title:'visit the project', href:repoUrl, key
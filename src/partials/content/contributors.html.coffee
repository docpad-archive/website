ul '.contributors', ->
	for contributor in @contributors or []
		li '.contributor', ->
			span '.contributor-name', ->
				if contributor.url
					a href:h(contributor.url), title:'visit their github', ->
						h(contributor.name)
				else
					text h(contributor.name)
			span '.contributor-repos', ->
				text " contributed to: "
				for own key,value of contributor.repos
					repoUrl = value
					if contributor.username
						contributionUrl = "#{repoUrl}/commits?author=#{contributor.username}"
						a '.contributor-repo', title:'view their contributions', href:h(contributionUrl), key
					else
						a '.contributor-repo', title:'visit the project', href:h(repoUrl), key
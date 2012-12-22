###
standalone: true
###

# App
class App extends BevryApp

	# State Change
	stateChange: (event,data) =>
		# Check
		return super  unless data

		# Prepare
		$navSecondaryRemote = data.$dataBody.find('.nav-secondary')
		$navSecondaryLocal = $('.nav-secondary')

		# Remote does not have navSecondary so ensure we don't have it locally
		if $navSecondaryRemote.length is 0
			$navSecondaryLocal.remove()

		# Remote has navSecondary so ensure we have it locally
		else
			if $navSecondaryLocal.length is 0
				$('.container').prepend($navSecondaryRemote)
			else
				$navSecondaryLocal.replaceWith($navSecondaryRemote)

		# Super
		super


# Create
app = new App()
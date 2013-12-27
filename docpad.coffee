# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
docpadConfig = {

	# =================================
	# Template Data
	# These are variables that will be accessible via our templates
	# To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

	templateData:

		# Specify some site properties
		site:
			# The production url of our website
			url: "http://plumvillage.org"

			# Here are some old site urls that you would like to redirect from
			oldUrls: [
				'www.plumvillage.org',
				'new.plumvillage.org'
			]

			# The default title of our website
			title: "Plum Village Practice Center"
			company: "Plum Village"

			# The website description (for SEO)
			description: """
				Plum Village is a Buddhist meditation center of the Order of Interbeing in the Dordogne, in southern France. It was founded by Vietnamese monk Thích Nhất Hạnh, and his colleague Bhikkhuni Chân Không, in 1982.
				"""

			# The website keywords (for SEO) separated by commas
			keywords: """
				Plum Village, Thich Nhat Hanh, Zen, mindfulness, Buddhism, peace, meditation
				"""

			# The website author's name
			author: "Plum Village Online Monastery"

			# The website author's email
			email: "om@plumvillage.org"

			# Styles
			styles: [
				"/styles/zurb-foundation.css"
				"/styles/style.css",
				"/styles/highlightjs-github.css"
			]

			# Scripts
			scripts: [
				"/scripts/app.js"
			]



		# -----------------------------
		# Helper Functions

		# Get the prepared site/document title
		# Often we would like to specify particular formatting to our page's title
		# we can apply that formatting here
		getPreparedTitle: ->
			# if we have a document title, then we should use that and suffix the site's title onto it
			if @document.title
				"#{@document.title} | #{@site.title}"
			# if our document does not have it's own title, then we should just use the site's title
			else
				@site.title

		# Get the prepared site/document description
		getPreparedDescription: ->
			# if we have a document description, then we should use that, otherwise use the site's description
			@document.description or @site.description

		# Get the prepared site/document keywords
		getPreparedKeywords: ->
			# Merge the document keywords with the site keywords
			@site.keywords.concat(@document.keywords or []).join(', ')


	# =================================
	# Collections
	# These are special collections that our website makes available to us

	collections:
		# list of documents which make up main nav. May be any content-type
		dcoumentsInMainNav: (database) ->
			database.findAllLive({includenInNavs: {$has: 'main'}}, [pageOrder:1,title:1])

		# All documents with contenttype=pages (i.e: directory reflects contenttype which seemed a logical choice)
		# ordered by pageOrder (not required) and title
		pages: (database) ->
			database.findAllLive({relativeOutDirPath: 'pages'}, [pageOrder:1,title:1])

		# All documents with contenttype=posts ordered by date
		posts: (database) ->
			database.findAllLive({relativeOutDirPath: 'posts'}, [date:-1])

		# All documents with contenttype=faqs ordered by faqOrder (not required) and title
		faqs: (database) ->
			database.findAllLive({relativeOutDirPath: 'faq'}, [faqOrder:1,title:1])


	# =================================
	# Plugins

	plugins:
		nodesass: 
			bourbon: true
		grunt:
      		gruntTasks: ["uglify"]

	# =================================
	# DocPad Events

	# Here we can define handlers for events that DocPad fires
	# You can find a full listing of events on the DocPad Wiki
	events:

		# Server Extend
		# Used to add our own custom routes to the server before the docpad routes are added
		serverExtend: (opts) ->
			# Extract the server from the options
			{server} = opts
			docpad = @docpad

			# As we are now running in an event,
			# ensure we are using the latest copy of the docpad configuraiton
			# and fetch our urls from it
			latestConfig = docpad.getConfig()
			oldUrls = latestConfig.templateData.site.oldUrls or []
			newUrl = latestConfig.templateData.site.url

			# Redirect any requests accessing one of our sites oldUrls to the new site url
			server.use (req,res,next) ->
				if req.headers.host in oldUrls
					res.redirect(newUrl+req.url, 301)
				else
					next()

}


# Export our DocPad Configuration
module.exports = docpadConfig
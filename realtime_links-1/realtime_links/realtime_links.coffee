# This is the coffee file for the complete Meteor example

root = global ? window
Meteor = root.Meteor

# Define the links collection on which the application works
Links = new Meteor.Collection 'links'
# This collection has the fields - url, thumbs_up, thumbs_down and score

if Meteor.is_client
	# The following functions are used by the header template
	Template.header.collection_size = () ->
		return Links.find({}).count()

	# The following functions are used by the link_list template
	Template.link_list.links = () ->
		return Links.find({}, {sort : {score : -1}})
	
	# The following functions are used by the link_detail template
	# It will refer to a particular link
	Template.link_detail.events =
		'click input.thumbs_up' : () ->
			Meteor.call 'vote', @url, 'thumbs_up'

		'click input.thumbs_down' : () ->
			Meteor.call 'vote', @url, 'thumbs_down'
	
	Template.add_new_link.events =
		'click input#add_url' : () ->
			new_url = $('#url').val()
			url_row = Links.findOne {url : new_url}
			if not url_row
				Links.insert {url : new_url, score : 0, thumbs_up : 0, thumbs_down : 0}
			Meteor.call 'vote', new_url, 'thumbs_up'

# Server side code
if Meteor.is_server
	Meteor.startup( ->
		Meteor.methods
			vote : (url, field) ->
				new_obj = {$inc : {}}
				if field == 'thumbs_up'
					new_obj['$inc']['thumbs_up'] = 1
					new_obj['$inc']['score'] = 1
				else
					new_obj['$inc']['thumbs_down'] = 1
					new_obj['$inc']['score'] = -1
				Links.update({url : url}, new_obj)
	 )


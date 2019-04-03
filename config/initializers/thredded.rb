# frozen_string_literal: true

# Set the default user class to make sure Thredded adds its methods to it.
Thredded.user_class = 'User'

# Use User#login for the @mention syntax and to present the name of the user. Note that this column
# must be unique.
Thredded.user_name_column = :login

# Configure the method name to fetch the current user.
Thredded.current_user_method = :current_user

# Lambda to generate a URL to the user page.
Thredded.user_path = ->(user) { '/' + user.to_param }

# Configure which URL to use for an avatar.
Thredded.avatar_url = ->(user) {
  user.avatar_location(variant: :album) || UsersHelper.no_avatar_path
}

# The name of the moderator flag column on the users table.
Thredded.moderator_column = :moderator

# The name of the admin flag column on the users table.
Thredded.admin_column = :admin

# Whether posts and topics pending moderation are visible to regular users.
Thredded.content_visible_while_pending_moderation = false

# Whether users that are following a topic are listed on topic page.
Thredded.show_topic_followers = true

# How to calculate the position of messageboards in a list: :position, :last_post_at_desc, or
# :topics_count_desc.
Thredded.messageboards_order = :position

# Email "From:" field will use the following.
Thredded.email_from = 'support@alonetone.com'

# Emails going out will prefix the "Subject:" with the following string.
Thredded.email_outgoing_prefix = '[alonetone] '

# Set the layout for rendering the thredded views.
Thredded.layout = 'thredded'

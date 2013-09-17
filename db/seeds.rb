# -*- encoding : utf-8 -*-
require 'active_record/fixtures'

admin = User.create(:login => 'admin', :password => 'testing123', :password_confirmation => 'testing123')
admin.update_attribute(:admin, true)

forum = Forum.create
forum.name = "Making Music"
forum.description = "Talk about how you do it, how you want to do it, and how you feel about it."
forum.save

topic = admin.topics.create(
  :title => "Music and passion",
  :forum_id => forum
)

post = admin.posts.create(
  :body => "keep moving on",
  :topic_id => topic,
  :forum_id => forum
)

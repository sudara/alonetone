# -*- encoding : utf-8 -*-
require 'active_record/fixtures'

admin = User.create(:login => 'admin', :password => 'testing123', :password_confirmation => 'testing123')
admin.update_attribute(:admin, true)

forum = Forum.create
forum.name = "Making Music"
forum.description = "Talk about how you do it, how you want to do it, and how you feel about it."
forum.save

topic = admin.topics.build(
  :title => "Music and passion",
)

topic.forum = forum
topic.save

post = admin.posts.build(
  :body => "keep moving on"
)

post.topic = topic
post.forum = forum
post.save

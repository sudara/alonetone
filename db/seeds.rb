# -*- encoding : utf-8 -*-
require 'active_record/fixtures'

ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/fixtures", "users")

admin = User.find_by_login("admin")

forum = Forum.create
forum.name = "Making Music"
forum.description = "Talk about how you do it, how you want to do it, and how you feel about it."
forum.save

topic = admin.topics.create(
  :title => "Music and passion",
  :body => "alonetone rocks!"
)

topic.forum = forum
topic.save

post = admin.posts.create(
  :body => "keep moving on"
)

post.topic = topic
post.forum = forum
post.save

# -*- encoding : utf-8 -*-
Forum.delete_all
Topic.delete_all
Post.delete_all

admin = User.find_by_login("admin")

forum = Forum.create(
  :name => "Making Music",
  :description => "Talk about how you do it, how you want to do it, and how you feel about it."
)

topic = admin.topics.create(
  :title => "Music and passion",
  :body => "alonetone rock!"
)

topic.forum = forum
topic.save(false)

post = admin.posts.create(
  :body => "keep moving on"
)

post.topic = topic
post.forum = forum
post.save(false)

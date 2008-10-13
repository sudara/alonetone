f = Forum.create(
  :name => "Making Music",
  :description => "Talk about how you do it, how you want to do it, and how you feel about it."
)

t = f.topics.create(
  :user_id => 1,
  :title => "Music and passion",
  :body => "alonetone rock!"
).save(false)
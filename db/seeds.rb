require 'active_record/fixtures'
include ActionDispatch::TestProcess

admin = User.create(:login => 'admin', :email => "123@123.com", :password => 'testing123', :password_confirmation => 'testing123')
admin.update_attribute(:admin, true)

moderator = User.create(:login => 'moderator', :email =>'mod@mod.com', :password => 'mod123', :password_confirmation => 'mod123')
moderator.update_attribute(:moderator, true)

musician = User.create(:login => 'musician', :email =>'music@music.com', :password => 'music123', :password_confirmation => 'music123')
musician.update_attribute(:settings, :secret_view_enabled => true)

mp3 = fixture_file_upload(File.join('spec/fixtures/assets','muppets.mp3'),'audio/mpeg')
asset = musician.assets.build(:mp3 => mp3, :title => 'muppets!', :description => '*muppets* poking fun')
asset.extract_waveform(mp3.path)
asset.save

asset.listens.create(
  :listener     => moderator, 
  :track_owner  => asset.user, 
  :user_agent   => 'db seeds',
  :ip           => '127.0.0.1'
) 

forum = Forum.create
forum.name = "Making Music"
forum.description = "Talk about how you do it, how you want to do it, and how you feel about it."
forum.save

topic = admin.topics.build(
  :title => "Music and passion",
  :body  => "Lets tawlk"
)

topic.forum = forum
topic.save

post = admin.posts.build(
  :body => "keep moving on"
)

post.topic = topic
post.forum = forum
post.save

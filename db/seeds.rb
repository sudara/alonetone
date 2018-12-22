require 'active_record/fixtures'
include ActionDispatch::TestProcess

admin = User.create(:login => 'admin', :email => "123@123.com", :password => 'testing123', :password_confirmation => 'testing123')
admin.update_attribute(:admin, true)

moderator = User.create(:login => 'moderator', :email =>'mod@mod.com', :password => 'mod123', :password_confirmation => 'mod123')
moderator.update_attribute(:moderator, true)

musician = User.create(:login => 'musician', :email =>'music@music.com', :password => 'music123', :password_confirmation => 'music123')
musician.update_column(:greenfield_enabled, true)

mp3 = fixture_file_upload(File.join('spec/fixtures/assets','muppets.mp3'),'audio/mpeg')
asset = musician.assets.create(:mp3 => mp3, :title => 'muppets!', :description => '*muppets* poking fun', :waveform => Greenfield::Waveform.extract(mp3.path))

asset.listens.create(
  :listener     => moderator,
  :track_owner  => asset.user,
  :user_agent   => 'db seeds',
  :ip           => '127.0.0.1'
)

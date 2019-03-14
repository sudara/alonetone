include ActionDispatch::TestProcess
muppet_upload = fixture_file_upload(File.join('spec/fixtures/files/muppets.mp3'), 'audio/mpeg')
piano_upload = fixture_file_upload(File.join('spec/fixtures/files/piano.mp3'), 'audio/mpeg')
cover_upload = fixture_file_upload(File.join('spec/fixtures/images/manfreddoescover.jpg'), 'image/jpeg')
avatar_upload = fixture_file_upload(File.join('spec/fixtures/images/jeffdoessudara.jpg'), 'image/jpeg')

def put_user_credentials(username, password)
  puts "You can now sign in with: #{username} - #{password}"
end

selected_password = ENV.fetch('PASSWORD', 'testing123')

# Create admin account.
admin_password = selected_password
admin = User.create!(
  login: 'admin',
  email: 'admin@example.com',
  password: admin_password,
  password_confirmation: admin_password,
  admin: true
)
put_user_credentials(admin.login, admin_password)

# Create moderator account.
moderator_password = selected_password
moderator = User.create!(
  login: 'moderator',
  email: 'moderator@example.com',
  password: moderator_password,
  password_confirmation: moderator_password,
  moderator: true
)
moderator.create_pic!(pic: avatar_upload)
put_user_credentials(moderator.login, moderator_password)

# Create regular musician account.
musician_password = selected_password
musician = User.create!(
  login: 'musician',
  email: 'musician@example.com',
  password: musician_password,
  password_confirmation: musician_password,
  greenfield_enabled: true
)
put_user_credentials(musician.login, musician_password)

# Create a regular musician account with playlists and tracks.
marie_password = selected_password
marie = User.create!(
  login: 'marieh',
  email: 'marie.harel@example.com',
  password: marie_password,
  password_confirmation: marie_password,
  greenfield_enabled: true
)
put_user_credentials(marie.login, marie_password)

# Create a few assets for the musician.
commonly_blue_green = marie.assets.create!(
  mp3: muppet_upload,
  title: 'Commonly Blue-grey',
  description: 'The color of camembert rind was a matter of chance, most commonly blue-grey, with brown spots.',
  audio_feature_attributes: {
    waveform: Waveform.extract(muppet_upload.path)
  }
)
aqueous_suspension = marie.assets.create!(
  mp3: muppet_upload,
  title: 'Aqueous Suspension',
  description: 'The surface of each cheese is then sprayed with an aqueous suspension of the mold Penicillium camemberti.',
  audio_feature_attributes: {
    waveform: Waveform.extract(muppet_upload.path)
  }
)
# Create a playlist for the tracks.
playlist = marie.playlists.build(
  title: 'Before fungi were understood',
  year: Date.today.year - 1
)
playlist.description = <<~DESC
  The variety named Camembert de Normandie was granted a protected designation of origin in 1992
  after the original AOC in 1983.
DESC
playlist.save!
playlist.create_pic!(pic: cover_upload)
playlist.tracks.create!(user: marie, asset: commonly_blue_green)
playlist.tracks.create!(user: marie, asset: aqueous_suspension)
playlist.update(private: false)

# Create some more assets.
baguette_laonnaise = marie.assets.create!(
  mp3: piano_upload,
  title: 'Baguette Laonnaise',
  description: 'The cheese is typically loaf-shaped and has a supple interior as well as a sticky orange-brown rind.',
  audio_feature_attributes: {
    waveform: Waveform.extract(piano_upload.path)
  }
)
appellation_description = marie.assets.create!(
  mp3: piano_upload,
  title: 'Appellation description d’origine protégée',
  description: 'In Switzerland, the appellation d’origine protégée (AOP, protected designation of origin) is a geographical indication protecting the origin and the quality of traditional food products',
  audio_feature_attributes: {
    waveform: Waveform.extract(piano_upload.path)
  }
)
# Create a playlist for those assets.
playlist = marie.playlists.build(
  title: 'Raclette',
  year: Date.today.year
)
playlist.description = <<~DESC
  Raclette /rəˈklɛt/ is a semi-hard cheese that is usually fashioned into a wheel of about
  6 kg (13 lb).
DESC
playlist.save!
playlist.tracks.create!(user: marie, asset: baguette_laonnaise)
playlist.tracks.create!(user: marie, asset: appellation_description)
playlist.update(private: false)

# Some random listens.
Asset.find_each do |asset|
  User.find_each do |user|
    if rand(4) == 1
      asset.listens.create!(
        listener: user,
        track_owner: asset.user,
        user_agent: 'seeds/v1.0',
        ip: '127.0.0.1'
      )
    end
  end
end

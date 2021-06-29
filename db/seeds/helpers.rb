def upload(path)
  filename = File.expand_path(
    File.join(Rails.root, 'spec', 'fixtures', 'files', path),
    __dir__
  )
  content_type = Marcel::MimeType.for(filename)
  Rack::Test::UploadedFile.new(filename, content_type)
end

def extract_metadata(attributes)
  metadata = Upload::Metadata.new(attributes[:audio_file])
  metadata.attributes.merge(attributes)
end

def put_user_credentials(username, password)
  puts "You can now sign in with: #{username} - #{password}"
end

def audio_file
  @muppet_upload ||= upload('muppets.mp3')
  @piano_upload ||= upload('piano.mp3')
  @andy_upload ||= upload('titleless.mp3')

  [@muppet_upload, @piano_upload, @andy_upload].sample
end

def create_track(user)
  user.assets.create!(extract_metadata(
    audio_file: audio_file,
    title: Faker::Music::RockBand.song,
    description: Faker::Quote.famous_last_words
  ))
end
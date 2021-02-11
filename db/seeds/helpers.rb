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

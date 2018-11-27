require 'zip'
class Asset
  include Paperclip

  # see config/initializers/paperclip for defaults
  attachment_options = {
    styles: { original: '' }, # just makes sure original runs through the processor
    processors: [:mp3_paperclip_processor]
  }
  if Alonetone.storage == 's3'
    attachment_options[:path] = "/mp3/:id/:basename.:extension"
    attachment_options[:s3_permissions] = 'authenticated-read' # don't want these facing the public
  else
    attachment_options[:s3_permissions] = 'public-read' # let localhost/test work without expiring urls
  end

  has_attached_file :mp3, attachment_options

  validates_attachment_size :mp3, less_than: 60.megabytes
  validates_attachment_presence :mp3, message: 'must be set. Make sure you chose a file to upload!'
  validates_attachment_content_type :mp3, content_type: ['audio/mpeg', 'audio/mp3', 'audio/x-mp3'], message: " was wrong, this doesn't look like an Mp3..."

  def self.parse_external_url(url)
    url.gsub!('dl=0', 'dl=1') # make dropbox links easier to work with
    URI.parse(url)
  end

  def self.extract_mp3s(zip_file)
    # try to open the zip file
    Zip::File.open(zip_file.path) do |z|
      z.each do |entry|
        # only care if the zip entry is an mp3 of a decent size
        next unless entry.to_s =~ /(\.\w+)$/ && Regexp.last_match(1) == '.mp3' && entry.size > 2000

        tempfile_name = [File.basename(entry.name, '.mp3'), '.mp3']
        temp = Tempfile.new(tempfile_name)
        temp.open
        temp.binmode
        temp << z.read(entry)
        yield temp
        temp.close
        logger.warn("ZIP: #{entry} was extracted from zip file: #{zip_file.path}")
      end
    end
  # pass back the file unprocessed if the file is not a zip
  rescue Zip::ZipError => e
    logger.warn("User uploaded #{zip_file.path}:" + e.message)
    yield zip_file
  rescue TypeError => e
    logger.warn("User tried to upload too small file")
  end
end

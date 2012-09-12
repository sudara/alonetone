class Asset 
  include Paperclip
  ##has_attachment  :storage => Alonetone.storage, 
  #                :processor => :mp3info,
  #                # Don't know why can't upload mp3 files (zip files are passed)
  #                # so remove content_type for development and test environments
  #                :content_type => ['audio/mpeg','application/zip'],
  #                :max_size => 60.megabytes,
  #                :path_prefix => File.join(Alonetone.path_prefix, "mp3")
  #                  
  #validates_as_attachment

  # see environment files for defaults
  has_attached_file :mp3, {
    :styles => {:original => [:processors => :mp3_paperclip_processor]},
    :path => "/mp3/:id/:filename.:extension"
  }
  validates_attachment_size :mp3, :less_than => 60.megabytes
  validates_attachment_presence :mp3, :message => 'must be set. Make sure you chose a file to upload!'
  validates_attachment_content_type :mp3, :content_type => ['audio/mpeg'], :message => " was wrong. It doesn't look like you uploaded a valid mp3 file. Could you double check?"
  
  
 # Disable zip uploads for now, make life easier transitioning to paperclip
 # 
 # def self.extract_mp3s(zip_file, &block)
 #   # try to open the zip file
 #   Zip::ZipFile.open(zip_file.path) do |z|
 #     z.each do |entry|
 #       # so, if we've got a file with an mp3 in there with a decent size
 #       if entry.to_s =~ /(\.\w+)$/ && allowed_extensions.include?($1) && entry.size > 2000
 #         # throw together a new tempfile of the rails flavor 
 #         # spoof the necessary attributes to get Attachment_fu to accept our zipped friends
 #         #temp.content_type = 'audio/mpeg'          
 #         # pass back each mp3 within the zip
 #         tempfile_name = File.basename entry.name
 #         temp = ActionController::UploadedTempfile.new(tempfile_name, Technoweenie::AttachmentFu.tempfile_path)
 #         temp.open
 #         temp.binmode
 #         temp << z.read(entry)
 #         temp.content_type=  'audio/mpeg'
 #         # if there are some directories, remove them
 #         temp.original_path = tempfile_name
 #         yield temp
 #         #debugger
 #         # deletes the temp files
 #         temp.close
 # 
 #         logger.warn("ZIP: #{entry.to_s} was extracted from zip file: #{zip_file.path}")
 #       end
 #     end 
 #   end    
 # # pass back the file unprocessed if the file is not a zip 
 # rescue Zip::ZipError => e
 #   logger.warn("User uploaded #{zip_file.path}:"+e)
 #   yield zip_file
 # rescue TypeError => e
 #   logger.warn("User tried to upload too small file");
 # end  

  # never allow this to be blank, as permalinks are generated from it
  def clean_filename
    clean = self.filename[0..-5].gsub(/-|_/,' ').strip.titleize
    clean.blank? ? 'untitled' : clean
  end
end
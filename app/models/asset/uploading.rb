class Asset 
  # used for extra mime types that dont follow the convention
  @@extra_content_types = { 
    :audio => ['application/ogg'], 
    :movie => ['application/x-shockwave-flash'], 
    :pdf => ['application/pdf'] 
  }.freeze
  
  @@allowed_extensions = %w(.mp3)

  cattr_reader :extra_content_types, :allowed_extensions

  # use #send due to a ruby 1.8.2 issue
  @@movie_condition = send(:sanitize_sql, 
    ['content_type LIKE ? OR content_type IN (?)', 'video%', extra_content_types[:movie]]
  ).freeze

  @@audio_condition = send(:sanitize_sql, 
    ['content_type LIKE ? OR content_type IN (?)', 'audio%', extra_content_types[:audio]]
  ).freeze

  @@image_condition = send(:sanitize_sql, [
    'content_type IN (?)', 
    Technoweenie::AttachmentFu.content_types
  ]).freeze

  @@content_types = extra_content_types[:movie] + 
                    extra_content_types[:audio] + 
                    Technoweenie::AttachmentFu.content_types
  
  @@other_condition = send(:sanitize_sql, [
    'content_type NOT LIKE ? AND content_type NOT LIKE ? AND content_type NOT IN (?)',
    'audio%', 'video%', @@content_types
  ]).freeze

  cattr_reader *%w(movie audio image other).collect! { |t| "#{t}_condition".to_sym }
  
  has_attachment  :storage => ALONETONE.storage, 
                  :processor => :mp3info,
                  # Don't know why can't upload mp3 files (zip files are passed)
                  # so remove content_type for development and test environments
                  :content_type => (RAILS_ENV == 'production' ? ['audio/mpeg','application/zip'] : nil),
                  :max_size => 40.megabytes,
                  :path_prefix => File.join(ALONETONE.path_prefix, "mp3")
                    
  validates_as_attachment

  def self.extract_mp3s(zip_file, &block)
    # try to open the zip file
    Zip::ZipFile.open(zip_file.path) do |z|
      z.each do |entry|
        # so, if we've got a file with an mp3 in there with a decent size
        if entry.to_s =~ /(\.\w+)$/ && allowed_extensions.include?($1) && entry.size > 2000
          # throw together a new tempfile of the rails flavor 
          # spoof the necessary attributes to get Attachment_fu to accept our zipped friends
          #temp.content_type = 'audio/mpeg'          
          # pass back each mp3 within the zip
          tempfile_name = File.basename entry.name
          temp = ActionController::UploadedTempfile.new(tempfile_name, Technoweenie::AttachmentFu.tempfile_path)
          temp.open
          temp.binmode
          temp << z.read(entry)
          temp.content_type= 'audio/mpeg'
          # if there are some directories, remove them
          temp.original_path = tempfile_name
          yield temp
          #debugger
          # deletes the temp files
          temp.close

          logger.warn("ZIP: #{entry.to_s} was extracted from zip file: #{zip_file.path}")
        end
      end 
    end    
  # pass back the file unprocessed if the file is not a zip 
  rescue Zip::ZipError => e
    logger.warn("User uploaded #{zip_file.path}:"+e)
    yield zip_file
  rescue TypeError => e
    logger.warn("User tried to upload too small file");
  end

  class << self
    def movie?(content_type)
      content_type.to_s =~ /^video/ || extra_content_types[:movie].include?(content_type)
    end
        
    def audio?(content_type)
      content_type.to_s =~ /^audio/ || extra_content_types[:audio].include?(content_type)
    end
    
    def other?(content_type)
      ![:image, :movie, :audio].any? { |a| send("#{a}?", content_type) }
    end

    def find_all_by_content_types(types, *args)
      with_content_types(types) { find *args }
    end

    def with_content_types(types, &block)
      with_scope(:find => { :conditions => types_to_conditions(types).join(' OR ') }, &block)
    end

    def types_to_conditions(types)
      types.collect! { |t| '(' + send("#{t}_condition") + ')' }
    end
  end
  
  
  [:movie, :audio, :other, :pdf].each do |content|
    define_method("#{content}?") { self.class.send("#{content}?", content_type) }
  end
  
  def public_mp3
    self.public_filename
  end
  
  # never allow this to be blank, as permalinks are generated from it
  def clean_filename
    clean = self.filename[0..-5].gsub(/-|_/,' ').strip.titleize
    clean.blank? ? 'untitled' : clean
  end
end
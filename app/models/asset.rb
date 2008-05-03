# create_table "assets", :force => true do |t|
#   t.string   "content_type"
#   t.string   "filename"
#   t.integer  "size"
#   t.integer  "parent_id"
#   t.string   "thumbnail"
#   t.integer  "width"
#   t.integer  "height"
#   t.integer  "site_id"
#   t.datetime "created_at"
#   t.string   "title"
#   t.integer  "thumbnails_count", :default => 0
#   t.integer  "user_id"
#   t.integer  "length"
#   t.string   "album"
#   t.string   "permalink"
# end

class Asset < ActiveRecord::Base
  
  named_scope :descriptionless, {:conditions => 'description = "" OR description IS NULL', :order => 'created_at DESC', :limit => 10}
  named_scope :recent, {:include => :user, :order => 'assets.created_at DESC'}
    
  # used for extra mime types that dont follow the convention
  @@extra_content_types = { :audio => ['application/ogg'], :movie => ['application/x-shockwave-flash'], :pdf => ['application/pdf'] }.freeze
  @@allowed_extensions = %w(.mp3)
  cattr_reader :extra_content_types, :allowed_extensions
  

  # use #send due to a ruby 1.8.2 issue
  @@movie_condition = send(:sanitize_sql, ['content_type LIKE ? OR content_type IN (?)', 'video%', extra_content_types[:movie]]).freeze
  @@audio_condition = send(:sanitize_sql, ['content_type LIKE ? OR content_type IN (?)', 'audio%', extra_content_types[:audio]]).freeze
  @@image_condition = send(:sanitize_sql, ['content_type IN (?)', Technoweenie::AttachmentFu.content_types]).freeze
  @@other_condition = send(:sanitize_sql, [
    'content_type NOT LIKE ? AND content_type NOT LIKE ? AND content_type NOT IN (?)',
    'audio%', 'video%', (extra_content_types[:movie] + extra_content_types[:audio] + Technoweenie::AttachmentFu.content_types)]).freeze
  cattr_reader *%w(movie audio image other).collect! { |t| "#{t}_condition".to_sym }
  
  has_many :tracks, :dependent => :destroy
  has_many :playlists, :through => :tracks
  
  belongs_to :user, :counter_cache => true
  
  has_many :listens, :dependent => :destroy
  has_many :listeners, :through => :listens, :order => 'listens.created_at DESC', :uniq => true, :limit => 20
  
  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at DESC'
  
  acts_as_defensio_article
  
  has_many :facebook_addables, :as => :profile_chunks

  has_permalink :name
  # make sure we update permalink when user changes title
  before_save :create_unique_permalink
  
  has_attachment  :storage => :s3, 
                  :processor => :mp3info,
                  :content_type => ['audio/mpeg','application/zip'],
                  :max_size => 40.megabytes,
                  :path_prefix => "mp3"
                    
  validates_as_attachment
  validates_presence_of :user_id
  
  # after_resize do |record, mp3|
  #   mp3.tag.author = "#{record.user.name} (#{record.user.site})" unless mp3.tag.author
  # end
  # the attachment_fu callback is actually named after_resize


    # Generates magic %LIKE% sql statements for all columns
  def self.conditions_by_like(value, *columns) 
    columns = self.content_columns if columns.size==0 
    columns = columns[0] if columns[0].kind_of?(Array) 
    conditions = columns.map {|c| 
    c = c.name if c.kind_of? ActiveRecord::ConnectionAdapters::Column 
    "#{c} LIKE " + ActiveRecord::Base.connection.quote("%#{value}%") 
    }.join(" OR ") 
  end

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
  
  def self.latest(limit=10)
    find(:all, :include => :user, :limit => limit, :order => 'assets.created_at DESC')
  end

  def self.most_popular(limit=10, time_period=5.days.ago)
    popular = Listen.count(:all,:include => :asset, :group => 'listens.asset_id', :limit => limit, :conditions => ["listens.created_at > ? AND (listens.listener_id IS NULL OR listens.listener_id != listens.track_owner_id)", time_period], :order => 'count_all DESC')
    find(popular.collect{|pop| pop.first}, :include => :user)
    # In the last week, people have been listening to the following
    #find(:all, :include => :user, :limit => limit, :order => 'assets.listens_count DESC')
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
  
  # needed in case we've got multiple assets on the same page
  def unique_id
    object_id
  end
  
  def name
    # make sure the title is there, and if not, the filename is used...
    (title && !title.strip.blank?) ? title.strip : clean_filename
  end
  
  def public_mp3
    self.s3_url
  end
  
  # never allow this to be blank, as permalinks are generated from it
  def clean_filename
    clean = self.filename[0..-5].gsub(/-|_/,' ').strip.titleize
    clean.blank? ? 'untitled' : clean
  end
  
  def clean_permalink
    self.permalink = nil
  end
  
  def self.days
    (Asset.sum(:length).to_f / 60 / 60 / 24).to_s[0..2]
  end
  
  def self.gigs
    (Asset.sum(:size).to_f / 1024 / 1024 / 1024).to_s[0..3]
  end
  
  # allows classes outside Asset to use the same format
  def self.formatted_time(time)
    if time
      min_and_sec = time.divmod(60)
      minutes = min_and_sec[0].to_s
      seconds = min_and_sec[1].to_s
      seconds = "0"+seconds if seconds.length == 1
      minutes + ':' + seconds
    else
      "?:??"
    end
  end
  
  def self.update_hotness
    Asset.find(:all).each do |a|
      a.update_attribute(:hotness, a.calculate_hotness)
    end 
  end
  
  def calculate_hotness
    # hotness = listens not originating from own user within last 7 days * num of alonetoners who listened to it / age
    ratio = ((recent_listen_count.to_f) * (((unique_listener_count * 10) / User.count) + 1) * age_ratio )
  end
  
  def recent_listen_count(from = 7.days.ago, to = 1.hour.ago)
   listens.count(:all, :conditions => ['listens.created_at > ? AND listens.created_at < ? AND listens.listener_id != ?',from, to, self.user_id]) 
  end
  
  def listens_per_day
    listens.count(:all, :conditions => ['listens.listener_id != ?', self.user_id]).to_f / days_old
  end
  
  def unique_listener_count
    listens.count(:listener_id, :distinct => true)
  end
  
  def days_old
    ((Time.now - created_at) / 60 / 60 / 24 ).ceil
  end
  
  def age_ratio
    case days_old
      when 0..3 then 20.0
      when 4..7 then 8.0
      when 8..15 then 3.0
      when 16..30 then 2.5
      when 31..90 then 1.0
      else 0.5
    end
  end
  
  def length
    self.class.formatted_time(self[:length])
  end
  
  protected 
  
  def set_title_to_filename
    title = filename.split('.').first unless title
  end
   
end

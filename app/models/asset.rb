class Asset < ActiveRecord::Base
  
  concerned_with :uploading, :statistics
  
  named_scope :descriptionless, {:conditions => 'description = "" OR description IS NULL', :order => 'created_at DESC', :limit => 10}
  named_scope :recent, {:include => :user, :order => 'assets.created_at DESC'}

  formats_attributes :description    
  
  has_many :tracks, :dependent => :destroy
  has_many :playlists, :through => :tracks
  
  belongs_to :user, :counter_cache => true
  
  has_many :listens, :dependent => :destroy
  has_many :listeners, :through => :listens, :order => 'listens.created_at DESC', :uniq => true, :limit => 20
  
  has_many :comments, :as => :commentable,  :dependent => :destroy, :order => 'created_at DESC'
    
  acts_as_defensio_article
  
  has_many :facebook_addables, :as => :profile_chunks

  has_permalink :name
  # make sure we update permalink when user changes title
  before_save :create_unique_permalink
  
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


  
  # needed in case we've got multiple assets on the same page
  def unique_id
    object_id
  end
  
  def name
    # make sure the title is there, and if not, the filename is used...
    (title && !title.strip.blank?) ? title.strip : clean_filename
  end
  
  def clean_permalink
    self.permalink = nil
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
  
  def description
    return nil unless self[:description]
    self.description_html || BlueCloth::new(self[:description]).to_html
  end
  
  def length
    self.class.formatted_time(self[:length])
  end
  
  protected 
  
  def set_title_to_filename
    title = filename.split('.').first unless title
  end
   
end

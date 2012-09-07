class Asset < ActiveRecord::Base
  
  concerned_with :uploading, :radio, :statistics
  
  scope :recent, order('assets.id DESC').includes(:user)
  scope :descriptionless, where('description = "" OR description IS NULL').order('created_at DESC').limit(10)
  scope :random_order, order("RAND()")
  scope :favorited, select('distinct assets.*').includes(:tracks).where('tracks.is_favorite is ?', true).order('tracks.id DESC')
    
  

  #formats_attributes :description    
  
  has_many :tracks, :dependent => :destroy
  has_many :playlists, :through => :tracks
  belongs_to :user, :counter_cache => true
  has_many :listens, :dependent => :destroy
  has_many :listeners, 
    :through  => :listens, 
    :order    => 'listens.created_at DESC', 
    :uniq     => true, 
    :limit    => 20
  
  has_many :favoriters, 
    :source     =>  :user, 
    :through    =>  :tracks, 
    :conditions => {'tracks.is_favorite' => true}, 
    :order      =>  'tracks.created_at DESC'
    # :include    =>  :picable   
  
  has_many :comments, 
    :as         => :commentable,  
    :dependent  => :destroy, 
    :order      => 'created_at DESC'
    
  #acts_as_defensio_article(:fields =>{:permalink => :full_permalink})
  
  has_many :facebook_addables, :as => :profile_chunks
  reportable :weekly, :aggregation => :count, :grouping => :week
  has_permalink :name
  
  # make sure we update permalink when user changes title
  before_save :create_unique_permalink
  
  validates_presence_of :user_id
  
  # after_resize do |record, mp3|
  #   mp3.tag.author = "#{record.user.name} (#{record.user.site})" unless mp3.tag.author
  # end
  # the attachment_fu callback is actually named after_resize

  def self.latest(limit=10)
    includes(:user => :pic).limit(limit).order('assets.id DESC')
  end
  
  def self.id_not_in(asset_ids)
    where("assets.id NOT IN (?)", asset_ids)
  end

  def self.user_id_in(asset_ids)
    where( "assets.user_id IN (?)", user_ids)
  end
  
  # Generates magic %LIKE% sql statements for all columns
  def self.conditions_by_like(value, *columns) 
    columns = self.content_columns if columns.size==0 
    columns = columns[0] if columns[0].kind_of?(Array) 
    conditions = columns.map {|c| 
    c = c.name if c.kind_of? ActiveRecord::ConnectionAdapters::Column 
    "#{c} LIKE " + ActiveRecord::Base.connection.quote("%#{value}%") 
    }.join(" OR ") 
  end
  
  # needed for views in case we've got multiple assets on the same page
  # TODO: this is a view concern, move to helper, or better yet, deal w/it in .js
  def unique_id
    object_id
  end
  
  # make sure the title is there, and if not, the filename is used...
  def name
    (title && !title.strip.blank?) ? title.strip : clean_filename
  end
  
  # otherwise permalink gets 'stuck' on edit
  def clean_permalink
    self.permalink = nil
  end
  
  def full_permalink
    "http://#{Alonetone.url}/#{user.login}/#{permalink}"
  end
  
  def self.first_playlist
    Playlist.public.where(:track_id => Track.where(:asset_id => id).first).order('playlist.id ASC').first
  end
  
  # allows classes outside Asset to use the same format
  def self.formatted_time(time)
    if time
      min_and_sec = time.divmod(60)
      minutes = min_and_sec[0].to_i.to_s
      seconds = min_and_sec[1].to_i.to_s
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
  
  def seconds
    self[:length] # a bit backwards, ain't it?
  end
  
  # hack for sproutcore json
  def type
    'Track'
  end
  
  def guest_can_comment?
    if user.settings && user.settings.present?( 'block_guest_comments' )
      user.settings['block_guest_comments'] == "false"
    else
      true
    end
  end
  
  protected 
  
  def set_title_to_filename
    title = filename.split('.').first unless title
  end
   
end

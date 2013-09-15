class Asset < ActiveRecord::Base
  
  concerned_with :uploading, :radio, :statistics
  
  scope :recent,          -> { order('assets.id DESC').includes(:user) }
  scope :descriptionless, -> { where('description = "" OR description IS NULL').order('created_at DESC').limit(10) }
  scope :random_order,    -> { order("RAND()") }
  scope :favorited,       -> { select('distinct assets.*').includes(:tracks).where('tracks.is_favorite is ?', true).order('tracks.id DESC') }
   
  has_many :tracks, :dependent => :destroy
  has_many :playlists, :through => :tracks
  belongs_to :user, :counter_cache => true
  has_many :listens, :dependent => :destroy
  has_many :listeners, 
    -> { order('listens.created_at DESC').uniq.limit(20)},
    :through  => :listens
  
  has_many :favoriters, 
    -> { where('tracks.is_favorite' => true).order('tracks.created_at DESC') },
    :source     =>  :user, 
    :through    =>  :tracks
      
  has_many :comments, :as => :commentable, :dependent  => :destroy
    
  after_create :notify_followers
    
  has_many :facebook_addables, :as => :profile_chunks
  reportable :weekly, :aggregation => :count, :grouping => :week
 
  has_permalink :name, true
  before_update :generate_permalink!, :if => :title_changed?
  
  validates_presence_of :user_id
  
  attr_accessible :user, :mp3, :size, :name, :user_id

  # override has_permalink method to ensure we don't get empty permas
  def generate_permalink!
    self.permalink = fix_duplication(normalize(self.send(generate_from)))
    if !permalink.present?
      self.permalink = fix_duplication("untitled")
    end
  end

  def self.latest(limit=10)
    includes(:user => :pic).limit(limit).order('assets.id DESC')
  end
  
  def self.id_not_in(asset_ids)
    where("assets.id NOT IN (?)", asset_ids)
  end

  def self.user_id_in(user_ids)
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
    return title.strip if title.present?
    clean = mp3_file_name.split('.')[-2].gsub(/-|_/,' ').strip.titleize
    clean.present? ? clean : 'untitled'
  end
  
  def first_playlist
    Track.where(:asset_id => id).first.playlists.first rescue nil
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
    if user.settings.present? && user.settings['block_guest_comments'].present?
      user.settings['block_guest_comments'] == "false"
    else
      true
    end
  end
  
  def to_param
    permalink
  end
  
  def notify_followers
    if followers_exist_for?(self)
      #AssetMailer.deliver_upload_notification(self,emails_of_followers(asset)) 
    end
  end 
end

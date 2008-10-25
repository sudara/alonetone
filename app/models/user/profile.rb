class User
  
  # has a bunch of prefs
  serialize :settings
  formats_attributes :bio
  
  before_save :normalize_itunes_url
  
  def normalize_itunes_url
    self.itunes = itunes.to_s.strip.gsub(/http\:\/\//, "")
  end
  
  def has_public_playlists?
    playlists.public.size >= 1
  end
  
  def has_tracks?
    self.assets_count > 0 
  end
  
  def has_as_favorite?(asset)
    favorite_asset_ids.include?(asset.id)
  end


  def dummy_pic(size)
    case size
      when :album then 'no-pic-200.png'
      when :large then 'no-pic-83.png'
      when :small then 'no-pic-50.png'
      when :tiny then 'no-pic-25.png'
      when nil then 'no-pic-200.jpg' 
    end
  end
  
  def avatar(size = nil)
    return dummy_pic(size) unless self.has_pic?
    self.pic.public_filename(size) 
  end
  
  def favorite_asset_ids
    Track.find(:all, :conditions => {:playlist_id => favorites}).collect(&:asset_id)
  end
  
  def favorites
    @favorites ||= self.playlists.favorites.find(:first)
  end
  
  def has_pic?
    pic && !pic.new_record?
  end
  
  def site
    "#{ALONETONE.url}/#{login}"
  end
  
  def printable_bio
    self.bio_html || BlueCloth::new(self.bio).to_html
  end
  
  def website
    self[:website] || site
  end
  
  def name
    self[:display_name] || login
  end
  
  def self.dummy_pic(size)
    find(:first).dummy_pic(size)
  end
end
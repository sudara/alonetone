class Asset
  
  def self.radio(params, user, session)
    per_page = (params[:per_page] && params[:per_page].to_i < 50) ? params[:per_page] : 5
    common_options = {:per_page => per_page, :page => params[:page]}
    
    case params[:source]
    when 'favorites'
      Track.favorites.paginate(:all, common_options)
    when 'your_favorite_alonetoners'
      Asset.from_favorite_artists_of(user, common_options)
    when 'mangoz_shuffle'
      Asset.mangoz(user, common_options)
    when 'most_favorited'
      Asset.most_favorited(per_page, (per_page.to_i*(params[:page].to_i || 0)))
    when 'songs_you_have_not_heard'
      Asset.not_heard_by(user, per_page)
    when 'popular'
      Asset.paginate(:all, {:order => 'hotness DESC'}.merge(common_options))
    else #latest
      Asset.recent.paginate(:all, common_options)
    end
  end
  
  # random radio, without playing the same track twice in a 24 hour period
  def self.mangoz(user, pagination_options)
    conditions = (user && user.listens.size > 10) ? ["assets.id NOT IN (?) ",user.listened_to_today_ids] : nil
    Asset.paginate(:all, {:conditions => conditions, :order => 'RAND()'}.merge(pagination_options))
  end
  
  # random radio, sourcing from the user's favorite artists
  def self.from_favorite_artists_of(user, pagination_options)
    Asset.paginate(:all,{ 
      :conditions => ['user_id IN (?) AND assets.id NOT IN (?)',user.most_listened_to_user_ids(10),user.listened_to_today_ids], 
      :order => 'RAND()'}.merge(pagination_options))
  end
  
  # finds all tracks not heard by the logged in user (or just the latest tracks for guests)
  def self.not_heard_by(user, limit)
    conditions = (user && user.listens.size > 10 ) ? ["assets.id NOT IN (?) ",user.listened_to_ids] : nil
    Asset.find(:all, :conditions => conditions, :order => 'created_at DESC', :limit => limit)
  end
  
  def self.most_favorited(limit, offset)
    Asset.find(Track.most_favorited(limit, offset))
  end
  
  def self.most_listened_to(pagination_options)
    Asset.paginate(:all, {:order => 'listens_count DESC'}.merge(pagination_options))
  end
end
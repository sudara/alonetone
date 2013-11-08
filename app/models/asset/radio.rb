class Asset
  
  def self.radio(channel, params, user)
    common_options = {:per_page => 20, :page => params[:page]}

    case channel
      when 'favorites'
        Asset.favorited.paginate(common_options)

      when 'your_favorite_alonetoners'
        Asset.from_favorite_artists_of(user, common_options)

      when 'mangoz_shuffle'
        Asset.mangoz(user, common_options)

      when 'most_favorited'
        Asset.order('favorites_count DESC').paginate(common_options)

      when 'songs_you_have_not_heard'
        Asset.not_heard_by(user, common_options)

      when 'popular'
        Asset.order('hotness DESC').paginate(common_options)
        
      when 'those_you_follow'
        Asset.recent.new_tracks_from_followees(user, common_options)
      else # latest
        Asset.recent.paginate(common_options)
    end
  end
  

  # random radio, without playing the same track twice in a 24 hour period
  def self.mangoz(user, pagination_options) 
    ids = user && user.listened_more_than?(10) && user.listened_to_today_ids
    Asset.random_order.id_not_in(ids).paginate(pagination_options)
  end

  
  # random radio, sourcing from the user's favorite artists
  def self.from_favorite_artists_of(user, pagination_options)
    Asset.
      id_not_in( user.listened_to_today_ids ).
      user_id_in( user.most_listened_to_user_ids(10) ).
      random_order.
      paginate( pagination_options)
  end
  

  # finds all tracks not heard by the logged in user (or just the latest tracks for guests)
  def self.not_heard_by(user, pagination_options)
    Asset.random_order.id_not_in(user && user.listened_to_ids).paginate(pagination_options)      
  end

  
  def self.most_listened_to(pagination_options)
    Asset.order('listens_count DESC').paginate(pagination_options)
  end
  
  # Since the raw sql doesn't give a meaningful performance boost, I removed it in favor of 
  # keeping the code clean, dry and more flexible (pagination, etc.)
  #
  # SELECT DISTINCT a.* FROM assets a INNER JOIN users u ON (a.user_id = u.id) INNER JOIN followings f ON (f.user_id = u.id) WHERE f.follower_id = :user_id ORDER BY a.created_at DESC LIMIT 15
  #
  def self.new_tracks_from_followees(user, pagination_options)
    Asset.recent.user_id_in(user.follows_user_ids).paginate(pagination_options)
  end
end

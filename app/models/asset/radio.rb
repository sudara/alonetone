class Asset
  
  def self.radio(channel, params, user)
    per_page = (params[:per_page] && params[:per_page].to_i < 50) ? params[:per_page] : 5

    common_options = {:per_page => per_page, :page => params[:page]}

    case channel
      when 'favorites'
        Asset.favorited.paginate(:all, common_options)

      when 'your_favorite_alonetoners'
        Asset.from_favorite_artists_of(user, common_options)

      when 'mangoz_shuffle'
        Asset.mangoz(user, common_options)

      when 'most_favorited'
        Asset.order_by('favorites_count DESC').paginate(:all, common_options)

      when 'songs_you_have_not_heard'
        Asset.not_heard_by(user, per_page)

      when 'popular'
        Asset.order_by('hotness DESC').paginate(:all, common_options)

      else # latest
        Asset.recent.paginate(:all, common_options)
    end
  end
  

  # random radio, without playing the same track twice in a 24 hour period
  def self.mangoz(user, pagination_options)    
    assets = Asset.random_order
    
    assets.id_not_in(user.listened_to_today_ids) \
    if user && user.listened_more_than?(10)

    assets.paginate(:all, pagination_options)
  end

  
  # random radio, sourcing from the user's favorite artists
  def self.from_favorite_artists_of(user, pagination_options)
    Asset.
      id_not_in( user.listened_to_today_ids ).
      user_id_in( user.most_listened_to_user_ids(10) ).
      random_order.
      paginate(:all, pagination_options)
  end
  

  # finds all tracks not heard by the logged in user (or just the latest tracks for guests)
  def self.not_heard_by(user, limit)
    assets = Asset.random_order.limit_by(limit)
    
    assets.id_not_in(user.listened_to_ids) \
    if user && user.listened_more_than?(0)
    
    return assets
  end

  
  def self.most_listened_to(pagination_options)
    Asset.
      order_by('listens_count DESC').
      paginate(:all, pagination_options)
  end
end
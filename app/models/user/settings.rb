class User
  def has_public_playlists?
    playlists.only_public.count >= 1
  end

  def has_tracks?
    assets_count > 0
  end

  def has_as_favorite?(asset)
    favorite_asset_ids.include?(asset.id)
  end

  def dummy_pic(size)
    case size
    when :album then 'default/no-pic.png'
    when :large then 'default/no-pic_large.png'
    when :small then 'default/no-pic_small.png'
    when :tiny then 'default/no-pic_tiny.png'
    when nil then 'default/no-pic.png'
    end
  end

  def favorite_asset_ids
    Track.where(playlist_id: favorites).pluck(:asset_id)
  end

  def favorites
    playlists.favorites.first
  end

  def name
    self[:display_name] || login
  end

  def self.dummy_pic(size)
    first.dummy_pic(size)
  end

  def wants_email?
    # anyone who doesn't have it set to false, aka, opt-out
    settings.empty? || (settings[:email_new_tracks] != "false")
  end

  def has_setting?(setting, value = nil)
    if !value.nil? # account for testing against false values
      settings.present? && settings[setting].present? && (settings[setting] == value)
    else
      settings.present? && settings[setting].present?
    end
  end
end

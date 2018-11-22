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

  def avatar(size = nil)
    return dummy_pic(size) if has_no_avatar?
    pic.pic.url(size)
  end

  def has_no_avatar?
    Alonetone.try(:show_dummy_pics) || !pic.present? || !pic.try(:pic).present?
  end

  def favorite_asset_ids
    Track.where(playlist_id: favorites).pluck(:asset_id)
  end

  def favorites
    playlists.favorites.first
  end

  def has_pic?
    pic && !pic.new_record?
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

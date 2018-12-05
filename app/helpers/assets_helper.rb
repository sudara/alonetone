module AssetsHelper

  def asset_cache_key(asset, favorite)
    [ asset.cache_key,
      logged_in? ? "user" : "guest",
      favorite.nil? ? "false" : favorite.user_id,
      theme_name
    ].join('/')
  end

  def radio_option(path, name, default = false, disabled_if_not_logged_in = false)
    classes = "radio_channel #{params[:source] == path ? 'selected' : ''} #{!logged_in? && disabled_if_not_logged_in ? 'disabled' : ''}"
    content_tag :li, (radio_button_tag('source', path, (params[:source] == path || !params[:source] && default),
      disabled: !logged_in? && disabled_if_not_logged_in) + content_tag(:span, (disabled_if_not_logged_in ? "#{name} #{login_link}" : name).html_safe, class: 'channel_name')),
       class: classes
  end

  def media_url(asset)
    if asset.is_a?(Greenfield::AttachedAsset)
      Greenfield::Engine.routes.url_helpers
                        .user_post_attached_asset_path(asset.post.user, asset.alonetone_asset,
                                      asset.permalink, format: :mp3)
    elsif @playlist
      user_show_track_in_playlist_path(asset.user, @playlist, asset, format: :mp3)
    else
      user_track_path(asset.user, asset, format: :mp3)
    end
  end
end

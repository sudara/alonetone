# frozen_string_literal: true

module TracklistHelper
  # Single source of truth for the data-track-* attributes the persistent player
  # reads off each row (see #descriptor in tracklist_controller.js). Returns the
  # inner `data:` hash; spread it with tag.attributes. Pass overrides for
  # contexts whose mp3/page URL, cover, or title differ from a plain track page.
  def track_descriptor_data(asset, url: nil, page_url: nil, image: nil, title: nil)
    {
      track_id: asset.id,
      track_url: url || user_track_path(asset.user.login, asset.permalink, format: :mp3),
      track_title: title || asset.name,
      track_artist: asset.user.name,
      track_artist_url: user_home_path(asset.user),
      track_page_url: page_url || user_track_path(asset.user, asset.permalink),
      track_image: image || image_path(user_avatar_url(asset.user, variant: :small_avatar)),
      track_waveform: waveform_user_track_path(asset.user.login, asset.permalink),
      track_duration: asset.length
    }
  end
end

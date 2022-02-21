# frozen_string_literal: true

module PlaylistsHelper
  def title_and_year_for(playlist)
    title = playlist.title.to_s
    title += " <span>(#{playlist.year})</span>" if playlist.year.present?
    title.html_safe
  end

  # DIV element which is ‘filled’ by the JavaScript with a a generated pattern based on the
  # playlist title.
  def playlist_cover_div(playlist)
    content_tag(:div, '', class: 'generated_svg_cover', title: playlist.title, data: { "controller": "svg-cover" })
  end

  # Returns a URL to the playlist's cover or nil when there is no cover.
  def playlist_cover_url(playlist, variant:)
    playlist.cover_image_location(variant: variant).to_s if playlist.cover_image_present?
  end

  # Returns an <img> tag with the cover for the playlist. Breaks when the playlist does not have
  # a cover.
  def playlist_cover_image(playlist, variant:)
    image_tag(
      playlist_cover_url(playlist, variant: variant),
      alt: 'Playlist cover'
    )
  end

  # Returns an <img> tag when the playlist has a cover or a <div> to be filled by JavaScript when
  # playlist has no cover or show_dummy_image is enabled.
  def playlist_cover(playlist, variant:)
    if Rails.application.show_dummy_image? || !playlist.cover_image_present?
      playlist_cover_div(playlist)
    else
      playlist_cover_image(playlist, variant: variant)
    end
  end

  def external_link_for(link)
    return unless link.present?

    text = case link
    when /youtube/i
      service = 'youtube'
      '<i class="youtube"></i><span class="service_name">Youtube</span><span class="action_text">Watch</span>'
    when /bandcamp/i
      service = 'bandcamp'
      '<i class="bandcamp"></i><span class="service_name">Bandcamp</span><span class="action_text">Buy</span>'
    when /spotify/i
      service = 'spotify'
      '<i class="spotify"></i><span class="service_name">Spotify</span><span class="action_text">Stream</span>'
    when /app\=music/i
      service = 'apple'
      '<i class="apple_music"></i><span class="service_name">Apple Music</span><span class="action_text">Stream</span>'
    when /app\=itunes/i
      service = 'itunes'
      '<i class="itunes"></i><span class="service_name">iTunes</span><span class="action_text">Buy</span>'
    when /play\.google/i
      service = 'google_play'
      '<i class="fa fa-google"></i>Google<span class="action_text">Stream</span>'
    else
      '<i class="fa fa-link"></i>Website<span class="action_text">Visit</span>'
    end.html_safe
    link_to(text, link, class: service).html_safe
  end

  def first_active_track?(track, asset)
    if asset.present? && (track.asset.id == asset.id) && !defined?(@active_set)
      @active_set = true
      true
    else
      false
    end
  end
end

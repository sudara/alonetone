# frozen_string_literal: true

module PlaylistsHelper
  def title_and_year_for(playlist)
    title = playlist.title.to_s
    title += " (#{playlist.year})" if playlist.year.present?
    title
  end

  def allow_greenfield_playlist_downloads?(user)
    user.greenfield_enabled? && Rails.application.remote_storage?
  end

  # DIV element which is ‘filled’ by the JavaScript with a a generated pattern based on the
  # playlist title.
  def playlist_cover_div
    content_tag(:div, '', class: 'no_pic')
  end

  # Returns a different variant when the Pic with the supplied ID does not have the variant.
  def downgrade_variant(playlist, variant:)
    if playlist.ancient_cover_quality?
      downgrade_ancient_variant(variant: variant)
    elsif playlist.legacy_cover_quality?
      downgrade_legacy_variant(variant: variant)
    else
      variant
    end
  end

  # Returns a URL to the playlist's cover or nil when there is no cover.
  def playlist_cover_url(playlist, variant:)
    if playlist.cover_image_present?
      variant = downgrade_variant(playlist, variant: variant)
      playlist.cover_url(variant: variant)
    end
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
      playlist_cover_div
    else
      playlist_cover_image(playlist, variant: variant)
    end
  end

  # @deprecated Returns default cover image URL for dark theme.
  def dark_default_cover_url(variant:)
    path = case variant
           when :small then 'default/no-cover-50.jpg'
           when :large then 'default/no-cover-125.jpg'
           when :album then 'default/no-cover-200.jpg'
           else 'default/no-cover-200.jpg'
    end
    image_url(path)
  end

  # @deprecated Returns a URL to the playlist's cover or a default image when there is no cover.
  def dark_playlist_cover_url(playlist, variant:)
    if Rails.application.show_dummy_image? || !playlist.cover_image_present?
      dark_default_cover_url(variant: variant)
    else
      playlist_cover_url(playlist, variant: variant)
    end
  end

  def greenfield_upload_form(user, playlist)
    # leave these hashrokets. breaking spec/request/assets_controller_spec.rb
    # Will look into it later
    data = {
      'expected-content-type' => Greenfield::PlaylistDownload::CONTENT_TYPE.join(' '),
      'max-file-size' => Greenfield::PlaylistDownload::MAX_SIZE,
      'max-file-size-human' =>
        number_to_human_size(Greenfield::PlaylistDownload::MAX_SIZE).downcase
    }
    options = {
      id: "s3-uploader",
      key_starts_with: "greenfield/",
      acl: "authenticated-read",
      callback_url: downloads_user_playlist_path(user, playlist),
      max_file_size: Greenfield::PlaylistDownload::MAX_SIZE,
      data: data
    }
    s3_uploader_form(options) { yield("") }
  end

  def external_link_for(link)
    return unless link.present?

    text = case link
    when /youtube/i
      service = 'youtube'
      '<i class="youtube"></i><span class="service-name">Youtube</span><span class="action-text">Watch</span>'
    when /bandcamp/i
      service = 'bandcamp'
      '<i class="bandcamp"></i><span class="service-name">Bandcamp</span><span class="action-text">Buy</span>'
    when /spotify/i
      service = 'spotify'
      '<i class="spotify"></i><span class="service-name">Spotify</span><span class="action-text">Stream</span>'
    when /app\=music/i
      service = 'apple'
      '<i class="apple_music"></i><span class="service-name">Apple Music</span><span class="action-text">Stream</span>'
    when /app\=itunes/i
      service = 'itunes'
      '<i class="itunes"></i><span class="service-name">iTunes</span><span class="action-text">Buy</span>'
    when /play\.google/i
      service = 'google_play'
      '<i class="fa fa-google"></i>Google<span class="action-text">Stream</span>'
    else
      '<i class="fa fa-link"></i>Website<span class="action-text">Visit</span>'
    end.html_safe
    link_to(text, link, class: service).html_safe
  end

  private

  def downgrade_ancient_variant(variant:)
    %i[greenfield original].include?(variant) ? :album : variant
  end

  def downgrade_legacy_variant(variant:)
    variant == :greenfield ? :original : variant
  end
end

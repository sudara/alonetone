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

  # DIV element which is ‘filled’ by the JavaScript with a a generated pattern
  # based on the playlist title.
  def playlist_cover_div
    content_tag(:div, '', class: 'no_pic')
  end

  # Returns true when the Pic with this ID does not have a greenfield variant.
  def no_greenfield_variant?(pic_id)
    (69806..72848).include?(pic_id)
  end

  # Returns true when the Pic with this ID does not have a greenfield nor
  # an original variant.
  def no_greenfield_and_original_variant?(pic_id)
    pic_id < 69807
  end

  # Returns a different variant when the Pic with the supplied ID does not have
  # the variant.
  def downgrade_variant(pic_id, variant:)
    if no_greenfield_and_original_variant?(pic_id)
      [:greenfield, :original].include?(variant) ? :album : variant
    elsif no_greenfield_variant?(pic_id)
      (variant == :greenfield) ? :original : variant
    else
      variant
    end
  end

  # Returns a URL to the playlist's cover or nil when there is no cover.
  def playlist_cover_url(playlist, variant:)
    if playlist.cover_image_present?
      variant = downgrade_variant(playlist.pic.id, variant: variant)
      playlist.cover_url(variant: variant)
    end
  end

  def playlist_cover(playlist, size)
    if Rails.application.show_dummy_image? || playlist.has_no_cover?
      return playlist_cover_div
    # greenfield size did not exist before this id
    elsif (size == :greenfield) && ((playlist.pic.id > 69806) && (playlist.pic.id < 72848))
      size = :original
    elsif ((size == :greenfield) || (size == :original)) && (playlist.pic.id < 69807)
      size = :album
      @old_cover_alert = true
    end

    image_tag playlist.cover(size)
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
    text = case link
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
      '<i class="fa fa-google"></i>Google<span class="action-text">Stream</span>'
           else
      '<i class="fa fa-link"></i>Website<span class="action-text">Visit</span>'
    end.html_safe
    link_to(text, link, class: service).html_safe
  end
end

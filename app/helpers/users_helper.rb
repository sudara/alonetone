# frozen_string_literal: true

module UsersHelper
  def website_for(user)
    "#{user.name}'s website " + (link_to user.website.to_s, ('http://' + h(user.website)))
  end

  def website_for_simple(user)
    (link_to user.website.to_s, ('http://' + h(user.website)))
  end

  def itunes_link_for(user)
    link_to "Open #{user.name}'s music in iTunes", 'http://' + h(user.itunes)
  end

  # Returns the user's location, e.g. from Vienna, AT.
  def user_location(profile = nil)
    return '' unless profile

    locality = [profile.city.presence, profile.country.presence].compact.map(&:strip).join(', ')
    locality.present? ? 'from ' + locality : ''
  end

  # Returns a summary of the user's history on Alonetone.
  def user_summary(user = nil)
    return '' unless user

    [
      user.name,
      user.assets_count > 0 ? pluralize(user.assets_count, 'uploaded tracks') : nil,
      "Joined alonetone #{user.created_at.to_date.to_formatted_s(:long)}",
      user_location(user.profile).presence
    ].compact.join("\n")
  end

  # Returns an <img> element with the avatar for a user. Automatically switches to the dark theme
  # when selected by the user.
  def user_image_link(user = nil, variant:)
    white_theme_user_image_link(user, variant: variant)
  end

  # Returns an <a> element with the avatar for a user or an <img> element with the default
  # avatar when the user is nil.
  def white_theme_user_image_link(user = nil, variant:)
    if user
      link_to(
        user_image(user, variant: variant),
        user_home_path(user),
        title: user_summary(user)
      )
    else
      user_image(user, variant: variant)
    end
  end

  # Returns an <img> tag with the avatar for the user or the default avatar when the user is nil.
  def user_image(user = nil, variant:)
    _user_image(user, url: user_avatar_url(user, variant: variant))
  end

  # Returns a URL to the user's avatar or the default Alonetone avatar when user is nill or the
  # user has no avatar. Always returns the default avatar when `show_dummy_image' is enabled in the
  # config.
  def user_avatar_url(user = nil, variant:)
    if user.nil? || Rails.application.show_dummy_image?
      UsersHelper.no_avatar_path
    else
      user.avatar_image_location(variant: variant) || UsersHelper.no_avatar_path
    end.to_s
  end

  # Returns the image path to use as a default avatar.
  def self.no_avatar_path
    'default/no-pic_white.svg'
  end

  def favorite_toggle(asset)
    link_to('add to favorites', toggle_favorite_path(asset_id: asset.id), class: 'add_to_favorites')
  end

  def follow_toggle(user)
    return unless logged_in? && (user.id != current_user.id)

    already_following = current_user.is_following?(user)
    if already_following
      link_to('<div class="sprites-heart-broken"></div> un-follow'.html_safe, toggle_follow_path(login: user.login),
        class: 'follow following')
    else
      link_to('<div class="sprites-heart-with-plus"></div> follow'.html_safe, toggle_follow_path(login: user.login),
        class: 'follow')
    end
  end

  def new_to_user?(thing)
    thing && (logged_in? && current_user.last_request_at) && (current_user.last_login_at < thing.created_at.utc)
  end

  def cache_key_for_follows(follows)
    count          = follows.count
    max_updated_at = follows.maximum(:updated_at).try(:utc).try(:to_s, :number)
    "follows/all-#{count}/#{max_updated_at}"
  end

  def digest_for_users
    if (@sort == "last_seen") || @sort.nil?
      @users.first.last_request_at
    else
      cache_digest(@users)
    end
  end

  private
  def _user_image(user, url:)
    image_tag(
      url.to_s,
      class: user&.avatar_image_present? ? nil : 'no_border',
      alt: user ? "#{user.name}'s avatar" : nil
    )
  end
end

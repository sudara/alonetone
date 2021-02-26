module ApplicationHelper
  include ::Pagy::Frontend
  @@listen_sources = %w[itunes]

  def authorized_for(user_related_record)
    logged_in? && (current_user.admin? || (user_related_record.user == current_user))
  end

  def authorized_as(user_account)
    logged_in? && ((current_user.id.to_s == user_account.id.to_s) || current_user.admin?)
  end

  def authorized_for_comment(comment)
    (moderator? || admin?) || (logged_in? && (comment.commenter == current_user || comment.user == current_user))
  end

  def pagy_url_for(page, pagy)
    params = request.query_parameters.merge(:only_path => true, pagy.vars[:page_param] => page )
    url_for(params)
  end

  def edit_or_show(_user, playlist)
    if authorized_for(playlist)
      edit_user_playlist_path(@user.login, playlist)
    else
      user_playlist_path(@user.login, playlist.permalink)
    end
  end

  def mp3_info_for(asset)
    mp3 = Mp3Info::Mp3Info.new(asset.authenticated_s3_url)
    "Filename: #{asset.permalink}<br/>Length: #{mp3.length}<br/>Name: #{mp3.tag.title}<br/>Artist: #{mp3.tag.artist} <br/>Album: #{mp3.tag.album}<br/>#{mp3}"
  rescue StandardError
    "File #{asset.permalink} was unopenable or did not exist."
  end

  def offer(html)
    result = '<div id="offer">'
    result += html
    result += '</div>'
    result
  end

  def rss_date(date)
    CGI.rfc1123_date(date)
  end

  def track_name_for(asset, length = 40)
    truncate(asset.name, length: length).html_safe
  end

  # Awesome truncate
  # First regex truncates to the length, plus the rest of that word, if any.
  # Second regex removes any trailing whitespace or punctuation (except ;).
  # Unlike the regular truncate method, this avoids the problem with cutting
  # in the middle of an entity ex.: truncate("this &amp; that",9)  => "this &am..."
  # though it will not be the exact length.
  def awesome_truncate(text, length = 30, truncate_string = "&hellip;")
    return "" if text.blank?

    l = length - truncate_string.mb_chars.length
    result = text.mb_chars.length > length ? (text[/\A.{#{l}}\w*\;?/m][/.*[\w\;]/m] || '') + truncate_string : text
    result.html_safe
  end

  # Comments are plaintext and don't use this helper
  # credits/profile/playlist currently are markdowned without line breaks
  def markdown(text)
    return "" unless text

    CommonMarker.render_doc(text, :SMART).to_html([:NOBREAKS]).html_safe
  end

  # full track descriptions should have hard line breaks
  def format_track_description(text)
    return "" unless text

    nofollowize(CommonMarker.render_doc(text, :SMART, [:autolink]).to_html(:HARDBREAKS)).html_safe
  end

  # https://en.wikipedia.org/wiki/Nofollow#rel="ugc"
  def nofollowize(markdown)
    markdown.gsub('<a href', '<a rel="nofollow ugc" href')
  end

  def link_to_play(asset, referer = nil)
    link_to ' ', user_track_path(asset.user.login, asset.permalink, format: :mp3, referer: referer), id: "play-#{asset.unique_id}", class: 'play_link', title: 'click to play the mp3'
  end

  def navigation_item(text, link, options = nil)
    content_tag(:li, link_to_unless_current(text.html_safe, link, options),
      class: current_page?(link) ? 'current' : '',
      data: { 'subnav-target': 'item' })
  end

  def link_source(source)
    if source == 'https://alonetone.com'
      link_to "home page", "/"
    elsif source.match(/soundmanager2_flash9/).present?
      link_to "alonetone", "/"
    else
      link_to source.gsub!(/http:\/\/alonetone.com\/|https:\/\/alonetone.com\/|http:\/\/localhost:3000\/|http:\/\/beta.alonetone.com\//, '/'), source
    end
  end

  def check_for_and_display_flashes
    flashes = []
    [flash[:notice], flash[:error], flash[:info], flash[:ok]].each do |flash|
      flashes << (render partial: 'shared/flash', object: flash) if flash && !flash.empty?
    end
    flashes.join.html_safe
  end

  def check_for_and_display_welcome_back
    render partial: 'shared/welcome_back' if welcome_back?
  end

  def authorized?
    admin? || @user === current_user
  end

  def login_link
    logged_in? ? '' : '(' + (link_to 'login', login_path) + ')'
  end

  def feed_icon_tag(title, url)
    (@feed_icons ||= []) << { url: url, title: title }
    link_to image_tag('icons/feed-icon.png', size: '14x14', alt: "Subscribe to #{title}"), url, class: 'rss'
  end

  def friendly_time_ago(time)
    return "Unknown" unless time.present?

    if time > 2.weeks.ago
      time_ago_in_words(time) + ' ago'
    else
      time.to_date.to_s(:long)
    end
  end

  def flag_for(country)
    return "" unless country.present?

    image_tag("flags/#{country.downcase}.svg", size: '80x40', style: 'float:right; clear:none;').html_safe
  end

  # Mephisto said it best...
  def sanitize_feed_content(html, sanitize_tables = false)
    options = sanitize_tables ? {} : { tags: %w[table thead tfoot tbody td tr th] }
    sanitized = html.strip do |html|
      html.gsub! /&amp;(#\d+);/ do |_s|
        "&#{Regexp.last_match(1)};"
      end
    end
    sanitized
  end

  def should_display_track_with_comment?
    !@single_track && !@playlist && !@asset
  end

  def svg_path(svg)
    File.join(Rails.root, 'app', 'assets', 'images', svg)
  end

  def theme_name
    session[:theme]
  end

  def other_theme_name
    light_theme? ? 'dark' : 'light'
  end

  def light_theme?
    theme_name == 'light'
  end

  def dark_theme?
    theme_name == 'dark'
  end

  def inline_form_error(error)
    if error.present?
      content_tag :div, error.first.humanize, class: 'inline_form_error'
    end
  end

  def forum_image(slug)
    themed_illustration_image("forums/#{slug}.png")
  end

  def themed_illustration_image(path)
    name = path.split('.')[0]
    extension = path.split('.')[1]
    image_tag("illustrations/#{name}-#{theme_name}.#{extension}", class: 'themeable') +
      image_tag("illustrations/#{name}-#{other_theme_name}.#{extension}", class: 'themeable hidden')
  rescue Sprockets::Rails::Helper::AssetNotFound
    tag.img "illustrations/#{name}-#{theme_name}.#{extension}", class: 'themeable'
  end

  protected
end

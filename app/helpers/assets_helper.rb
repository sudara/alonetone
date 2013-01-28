# -*- encoding : utf-8 -*-
module AssetsHelper

  def share_on_facebook_link(asset)
    link = CGI.escape(user_track_url(asset.user, asset.permalink,:format => :mp3))
    title = "Listen To \"#{asset.title}\" by #{asset.user.name}"
    "http://www.facebook.com/sharer/sharer.php?s=100&p[url]=#{link}&p[title]=#{title}&p[images][0]=#{asset.user.avatar(:medium)}"
  end

  def radio_option(path,name, default = false,disabled_if_not_logged_in=false)
      content_tag :li, (radio_button_tag('source', path, (params[:source] == path || (!params[:source]) && default), 
        :disabled => !logged_in? && disabled_if_not_logged_in) + content_tag(:span, (disabled_if_not_logged_in ? "#{name} #{login_link}" : name), :class=> 'channel_name')),
         :class => "radio_channel #{params[:source] == path ? 'selected' : ''} #{!logged_in? && disabled_if_not_logged_in ? 'disabled' : ''}"
  end
end

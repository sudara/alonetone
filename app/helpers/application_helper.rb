# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  @@listen_sources = %w(itunes home download facebook)

  def authorized_for(user_related_record)
    logged_in? && (current_user.admin? || (user_related_record.user == current_user))
  end
  
  def authorized_for_comment(commment)
    (logged_in? && admin?) || (logged_in? && (comment.commenter == current_user || comment.user == current_user))
  end
  
  def edit_or_show(user, playlist)
    if authorized_for(playlist)
      edit_user_playlist_path(@user.login, playlist)
    else
      user_playlist_path(@user.login, playlist.permalink)
    end
  end
  
  def mp3_info_for(asset)
    mp3 = Mp3Info::Mp3Info.new(asset.authenticated_s3_url)
    "Filename: #{asset.permalink}<br/>Length: #{mp3.length}<br/>Name: #{mp3.tag.title}<br/>Artist: #{mp3.tag.artist} <br/>Album: #{mp3.tag.album}<br/>#{mp3.to_s}"
  rescue
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
  

  
  def track_name_for(asset, length=40)
    truncate(h(asset.name),length)
  end

  def link_to_play(asset, referer=nil)
    link_to ' ', formatted_user_track_path(asset.user.login, asset.permalink, :mp3), :id=>"play-#{asset.id}", :class => 'play_link', :referer => referer
  end
  
  def user_nav_item(text, link, added_class='link')
    content_tag(:li, link_to_unless_current(text, link),:class=> ("#{added_class} #{"current" if current_page?(link)}"))
  end
  
  def link_source(source)
    return source if @@listen_sources.include?(source) || source == 'alonetone' || source == 'unknown'
    link_to source.gsub!(/http:\/\/alonetone.com\/|http:\/\/localhost:3000\/|http:\/\/staging.alonetone.com\//, ''), source
  end
  
  def recently_online
    @online.each {|person| link_to person.login, user_home_path(person) }
  end
  
  def check_for_and_display_flashes
    flashes = []
    [flash[:notice], flash[:error], flash[:info], flash[:ok]].each do |flash|
      flashes << (render :partial => 'shared/flash', :object => flash) if (flash && !flash.empty?)
    end
    flashes.join
  end
  
  def check_for_and_display_notices
    
  end
  
  def authorized?
    admin? || @user === current_user 
  end
  
  def notice_for(notice, h1_text, &block)
    concat content_tag(:div, ((content_tag :h1, h1_text, :class => 'notice') + 
      hide_notice_link(notice) + 
      capture(&block)), :class => 'notice'),
      block.binding unless notice_hidden?(notice)
  end
  
  def hide_notice_link(notice)
    link_to ['Ok, hide this notice', 'Yup! all good, thanks'].rand, 
      user_path(current_user, :user =>{:settings => {:hide_notice => {notice => true}}}, :method => :put),
      :class => 'hide_notice' if logged_in?
  end
  
  protected 
end

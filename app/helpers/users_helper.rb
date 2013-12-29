module UsersHelper
    
  def website_for(user)
    "#{user.name}'s website " + (link_to "#{user.website}", ('http://'+h(user.website)))
  end
  
  def itunes_link_for(user)
    link_to "Open #{user.name}'s music in iTunes", 'http://'+h(user.itunes)
  end
  
  def avatar(user, size=nil)
    return "default/no-pic_#{size}.png" if Alonetone.try(:default_user_images)
    case size
      when 100 then image_tag(user.has_pic? ? user.pic.pic.url(:large) : 'default/no-pic-thumb100.jpg')
      when 50 then image_tag(user.has_pic? ? user.pic.pic.url(:small) : 'default/no-pic-thumb50.jpg')
      when nil then image_tag(user.has_pic? ? user.pic.pic.url(:tiny) : 'default/no-pic.jpg' )
    end
  end
  
  def user_location(user)
    if (user.try(:city).present? && user.try(:country)).present?
      "from #{[user.city.strip, user.country.strip].compact.join(', ')}" 
    elsif (user.try(:city).present? || user.try(:country)).present?
      location = "#{user.try(:city) || user.try(:country)}"
      "from #{location}" 
    else
      ""
    end
  end
  
  def user_image_link(user, size = :large)
    link_to(image_tag(user.avatar(size),
      :class => (user.has_pic? ? '' : 'no_border'),
      :alt => "#{user.name}"), 
      user_home_path(user), 
      :title => " #{user.name}
 #{user.assets_count > 0 ? pluralize(user.assets_count,'uploaded tracks') : ''} 
 Joined alonetone #{user.created_at.to_date.to_s(:long)}
 #{user_location(user)}") 
  end
  
  def notice_hidden?(notice)
    logged_in? && current_user.has_setting?('hide_notice') && current_user.settings['hide_notice'][notice].present?
  end
  
  def favorite_toggle(asset)
    link_to('add to favorites', toggle_favorite_path(:asset_id => asset.id), :class => 'add_to_favorites')
  end
  
  def follow_toggle(user)
    return unless logged_in? and user.id != current_user.id
    already_following = current_user.is_following?(user)
    if already_following
      link_to('<div class="sprites-heart-broken"></div> un-follow'.html_safe, toggle_follow_user_path(current_user, :followee_id => user.id), 
        :class => 'follow following') 
    else  
      link_to('<div class="sprites-heart-with-plus"></div> follow'.html_safe, toggle_follow_user_path(current_user, :followee_id => user.id), 
        :class => 'follow')
    end
  end
  
  def new_to_user?(thing)
    thing && (logged_in? and current_user.last_session_at) && (current_user.last_session_at < thing.created_at.utc)
  end
  
  def cache_key_for_follows(follows)
    count          = follows.count
    max_updated_at = follows.maximum(:updated_at).try(:utc).try(:to_s, :number)
    "follows/all-#{count}-#{max_updated_at}"
  end

  def digest_for_users 
    if @sort == "last_seen" or @sort == nil
      @users.first.last_request_at
    else
      cache_digest(@users)
    end
  end
  
end

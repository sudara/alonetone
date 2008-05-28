module UsersHelper
  
  def website_for(user)
    "#{user.name}'s website " + (link_to "#{user.website}", ('http://'+h(user.website)))
  end
  
  def myspace_for(user)
    link_to "#{user.name} on Myspace.com",('http://myspace.com/'+h(user.myspace))
  end
  
  def itunes_link_for(user)
    link_to "Open #{user.name}'s music in iTunes", 'http://'+h(user.itunes)
  end
  
  def avatar(user, size=nil)
    case size
      when 100 then image_tag(user.has_pic? ? user.pic.public_filename(:large) : 'no-pic-thumb100.jpg')
      when 50 then image_tag(user.has_pic? ? user.pic.thumb.public_filename(:small) : 'no-pic-thumb50.jpg')
      when nil then image_tag(user.has_pic? ? user.pic.public_filename(:tiny) : 'no-pic.jpg' )
    end
  end
  
  def user_location(user)
    if (user.present?(:city) || user.present?(:country))
      "from #{[user.city, user.country].compact.join(', ')}" 
    end
  end
  
  def user_image_link(user, size = :large)
    link_to(image_tag(user.avatar(size),:alt => "#{user.name} on alonetone"), user_home_path(user), :title => "#{user.name} on alonetone") 
  end
  
  def notice_hidden?(notice)
    logged_in? && current_user.present?(:settings) && current_user.settings.present?('hide_notice') && current_user.settings['hide_notice'].present?(notice)
  end
  
  def setting(symbol_or_string, user=current_user)
    logged_in? && user.settings && user.settings[symbol_or_string.to_sym]
  end
  
  def favorite_toggle(asset)
    return unless logged_in?
    link_to((asset.is_favorite_of?(current_user) ? 'remove from favorites' : 'add to favorites'), toggle_favorite_user_path(current_user, :asset_id => asset.id), 
      :class => 'add_to_favorites '+((asset.is_favorite_of? current_user) ? 'favorited' : ''))
  end

end

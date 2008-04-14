module UsersHelper
  
  def user_image_link(user, size = :large)
    link_to(image_tag(user.avatar(size),:alt => "#{user.name} on alonetone"), user_home_path(user), :alt => "#{user.name} on alonetone") 
  end
  
  def setting(symbol_or_string)
    if logged_in? && current_user.settings
      current_user.settings[symbol_or_string.to_sym]
    end
  end

end

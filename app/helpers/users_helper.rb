module UsersHelper
  
  def user_image_link(user, size = :large)
    link_to(image_tag(user.avatar(size),:alt => "#{user.name} on alonetone"), user_home_path(user), :alt => "#{user.name} on alonetone") 
  end

end

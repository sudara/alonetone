module AuthlogicHelpers  

  # from Authlogic readme
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user= current_user_session && current_user_session.record
  end
  
  # basic questions asked at controller/view level
  def logged_in?
    !!current_user
  end
  
  def admin?
    logged_in? && current_user.admin?
  end
  
  def moderator?
    logged_in? && (current_user.moderator? || current_user.admin?)
  end
  
  
  
  # for usage in before filters
  def moderator_required
    require_login && moderator?
  end
  
  def require_login
    force_login unless logged_in? and authorized?
  end
    
  def admin_only
    force_admin_login unless admin?
  end
  
  def moderator_only
    force_mod_login unless moderator?
  end
  
  
  
  # force logins at various access levels
  def force_login
    store_location
    redirect_to login_path, :alert => "Whups, you need to login for that!"
  end
  
  def force_mod_login
    store_location
    redirect_to login_path, :alert => "Super special secret area. Alonetone Elite Only."
  end
  
  def force_admin_login
    store_location
    redirect_to login_path, :alert => "What do you think you’re doing?! We're calling your mother..."
  end  
  
end
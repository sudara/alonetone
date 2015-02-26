class ApplicationController < ActionController::Base  
  helper :all # all helpers, all the time

  include AuthlogicHelpers
  include PreventAbuse
  
  protect_from_forgery
    
  before_filter :set_tab, :is_sudo
  before_filter :display_news
  before_filter :set_latest_update_title
  
  # let ActionView have a taste of our authentication
  helper_method :current_user, :current_user_session, :logged_in?, :admin?, :last_active, :current_page, :moderator?, :welcome_back?, :user_setting
  
  # ability to tack these flash types on redirects/renders, access via flash.error
  add_flash_types(:error, :ok)
  
  before_filter :store_location, :only => [:index, :show]
  
  def current_page
    @page ||= params[:page].blank? ? 1 : params[:page].to_i
  end
  
  protected
  
  def not_found
    flash[:error] = "Hmm, we didn't find that alonetoner"
    raise ActionController::RoutingError.new('User Not Found')
  end
  
  def currently_online
    @online = User.currently_online
  end
    
  def find_user
    login = params[:login] || params[:user_id] || params[:id]
    @user = User.where(:login => login).first
    not_found unless @user
  end

  def find_asset
    @asset = Asset.where(:permalink => (params[:permalink] || params[:track_id] || params[:id])).first
    @asset ||= Asset.where(:id => params[:id]).first || track_not_found
  end
  
  def find_playlists
    @playlist = @user.playlists.find(:permalink => (params[:permalink] || params[:id]), :include =>[:tracks => :asset]).first
    @playlist = @user.playlists.find(params[:id], :include =>[:tracks => :asset]) if !@playlist && params[:id] 
  end

  def display_private_comments?
    moderator? or (logged_in? && (current_user.id.to_s == @user.id.to_s))
  end
  
  def store_location
    session[:return_to] = request.url unless request.xhr? or request.format.mp3?
  end
  
  def redirect_back_or_default(default='/')
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def admin_or_owner(record=current_user)
    admin? || (!%w(destroy admin edit update).include?(action_name) && (params[:login].nil? || params[:login] == record.login))
  end
  
  def admin_or_owner_with_delete(record=current_user)
    admin? || (params[:login].nil? || params[:login] == record.login)
  end
  
  def current_user_is_admin_or_owner?(user)
    logged_in? && (current_user.admin? || ((current_user.id.to_s == user.id.to_s)))
  end

  def current_user_is_admin_or_moderator_or_owner?(user)
    current_user_is_admin_or_owner? || moderator?
  end

  def user_setting(symbol_or_string, user=current_user)
    logged_in? && user.settings && user.settings[symbol_or_string.to_sym] 
  end
  
  def set_tab
    @tab = ''
  end
  
  def display_news
    return unless logged_in?
    last_update = Update.order('created_at DESC').first
    @display_news = true if session[:last_active] && last_update && (session[:last_active] < last_update.created_at)
  end

  def is_sudo
    @sudo = session[:sudo]
  end
  
  # don't update last_request_at when sudo is present
  def last_request_update_allowed?
    !session[:sudo]
  end
  
  def set_latest_update_title
    @latest_update = Update.order('created_at DESC').limit(1).first
  end
    
  def welcome_back?
    @welcome_back
  end

  def default_url
    url = user_home_path(current_user) if logged_in? 
    url = login_url if !url
    url
  end

    
  def redirect_to_default
    redirect_to(session[:return_to] || default_url)
    session[:return_to] = nil
  end
    
  def authorized?() 
    logged_in?
  end
end

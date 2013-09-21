class ApplicationController < ActionController::Base  
  helper :all # all helpers, all the time

  include AuthlogicHelpers
  
  @@bad_ip_ranges = ['195.239', '220.181', '61.135', '60.28.232', '121.14', '221.194','117.41.183',
                     '117.41.184','60.169.78','222.186','61.160.232','22.186.24.']

  protect_from_forgery
    
  before_filter :set_tab, :ie6, :is_sudo
  before_filter :ie6
  before_filter :display_news
  before_filter :set_latest_update_title
  
  # let ActionView have a taste of our authentication
  helper_method :current_user, :current_user_session, :logged_in?, :admin?, :last_active, :current_page, :moderator?, :welcome_back?, :user_setting
    
  def current_page
    @page ||= params[:page].blank? ? 1 : params[:page].to_i
  end
  
  protected
      
  def user_not_found
    if @user
      flash[:error] = 'There was a problem with that request...'
    else
      # take them to the search
      flash[:error] = "Hmm, we didn't find that alonetoner, but we did a search for you..."
      redirect_to search_url(:query => params[:login])
    end
  end

  def ie6
    @ie6 = true if request.env['HTTP_USER_AGENT'] and request.env['HTTP_USER_AGENT'].include? "MSIE 6.0" 
  end
  
  def currently_online
    @online = User.currently_online
  end
  
  def find_user
    login = params[:login] || params[:user_id] || params[:id]
    @user = User.find_by_login(login) || current_user 
  end

  def find_asset
    @asset = Asset.find_by_permalink(params[:permalink] || params[:id])
    @asset ||= Asset.find(params[:id]) if params[:id]
  end
  
  def find_playlists
    @playlist = @user.playlists.find_by_permalink(params[:permalink] || params[:id], :include =>[:tracks => :asset])
    @playlist = @user.playlists.find(params[:id], :include =>[:tracks => :asset]) if !@playlist && params[:id] 
  end

  def display_private_comments?
    moderator? or (logged_in? && (current_user.id.to_s == @user.id.to_s))
  end
  
  def store_location
    session[:return_to] = request.url unless request.xhr?
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

  def render_text(text)
   render :text => text
  end

  def user_setting(symbol_or_string, user=current_user)
    logged_in? && user.settings && user.settings[symbol_or_string.to_sym] 
  end
  
  def set_tab
    @tab = ''
  end
  
  def prep_bugaboo
    if logged_in?
      @forum_feedback = Topic.new
    else  
      @user_report = UserReport.new(:user => @current_user || nil, :params => params)
    end
  end

  def display_news
    return unless logged_in?
    last_update = Update.order('created_at DESC').first
    @display_news = true if session[:last_active] && last_update && (session[:last_active] < last_update.created_at)
  end

  def is_sudo
    @sudo = session[:sudo]
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

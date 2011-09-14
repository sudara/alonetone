class ApplicationController < ActionController::Base  
  helper :all # all helpers, all the time

  protect_from_forgery
    
  include AuthenticatedSystem
  before_filter :set_tab, :ie6, :is_sudo
  before_filter :ie6
  before_filter :login_by_token, :display_news
  before_filter :prep_bugaboo
  before_filter :update_last_seen_at, :only => [:index]
  before_filter :set_latest_update_title
  
  # let ActionView have a taste of our authentication
  helper_method :current_user, :logged_in?, :admin?, :last_active, :current_page, :moderator?, :welcome_back?
  
  
  #rescue_from ActiveRecord::RecordNotFound, :with => :show_error
  #rescue_from NoMethodError, :with => :show_error
  rescue_from ActionController::InvalidAuthenticityToken, :with => :show_error
  
  # all errors end up here
  def show_error(exception)
    if RAILS_ENV == 'production'
      # show something decent for visitors
      flash[:error] = "Whups! That didn't work out. We've logged it, but feel free to let us know (bottom right) if something is giving you trouble"
      redirect_to (session[:return_to] || root_path)
    else
      # let me see what's wrong in dev mode.
      raise exception  
    end
  end
  
  
  def current_page
    @page ||= params[:page].blank? ? 1 : params[:page].to_i
  end
  
  protected
  
  def display_private_comments_of?(user)
    admin? || (logged_in? && (current_user.id.to_s == user.id.to_s))
  end
      
  def user_not_found
    if @user
      flash[:error] = 'There was a problem with that request...'
    else
      # take them to the search
      flash[:error] = "Hmm, we didn't find that alonetoner, but we did a search for you..."
      redirect_to search_url(:query => params[:login])
    end
  end

  def sudo_to(destination_user)
    return false unless session[:sudo] || current_user.admin?
    if session[:sudo] && destination_user.admin?
      logger.warn('coming out of sudo to admin account')
      session[:sudo] = nil 
      @sudo = nil
    else 
      session[:sudo] = true
      logger.warn("SUDO: #{current_user.name} is sudoing to #{destination_user.name}")
      @sudo = true
    end
    self.current_user = destination_user
    logger.warn("SUDO: #{current_user.name}")
    true
   end

  def ie6
    @ie6 = true if request.env['HTTP_USER_AGENT'] and request.env['HTTP_USER_AGENT'].include? "MSIE 6.0" 
  end
  
  def currently_online
    @online = User.currently_online
  end
  
  def find_user
    login = params[:login] || params[:id]
    @user = User.find_by_login(login) || current_user 
  end

  def current_user_is_admin_or_owner?(user)
    logged_in? && (current_user.admin? || ((current_user.id.to_s == user.id.to_s)))
  end

  def current_user_is_admin_or_moderator_or_owner?(user)
    current_user_is_admin_or_owner? || moderator?
  end

  def find_asset
    @asset = Asset.find_by_permalink(params[:permalink] || params[:id])
    @asset ||= Asset.find(params[:id]) if params[:id]
  end
  
  def find_playlists
    @playlist = @user.playlists.find_by_permalink(params[:permalink] || params[:id], :include =>[:tracks => :asset])
    @playlist = @user.playlists.find(params[:id], :include =>[:tracks => :asset]) if !@playlist && params[:id] 
  end
  
  def authorized?
    # by default, users can hit every action if it involves their user, and it's not about deleting things.
    admin_or_owner
  end
  
  # authorization tricks
  
  def moderator?
    logged_in? && current_user.moderator?
  end
  
  def moderator_required
    login_required && current_user.moderator?
  end
  
  def admin_required
    login_required && admin?
  end
  
  def admin_or_owner(record=current_user)
    admin? || (!%w(destroy admin edit update).include?(action_name) && (params[:login].nil? || params[:login] == record.login))
  end
  
  def admin_or_owner_with_delete(record=current_user)
    admin? || (params[:login].nil? || params[:login] == record.login)
  end

  def render_text(text)
   render :text => text
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
    last_update = Update.find(:first, :order => 'created_at DESC')
    @display_news = true if session[:last_active] && last_update && (session[:last_active] < last_update.created_at)
  end

  def is_sudo
    @sudo = session[:sudo]
  end
  
  # override default behavior to ensure that 'log in to app' returns user somewhere useful
   # def application_is_not_installed_by_facebook_user
   #   redirect_to session[:facebook_session].install_url(:next => "#{request.request_uri}")
   # end
  
  def set_latest_update_title
    @latest_update = Update.find(:all, :order => 'created_at DESC', :limit => 1 ).first
  end

  private

end
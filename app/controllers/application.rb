class ApplicationController < ActionController::Base  
  helper :all # include all helpers, all the time

  protect_from_forgery  :secret => YAML.load_file(File.join(RAILS_ROOT,'config','alonetone.yml'))['alonetone']['secret']
    
  include AuthenticatedSystem
  include ExceptionLoggable
  before_filter :set_tab, :ie6, :is_sudo
  before_filter :ie6
  before_filter :login_by_token, :display_news
  before_filter :set_page_title
  before_filter :currently_online, :prep_bugaboo
  before_filter :update_last_seen_at, :only => [:index]
  before_filter :set_latest_update_title
  
  # let ActionView have a taste of our authentication
  helper_method :current_user, :logged_in?, :admin?, :last_active
  
  
  rescue_from ActiveRecord::RecordNotFound, :with => :show_error
  rescue_from NoMethodError, :with => :show_error
  
  # all errors end up here
  def show_error(exception)
    if RAILS_ENV == 'production' && admin?
      flash[:error] = "#{exception.message}"
      redirect_to_default
    elsif RAILS_ENV == 'production'
      if facebook?
        flash[:error] = "Alonetone made a boo boo: <br/> #{exception.message}"
        render :partial => 'facebook_accounts/error', :layout => true
      else
        # show something decent for visitors
        flash[:error] = "Whups! That didn't work out. We've logged it, but feel free to let us know (bottom right) if something is giving you trouble"
        redirect_to_default 
      end
    else
      # let me see what's wrong in dev mode.
      raise exception  
    end
  end
  
  
  
  protected
  def facebook?
   !(params[:fb_sig] == nil)
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
    @user = (params[:login] || params[:id])? User.find_by_login(params[:login] || params[:id]) : current_user
  end

  def find_asset
    @asset = @user.assets.find_by_permalink(params[:permalink] || params[:id])
    @asset = @user.assets.find(params[:id]) if !@asset && params[:id]
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
  
  def admin_or_owner(record=current_user)
    admin? || (!%w(destroy admin edit update).include?(action_name) && (params[:login].nil? || params[:login] == record.login))
  end
  
  def admin_or_owner_with_delete(record=current_user)
    admin? || (params[:login].nil? || params[:login] == record.login)
  end
  
  def set_page_title
    @page_title = "alonetone - a damn fine home for musicians. Upload mp3s, host and share your music."
  end
  

  def render_text(text)
   render :text => text
  end

  def set_tab
    @tab = ''
  end
  
  def prep_bugaboo
    @user_report = UserReport.new(:user => @current_user || nil, :params => params)
  end

  def display_news
    return unless logged_in?
    @display_news = true if session[:last_active] && (session[:last_active] < Update.find(:first, :order => 'created_at DESC').created_at)
  end

  def is_sudo
    @sudo = session[:sudo]
  end
  
  # override default behavior to ensure that 'log in to app' returns user somewhere useful
  def application_is_not_installed_by_facebook_user
    redirect_to session[:facebook_session].install_url(:next => "#{request.request_uri}")
  end
  
  def set_latest_update_title
    @latest_update = Update.find(:all, :order => 'created_at DESC', :limit => 1 ).first
  end

  private

end
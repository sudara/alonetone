# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  
  before_filter :find_user, :except => [:new, :create]
  before_filter :require_login, :except => [:index, :show, :new, :create, :activate, :bio, :destroy]
  
  #rescue_from NoMethodError, :with => :user_not_found

  def index
    @page_title = "#{params[:sort] ? params[:sort].titleize+' - ' : ''} Musicians and Listeners"
    @tab = 'browse'

    respond_to do |format|
      format.html do
        @users = User.includes(:pic).paginate_by_params(params)
        @sort = params[:sort]
        @user_count = User.count
        @active     = User.count(:all, :conditions => "assets_count > 0", :include => :pic)
      end
      format.xml do
        @users = User.activated.search(params[:q], :limit => 1000)
        render :xml => @users.to_xml
      end
      format.rss do
        @users = User.activated.geocoded.limit(1000)
      end
      # API 
      format.json do
        cached_json = cache("usersjson-"+User.last.id.to_s) do
          users = User.alpha.musicians.includes(:pic)
          '{ "records" : ' + users.to_json(:methods => [:name, :type, :avatar, :follows_user_ids], :only => [:id,:name,:comments_count,:bio_html,:website,:login,:assets_count,:created_at, :user_id]) + '}'
        end
        render :json => cached_json
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        @page_title = (@user.name)
        @keywords = "#{@user.name}, latest, upload, music, tracks, mp3, mp3s, playlists, download, listen"      
        @description = "Listen to all of #{@user.name}'s music and albums on alonetone. Download #{@user.name}'s mp3s free or stream their music from the page"
        @tab = 'your_stuff' if current_user == @user
               
        @popular_tracks = @user.assets.limit(5).order('assets.listens_count DESC')
        @assets = @user.assets.limit(5)
        @playlists = @user.playlists.public
        @listens = @user.listened_to_tracks.limit(5)
        @track_plays = @user.track_plays.from_user.limit(10)
        @favorites = @user.tracks.favorites.recent.limit(5)
        @comments = @user.comments.public.limit(5) unless display_private_comments?(@user)
        @comments = @user.comments.include_private.limit(5) if display_private_comments?(@user)
        @follows = @user.followees
        @mostly_listens_to = @user.mostly_listens_to
        render
      end
      format.xml { @assets = @user.assets.recent.limit(params[:limit] || 10) }
      format.rss { @assets = @user.assets.recent }
      format.js do  render :update do |page| 
          page.replace 'user_latest', :partial => "latest"
        end
      end
    end
  end
  
  def stats
    @tracks = @user.assets
    respond_to do |format|
      format.html 
      format.xml
    end
  end

  def new
    @user = User.new
    @page_title = "Join alonetone to upload your music in mp3 format"
    flash.now[:error] = "Join alonetone to upload and create playlists (it is quick: about 45 seconds)" if params[:new]
  end
  

  def create
    return false if @@bad_ip_ranges.any?{|cloaked_ip| request.ip.match /^#{cloaked_ip}/  } # check bad ips 
    
    @user = User.new(params[:user])
    if @user.save_without_session_maintenance
      @user.reset_perishable_token!
      UserNotification.signup(@user).deliver
      flash[:ok] = "We just sent you an email to '#{CGI.escapeHTML @user.email}'.<br/><br/>You just have to click the link in the email, and the hard work is over! <br/> Note: check your junk/spam inbox if you don't see a new email right away.".html_safe
      redirect_to login_url
    else
      render :action => :new
    end
  end
  
  
  def activate
    @user = User.where(:perishable_token => params[:perishable_token]).first
    if logged_in? 
      flash[:error] = "You are already activated and logged in! Rejoice and upload!"
      redirect_to new_user_track_path(current_user)
    elsif @user and @user.activate!
      flash[:ok] = "Whew! All done, your account is activated. Go ahead and upload your first track."
      UserSession.create(@user, false) # Log user in manually
      UserNotification.activation(@user).deliver
      redirect_to new_user_track_path(current_user)
    else
      flash[:error] = "Hm. Activation didn't work. Sorry about that!"
      redirect_to new_user_path
    end
  end
  
  def edit
  end
  
  def bio
    @page_title = "#{@user.name}'s Profile"
    @mostly_listens_to = @user.mostly_listens_to
  end
  
  def attach_pic
    @pic = @user.build_pic(params[:pic])
    if @pic.save
      flash[:ok] = 'Pic updated!'
    else
      flash[:error] = 'Pic not updated!'      
    end
    redirect_to edit_user_path(@user)
  end
  
  
  def update
    # fix to not care about password stuff unless both fields are set
    (params[:user][:password] = params[:user][:password_confirmation] = nil) unless params[:user][:password].present? and params[:user][:password_confirmation].present?    
    # If the user changes the :block_guest_comments setting then it requires
    # that the cache for all their tracks be invalidated or else the cached
    # tabs will not change
    flush_asset_caches = false
    if params[:user] && params[:user][:settings] && params[:user][:settings][:block_guest_comments]
      currently_blocking_guest_comments = @user.settings && @user.settings['block_guest_comments'].present? && @user.settings['block_guest_comments'] == 'true'
      flush_asset_caches = params[:user][:settings][:block_guest_comments] == ( currently_blocking_guest_comments ? "false" : "true" )
    end
    
    @user.attributes = params[:user]
    # temp fix to let people with dumb usernames change them
    @user.login = params[:user][:login] if not @user.valid? and @user.errors.on(:login)
    
    successful_save = @user.save
    if successful_save && flush_asset_caches
      # Invalidate asset.cache_key for all this users assets
      Asset.update_all( { :updated_at => Time.now }, { :user_id => @user.id } )
    end
    
    respond_to do |format|
      format.html do 
        if successful_save
          flash[:ok] = "Sweet, updated" 
          redirect_to edit_user_path(@user)
        else
          flash[:error] = "Not so fast, young one"
          render :action => :edit
        end
      end
      format.js do
        successful_save ? (return head(:ok)) : (return head(:bad_request))
      end
    end
  end
  
  def toggle_favorite
    return false unless logged_in? && Asset.find(params[:asset_id]) # no bullshit
    existing_track = current_user.tracks.find(:first, :conditions => {:asset_id => params[:asset_id], :is_favorite => true})
    if existing_track  
      existing_track.destroy && Asset.decrement_counter(:favorites_count, params[:asset_id])
    else
      favs = Playlist.find_or_create_by_user_id_and_is_favorite(:user_id => current_user.id, :is_favorite => true) 
      added_fav = favs.tracks.create(:asset_id => params[:asset_id], :is_favorite => true, :user_id => current_user.id)
      Asset.increment_counter(:favorites_count, params[:asset_id]) if added_fav
    end
    render :nothing => true
  end
  
  def toggle_follow
    current_user.add_or_remove_followee(params[:followee_id])
    render :nothing => true
  end

  def destroy
    if admin_or_owner_with_delete
      flash[:ok] = "The alonetone account #{@user.login} has been permanently deleted."
      @user.destroy # this will run "efficiently_destroy_relations" before_destory callback
      redirect_to logout_path
    else
      redirect_to root_path 
    end
  end
  
  def sudo
    if current_user.admin? && params[:id]
      session[:sudo] = @sudo = current_user.id
      destination = User.where(:login => params[:id]).first
      sudo_to(destination)
      logger.warn("SUDO: #{current_user.name} is sudoing to #{destination.name}")
    elsif !current_user.admin? && session[:sudo]
      logger.warn('coming out of sudo back to admin account')
      sudo_to(User.find(session[:sudo]))
      @sudo = session[:sudo] = nil
    else
      redirect_to root_path
    end
  end

  protected
    def authorized?
      admin? || (!%w(destroy admin).include?(action_name) && logged_in? && (current_user.id.to_s == @user.id.to_s)) || (action_name == 'sudo')
    end
    
    def sudo_to(user)
      current_user_session.destroy
      UserSession.create!(user)
      flash[:ok] = "Sudo to #{user.name}"
      redirect_back_or_default 
    end
    
    def display_user_home_or_index
      if params[:login] && User.find_by_login(params[:login])
        redirect_to user_home_url(params[:user])
      else
        redirect_to users_url
      end
    end
    
end

class UsersController < ApplicationController
  
  skip_before_filter :update_last_seen_at, :only => [:create, :new, :activate, :sudo]
  before_filter :find_user,      :except => [:new, :create]
  
  before_filter :login_required, :except => [:index, :show, :new, :create, :activate, :bio, :destroy]
  skip_before_filter :login_by_token, :only => :sudo
  
  rescue_from NoMethodError, :with => :user_not_found

  def index
    @page_title = "#{params[:sort] ? params[:sort].titleize+' - ' : ''} Musicians and Listeners"
    @tab = 'browse'

    respond_to do |format|
      format.html do
        @users = User.paginate_by_params(params) 
        @sort = params[:sort]
        @user_count = User.count
        @active     = User.count(:all, :conditions => "assets_count > 0", :include => :pic)
      end
      format.xml do
        @users = User.activated.search(params[:q], :limit => 1000)
        render :xml => @users.to_xml
      end
      format.rss do
        @users = User.activated.geocoded.find(:all, :limit => 1000)
      end
      # API 
      format.json do
        cached_json = cache("usersjson-"+User.last.id.to_s) do
          users = User.alpha.musicians.find(:all,:include => :pic)
          '{ "records" : ' + users.to_json(:methods => [:name, :type, :avatar, :follows_user_ids], :only => [:id,:name,:comments_count,:bio_html,:website,:login,:assets_count,:created_at, :user_id]) + '}'
        end
        render :json => cached_json
      end
     # format.fbml do
     #   @users = User.paginate(:all, :per_page => 10, :order => 'listens_count DESC', :page => params[:page])
     # end
    end
  end

  def show
    respond_to do |format|
      format.html do
        @page_title = (@user.name)
        @keywords = "#{@user.name}, latest, upload, music, tracks, mp3, mp3s, playlists, download, listen"      
        @description = "Listen to all of #{@user.name}'s music and albums on alonetone. Download #{@user.name}'s mp3s free or stream their music from the page"
        @tab = 'your_stuff' if current_user == @user
               
        @popular_tracks = @user.assets.find(:all, :limit => 5, :order => 'assets.listens_count DESC')
        @assets = @user.assets.find(:all, :limit => 5)
        @playlists = @user.playlists.public.find(:all)
        @listens = @user.listens.find(:all, :limit =>5)
        @track_plays = @user.track_plays.from_user.find(:all, :limit =>10) 
        @favorites = Track.favorites.find_all_by_user_id(@user.id, :limit => 5)
        @comments = @user.comments.public.find(:all, :limit => 5) unless display_private_comments_of?(@user)
        @comments = @user.comments.include_private.find(:all, :limit => 5) if display_private_comments_of?(@user)
        @follows = @user.followees
        @mostly_listens_to = @user.mostly_listens_to
        render
      end
      format.xml { @assets = @user.assets.find(:all, :order => 'created_at DESC', :limit => (params[:limit] || 10))}
      format.rss { @assets = @user.assets.find(:all, :order => 'created_at DESC')}
      format.fbml do
        @assets = @user.assets.find(:all)
      end
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
  
  # ugliest logic ever. This is one of those areas where you don't want to touch the stuff for fear of breaking things
  # On the other hand, until it's cleaned up, refactoring and bug fixing is next to impossible
  def create
    respond_to do |format|
      format.html do
        @user = params[:user].blank? ? User.find_by_email(params[:email]) : User.new(params[:user])
        if params[:email] and not @user
          flash[:error] = "I could not find an account with the email address '#{CGI.escapeHTML params[:email].first}'. <br/> Did you make a boo-boo or have another email I could diligently try for you?"
          redirect_to login_path and return false
        end
        @user.login = params[:user][:login] unless params[:user].blank?
        @user.reset_token!
        begin
          UserMailer.deliver_signup(@user) if !params[:user].blank?
          UserMailer.deliver_forgot_password(@user) if params[:user].blank?
        rescue Net::SMTPFatalError => e
          flash[:error] = "A permanent error occured while sending the signup message to '#{CGI.escapeHTML @user.email}'. Please check the e-mail address."
          redirect_to :action => "new"
        rescue Net::SMTPServerBusy, Net::SMTPUnknownError, \
          Net::SMTPSyntaxError, TimeoutError => e
          flash[:error] = "The signup message cannot be sent to '#{CGI.escapeHTML @user.email}' at this moment. Please, try again later."
          redirect_to :action => "new"
        end
        flash[:ok] = "We just sent you an email to '#{CGI.escapeHTML @user.email}'.<br/><br/>You just have to click the link in the email, and the hard work is over! <br/> Note: check your junk/spam inbox if you don't see a new email right away."
      end
    end
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Whups, there was a small issue"
      render :action => 'new'
  end
  
  
  def activate
    self.current_user = User.find_by_activation_code(params[:activation_code])
    if current_user != false && !current_user.activated?
      # Did the user already activate, and this is just a forgot password "activation?"
      if current_user.activated_at 
        current_user.activate
        cookies[:auth_token] = { :value => self.current_user.token , :expires => 2.weeks.from_now }
        flash[:ok] = "Sweet, you are back in! <br/>Now quick, update your password below so you don't have to jump through hoops again"
        redirect_to edit_user_path(current_user)
      else
        current_user.activate
        flash[:ok] = "Whew! All done, your account is activated. Go ahead and upload your first track."
        redirect_to new_user_track_path(current_user)
      end
    else 
      flash[:error] = "Hm. Activation didn't work. Maybe your account is already activated?"
      redirect_to default_url
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
    (params[:user][:password] = params[:user][:password_confirmation] = nil) unless present?(params[:user][:password]) and present?(params[:user][:password_confirmation])
    
    # If the user changes the :block_guest_comments setting then it requires
    # that the cache for all their tracks be invalidated or else the cached
    # tabs will not change
    flush_asset_caches = false
    if params[:user] && params[:user][:settings] && params[:user][:settings][:block_guest_comments]
      currently_blocking_guest_comments = @user.settings && @user.settings.present?('block_guest_comments') && @user.settings['block_guest_comments'] == 'true'
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
    redirect_to user_home_path(current_user) and return false unless @user && (current_user.admin? || session[:sudo])
    flash[:ok] = "Sudo to #{@user.name}" if sudo_to(@user)
    redirect_to :back
  end

  protected
    def authorized?
      admin? || (!%w(destroy admin).include?(action_name) && logged_in? && (current_user.id.to_s == @user.id.to_s)) || (action_name == 'sudo')
    end
    
    def display_user_home_or_index
      if params[:login] && User.find_by_login(params[:login])
        redirect_to user_home_url(params[:user])
      else
        redirect_to users_url
      end
    end
    
end

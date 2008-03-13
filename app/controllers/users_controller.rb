class UsersController < ApplicationController
  

  skip_before_filter :update_last_seen_at, :only => [:create, :new, :activate, :sudo]
  before_filter :find_user,      :except => [:new, :create, :sudo]
  
  before_filter :login_required, :except => [:index, :show, :new, :create, :activate, :bio]
  skip_before_filter :login_by_token, :only => :sudo
  
  rescue_from NoMethodError, :with => :display_user_home_or_index


  def index
    @page_title = 'the music makers and music lovers of alonetone'
    @tab = 'browse'
    @users =  User.paginate_by_params(params)
    flash[:info] = "Want to see your pretty face show up here?<br/> Edit <a href='#{edit_user_path(current_user)}'>your profile</a>" unless current_user = :false || current_user.has_pic?
    respond_to do |format|
      format.html do
        @user_count = User.count
        @active     = User.count(:all, :conditions => "assets_count > 0")
      end
      format.xml do
        @users = User.search(params[:q], :limit => 25)
        render :xml => @users.to_xml
      end
      format.js do render :update do |page|
          page.replace 'user-index', :partial => 'users'
        end
      end
     # format.fbml do
     #   @users = User.paginate(:all, :per_page => 10, :order => 'listens_count DESC', :page => params[:page])
     # end
    end
  end

  def show
    respond_to do |format|
      format.html do
        @page_title = @user.name + " on alonetone - latest music & playlists"
        @tab = 'your_stuff' if current_user == @user
        @assets = @user.assets.paginate(:all, :per_page => 5, :page=>params[:page])
        @playlists = @user.playlists.find(:all,:conditions => [ "tracks_count > 0"])
        @listens = @user.listens.find(:all, :limit =>5)
        @track_plays = @user.track_plays.find(:all, :limit =>10) 
        @comments = @user.comments.find_all_by_spam(false, :limit => 10)
      end
      format.xml { @assets = @user.assets.find(:all, :order => 'created_at DESC')}
      format.rss { @assets = @user.assets.find(:all, :order => 'created_at DESC')}
      format.js do  render :update do |page| 
          page.replace 'user_latest', :partial => "latest"
        end
      end
    end
  end

  def new
    @user = User.new
    @page_title = "Sign up with alonetone to upload your mp3s or discover new music"
  end
  
  
  def create
    respond_to do |format|
      format.html do
        @user = params[:user].blank? ? User.find_by_email(params[:email]) : User.new(params[:user])
        flash[:error] = "I could not find an account with the email address '#{CGI.escapeHTML params[:email]}'. Did you type it correctly?" if params[:email] and not @user
        redirect_to login_path and return unless @user
        @user.login = params[:user][:login] unless params[:user].blank?
        @user.reset_token! 
        begin
          UserMailer.deliver_signup(@user)
        rescue Net::SMTPFatalError => e
          flash[:error] = "A permanent error occured while sending the signup message to '#{CGI.escapeHTML @user.email}'. Please check the e-mail address."
          redirect_to :action => "new"
        rescue Net::SMTPServerBusy, Net::SMTPUnknownError, \
          Net::SMTPSyntaxError, TimeoutError => e
          flash[:error] = "The signup message cannot be sent to '#{CGI.escapeHTML @user.email}' at this moment. Please, try again later."
          redirect_to :action => "new"
        end
        flash[:ok] = "An email was sent to '#{CGI.escapeHTML @user.email}'. <br/>You just have to click the link in the email, and the hard work is over! <br/> Note: check your junk/spam inbox if you don't see a new email right away."
        redirect_to login_path
      end
    end
    rescue ActiveRecord::RecordInvalid
      render :action => 'new'
  end
  
  
  def activate
    self.current_user = User.find_by_activation_code(params[:activation_code])
    if current_user != false && !current_user.activated?
      current_user.activate
      flash[:ok] = "Whew! All done, your account is activated. Go ahead and upload your first track."
      redirect_to new_user_track_path(current_user)
    else 
      flash[:error] = "Hm. Activation didn't work. Maybe your account is already activated?"
      redirect_to default_url
    end
  end
  
  def edit

  end
  
  def bio
    @page_title = "#{@user.name}'s detailed biography on alonetone"
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
    @user.attributes = params[:user]
    # temp fix to let people with dumb usernames change them
    # @user.login = params[:user][:login] if not @user.valid? and @user.errors.on(:login)
    respond_to do |format|
      format.html do 
        if @user.save 
          flash[:ok] = "Sweet, your profile is updated" 
        end
        render :action => 'edit'
      end
    end
  end

  def destroy
    return unless admin?
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_path }
      format.xml  { head 200 }
    end
  end
  
  def sudo
    @to_user = User.find_by_login(params[:login] || params[:id])
    redirect_to :back and return false unless (current_user.admin? || session[:sudo]) && @to_user
    flash[:ok] = "Sudo to #{@to_user.name}" if sudo_to(@to_user)
    redirect_to :back
  end

  protected
    def authorized?
      admin? || (!%w(destroy admin sudo).include?(action_name) && logged_in? && (current_user.id.to_s == @user.id.to_s))
    end
    
    def display_user_home_or_index
      if params[:login] && User.find_by_login(params[:login])
        redirect_to user_home_url(params[:user])
      else
        redirect_to users_url
      end
    end
    
end

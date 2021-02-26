class UsersController < ApplicationController
  before_action :find_user, only: %i[show edit update toggle_setting destroy]
  before_action :require_login, except: %i[index show new create activate]

  def index
    @page_title = "#{params[:sort] ? params[:sort].titleize + ' - ' : ''} Musicians and Listeners"
    @tab = 'browse'
    @pagy, @users = pagy(User.with_preloads.paginate_by_params(params), items: 20)
    @sort = params[:sort]
    @user_count = User.count
    @active     = User.where("assets_count > 0").count
  end

  def show
    prepare_meta_tags
    gather_user_goodies
    respond_to :html
  end

  def new
    @user = User.new
    @page_title = "Join alonetone to upload your music in mp3 format"
    flash.now[:error] = "Join alonetone to upload and create playlists (it is quick: about 45 seconds)" if params[:new]
  end

  def create
    @user = User.new(user_params_with_ip)
    if @user.valid?
      if @user.spam? && @user.save_without_session_maintenance
        @user.update_attribute :is_spam, true
        @user.soft_delete
        flash[:error] = "Hrm, robots marked you as spam. If this was done in error, please email support@alonetone.com and magic fairies will fix it right up."
        redirect_to logout_path
      elsif is_a_bot?
        flash[:ok] = "We just sent you an email to '#{CGI.escapeHTML @user.email}'.<br/><br/>Just click the link in the email, and the hard work is over! <br/> Note: check your junk/spam inbox if you don't see a new email right away.".html_safe
        redirect_to login_url(already_joined: true)
      elsif @user.save_without_session_maintenance
        @user.reset_perishable_token!
        UserNotification.signup(@user).deliver_now

        flash[:ok] = "We just sent you an email to '#{CGI.escapeHTML @user.email}'.<br/><br/>Just click the link in the email, and the hard work is over! <br/> Note: check your junk/spam inbox if you don't see a new email right away.".html_safe
        redirect_to login_url(already_joined: true)
      end
    else
      flash[:error] = "Hrm, that didn't quite work, try again?"
      render action: :new
    end
  end

  def activate
    @user = User.where(perishable_token: params[:perishable_token]).first
    if logged_in?
      redirect_to new_user_track_path(current_user), error: "You are already activated and logged in! Rejoice and upload!"
    elsif !is_from_a_bad_ip? && @user && @user.activate!
      UserSession.create(@user, true) # Log user in manually
      UserNotification.activation(@user).deliver_now
      redirect_to new_user_track_path(@user.login), ok: "Whew! All done, your account is activated. Go ahead and upload your first track."
    else
      redirect_to new_user_path, error: "Hm. Activation didn't work. Sorry about that!"
    end
  end

  def edit
    @profile = @user.profile
    @page_title = "Editing #{@user.name}"
  end

  def update
    if @user.update(user_params)
      flush_asset_cache if user_params.include?(:login) || user_params.include?(:avatar_image)
      redirect_to edit_user_path(@user), ok: "Sweet, updated"
    else
      @user.reload if @user.errors.key?(:login)
      flash.now[:error] = "Ruh roh, that didn't work"
      @profile = @user.profile
      render 'edit'
    end
  end

  def toggle_favorite
    asset = Asset.published.find(params[:asset_id])
    return false unless logged_in? && asset # no bullshit

    current_user.toggle_favorite(asset)
    head :ok
  end

  def toggle_setting
    if Settings::AVAILABLE.include? "#{params[:setting]}?".to_sym
     result = @user.settings.toggle!(params[:setting])
    end
    result ? head(:ok) : head(:bad_request)
  end

  def destroy
    redirect_to(root_path) && (return false) if params[:user_id] || !params[:login] # bug of doom
    if admin_or_owner_with_delete
      flash[:ok] = "The alonetone account #{@user.login} has been permanently deleted."

      UserCommand.new(@user).soft_delete_with_relations

      if moderator?
        redirect_to root_path
      else
        redirect_to logout_path
      end
    else
      redirect_to root_path
    end
  end

  def sudo
    if admin?
      sudo_to_user
    else
      return_from_sudo_if_sudoed
    end
  end

  private

  # This overrides application controller's version of find_user
  # which is too flexible, full of edge cases and deprecated.
  def find_user
    @user = User.find_by_login(params[:id])
    not_found unless @user
  end

  def user_params
    params.require(:user).permit(:login, :name, :email, :password, :password_confirmation,
      :display_name, :avatar_image, settings: {}, profile_attributes:
      [:id, :bio, :city, :country, :website, :instagram, :spotify, :apple, :youtube])
  end

  def user_params_with_ip
    user_params.merge(current_login_ip: request.remote_ip)
  end

  def prepare_meta_tags
    @page_title = "#{@user.name}'s Music"
    @keywords = "#{@user.name}, latest, upload, music, tracks, mp3, mp3s, playlists, download, listen"
    @description = "Listen to all of #{@user.name}'s music and albums on alonetone. Download #{@user.name}'s mp3s free or stream their music from the page"
    @tab = 'your_stuff' if current_user == @user
  end

  def gather_user_goodies
    @profile = @user.profile
    @popular_tracks = @user.assets.with_preloads.limit(5).reorder(listens_count: :desc)
    @assets = @user.assets.with_preloads.limit(5)
    @playlists = @user.playlists.with_preloads.include_private
    @listens = @user.listened_to_tracks.preload(:user).group(:asset_id).limit(5)
    @track_plays = @user.track_plays.from_user.limit(10)
    @favorites = @user.tracks.with_preloads.favorites.recent.limit(5).collect(&:asset)
    @comments = @user.comments_received.with_preloads.public_or_private(display_private_comments?).limit(5)
    @other_users_with_same_ip = User.with_same_ip_as(@user).pluck(:login) if @user.current_login_ip.present?
    unless current_user_is_admin_or_owner?(@user)
      @popular_tracks = @popular_tracks.published
      @assets = @assets.published
      @listens = @listens.published
      @playlists = @playlists.only_public
    end
  end

  def authorized?
    !dangerous_action? || current_user_is_admin_or_owner?(@user) || @sudo.present? && (action_name == 'sudo')
  end

  def dangerous_action?
    %w[destroy update edit create].include? action_name
  end

  def change_user_to(user)
    current_user_session.destroy
    user.reset_persistence_token! unless user.persistence_token.present?
    session = UserSession.create(user)
    flash[:ok] = "Changed user to #{user.name}"
    redirect_back_or_default
  end

  def sudo_to_user
    raise "No user specified" unless params[:id]

    new_user = User.where(login: params[:id]).first
    if new_user.present?
      logger.warn("SUDO: #{current_user.name} is sudoing to #{new_user.name}")
      @sudo = session[:sudo] = current_user.id
      change_user_to new_user
    else
      flash[:warn] = "Well, that user doesn't exist, broseph"
    end
  end

  def return_from_sudo_if_sudoed
    redirect_to(root_path) && (return false) unless session[:sudo].present?
    logger.warn("SUDO: returning to admin account")
    change_user_to User.find(session[:sudo])
    @sudo = session[:sudo] = nil
  end

  def display_user_home_or_index
    if params[:login] && User.find_by_login(params[:login])
      redirect_to user_home_url(params[:user])
    else
      redirect_to users_url
    end
  end

  def flush_asset_cache
    Asset.where(user_id: @user.id).touch_all
  end
end

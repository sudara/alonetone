class UsersController < ApplicationController
  before_action :ip_is_acceptable?, only: :create
  before_action :find_user, except: %i[new create index activate sudo toggle_favorite]
  before_action :require_login, except: %i[index show new create activate bio destroy]

  def index
    @page_title = "#{params[:sort] ? params[:sort].titleize + ' - ' : ''} Musicians and Listeners"
    @tab = 'browse'
    @users = User.includes(:pic).paginate_by_params(params)
    @sort = params[:sort]
    @user_count = User.count
    @active     = User.where("assets_count > 0").count
  end

  def show
    respond_to do |format|
      format.html do
        prepare_meta_tags
        gather_user_goodies
        render 'show_white' if white_theme_enabled?
      end
      format.xml { @assets = @user.assets.published.recent.limit(params[:limit] || 10) }
      format.rss { @assets = @user.assets.published.recent }
      format.js do
        render :update do |page|
          page.replace 'user_latest', partial: "latest"
        end
      end
    end
  end

  def stats
    @tracks = @user.assets.published
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
    passed_recaptcha?
    @user = User.new(user_params)
    if @user.valid? && passed_recaptcha? && @user.save_without_session_maintenance
      session[:recaptcha] = false # make sure they have to recaptcha for new user
      @user.reset_perishable_token!
      UserNotification.signup(@user).deliver_now
      flash[:ok] = "We just sent you an email to '#{CGI.escapeHTML @user.email}'.<br/><br/>Just click the link in the email, and the hard work is over! <br/> Note: check your junk/spam inbox if you don't see a new email right away.".html_safe
      redirect_to login_url(already_joined: true)
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

  def edit; end

  def attach_pic
    if params[:pic].present?
      @pic = @user.build_pic(params[:pic].permit(:pic))
      flash[:ok] = 'Picture updated!' if @pic.save
    end
    flash[:error] = 'Whups, picture not updated! Try again.' unless flash[:ok].present?
    redirect_to edit_user_path(@user)
  end

  def update
    if @user.update_attributes(user_params)
      flush_asset_cache_if_necessary
      redirect_to edit_user_path(@user), ok: "Sweet, updated"
    else
      flash[:error] = "Not so fast, young one"
      render action: :edit
    end
  end

  def toggle_favorite
    asset = Asset.published.find(params[:asset_id])
    return false unless logged_in? && asset # no bullshit
    current_user.toggle_favorite(asset)
    head :ok
  end

  def destroy
    redirect_to(root_path) && (return false) if params[:user_id] || !params[:login] # bug of doom
    if admin_or_owner_with_delete
      flash[:ok] = "The alonetone account #{@user.login} has been permanently deleted."
      @user.destroy # this will run "efficiently_destroy_relations" before_destory callback
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

  def user_params
    params.require(:user).permit(:login, :name, :email, :password, :password_confirmation,
      :website, :myspace, :bio, :display_name, :itunes, :city, :country, :twitter,
      settings: %i[display_listen_count block_guest_comments most_popular
        increase_ego email_comments email_new_tracks])
  end

  def ip_is_acceptable?
    !is_from_a_bad_ip?
  end

  def passed_recaptcha?
    if (session[:recaptcha] == true) || !RECAPTCHA_ENABLED
      @bypass_recaptcha = true # bypass when already entered or setting not present
    else
      @bypass_recaptcha = session[:recaptcha] = verify_recaptcha(model: @user)
    end
  end

  def prepare_meta_tags
    @page_title = @user.name
    @keywords = "#{@user.name}, latest, upload, music, tracks, mp3, mp3s, playlists, download, listen"
    @description = "Listen to all of #{@user.name}'s music and albums on alonetone. Download #{@user.name}'s mp3s free or stream their music from the page"
    @tab = 'your_stuff' if current_user == @user
  end

  def gather_user_goodies
    @popular_tracks = @user.assets.includes(user: :pic).limit(5).reorder('assets.listens_count DESC')
    @assets = @user.assets.includes(user: :pic).limit(5)
    @playlists = @user.playlists.only_public.includes(:user, :pic)
    @listens = @user.listened_to_tracks.preload(:user).limit(5)
    @track_plays = @user.track_plays.from_user.limit(10)
    @favorites = @user.tracks.favorites.recent.includes(asset: { user: :pic }).limit(5).collect(&:asset)
    @comments = @user.comments.public_or_private(display_private_comments?)
                     .preload(commentable: { user: :pic }).preload(commenter: :pic).limit(5)
    @other_users_with_same_ip = @user.current_login_ip.present? ? User.where(last_login_ip: @user.current_login_ip).pluck('login') : nil
    unless current_user_is_admin_or_owner?(@user)
      @popular_tracks = @popular_tracks.published
      @assets = @assets.published
      @listens = @listens.published
    end
  end

  def authorized?
    !dangerous_action? || current_user_is_admin_or_owner?(@user) || @sudo.present? && (action_name == 'sudo')
  end

  def dangerous_action?
    %w[destroy update edit create attach_pic].include? action_name
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

  def flush_asset_cache_if_necessary
    # If the user changes the :block_guest_comments setting then it requires
    # that the cache for all their tracks be invalidated
    flush_asset_caches = false
    if params[:user][:settings].present? && params[:user][:settings][:block_guest_comments]
      currently_blocking_guest_comments = @user.has_setting?('block_guest_comments', 'true')
      flush_asset_caches = params[:user][:settings][:block_guest_comments] == (currently_blocking_guest_comments ? "false" : "true")
    end
    Asset.where(user_id: @user.id).update_all(updated_at: Time.now) if flush_asset_caches
  end

  def display_user_home_or_index
    if params[:login] && User.find_by_login(params[:login])
      redirect_to user_home_url(params[:user])
    else
      redirect_to users_url
    end
  end
end

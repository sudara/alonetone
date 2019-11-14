class ApplicationController < ActionController::Base

  # Sets ActiveStorage::Current.host based on the current request so all Active
  # Storage models can generate URLs out of the view context. This is mostly
  # used in development because in production we use CloudFront URLs.
  include ActiveStorage::SetCurrent
  include Authentication
  include Pagy::Backend
  include PreventAbuse

  protect_from_forgery

  before_action :is_sudo
  before_action :set_theme

  rescue_from ActionController::RoutingError, with: :show_404
  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from AbstractController::ActionNotFound, with: :show_404

  before_bugsnag_notify :add_user_info_to_bugsnag

  helper_method :current_user, :current_user_session, :logged_in?, :admin?, :last_active,
    :current_user_is_mod_or_owner?, :current_user?,
    :current_page, :moderator?, :welcome_back?, :user_setting, :latest_forum_topics

  # ability to tack these flash types on redirects/renders, access via flash.error
  add_flash_types(:error, :ok)

  before_action :store_location, only: %i[index show]

  def current_page
    @page ||= params[:page].blank? ? 1 : params[:page].to_i
  end

  protected

  def lazily_create_waveform_if_needed
    return if is_a_bot?
    return if @asset.audio_feature

    # perform_later will queue the job as soon as worker is available
    CreateAudioFeatureJob.perform_later @asset.id
  end

  def show_404
    render 'pages/four_oh_four', status: 404
  end

  def set_theme
    if logged_in?
      session[:white] = !current_user.use_old_theme?
    elsif session[:white].nil?
      session[:white] = true
    else
      session[:white]
    end
  end

  def not_found
    flash[:error] = "Hmm, we didn't find that..."
    raise ActionController::RoutingError, 'User Not Found'
  end

  def find_user
    login = params[:login] || params[:user_id] || params[:id]
    @user = User.where(login: login).first || (current_user if %w[new favorites].include? action_name)
    not_found unless @user
  end

  def find_asset
    @asset = @user.assets.where(permalink: (params[:permalink] || params[:track_id] || params[:id])).first
    @asset ||= @user.assets.where(id: params[:id]).first || track_not_found
  end

  def find_published_asset
    find_asset
    track_not_found unless @asset.published? || current_user_is_admin_or_owner?(@asset.user)
  end

  def find_playlists
    @playlist = @user.playlists.find(permalink: (params[:permalink] || params[:id]), include: [tracks: :asset]).first
    @playlist = @user.playlists.find(params[:id], include: [tracks: :asset]) if !@playlist && params[:id]
  end

  def display_private_comments?
    moderator? || (logged_in? && (current_user.id.to_s == @user.id.to_s))
  end

  def store_location
    session[:return_to] = request.url unless request.xhr? || request.format.mp3?
  end

  def redirect_back_or_default(default = '/')
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def admin_or_owner(record = current_user)
    admin? || (!%w[destroy admin edit update].include?(action_name) && (params[:login].nil? || params[:login] == record.login))
  end

  def admin_or_owner_with_delete(record = current_user)
    admin? || (params[:login].nil? || params[:login] == record.login)
  end

  def current_user?(user)
    current_user.id.to_s == user.id.to_s
  end

  def current_user_is_admin_or_owner?(user)
    logged_in? && (current_user.admin? || current_user?(user))
  end

  def current_user_is_mod_or_owner?(user)
    current_user_is_admin_or_owner?(user) || moderator?
  end

  def user_setting(symbol_or_string, user = current_user)
    logged_in? && user.settings && user.settings[symbol_or_string.to_sym]
  end

  def is_sudo
    @sudo = session[:sudo]
  end

  # don't update last_request_at when sudo is present
  def last_request_update_allowed?
    !session[:sudo]
  end

  def welcome_back?
    @welcome_back
  end

  def default_url
    path = user_home_path(current_user) if logged_in?
    path ||= login_path
    path
  end

  def redirect_to_default
    redirect_to(session[:return_to] || default_url)
    session[:return_to] = nil
  end

  def authorized?
    logged_in?
  end

  def latest_forum_topics
    Thredded::Topic.all.order_recently_posted_first.joins(:last_user).includes(:last_user).moderation_state_visible_to_user(current_user || Thredded::NullUser.new).limit(4)
  end

  def add_user_info_to_bugsnag(report)
    report.user = {
      email: current_user.email,
      name: current_user.display_name,
      id: current_user.id
    }
  end

end

class AssetsController < ApplicationController
  include Listens

  before_action :find_user, except: %i[radio latest new]
  before_action :find_asset, only: %i[edit update destroy stats spam unspam]
  before_action :find_published_asset, only: %i[show stats]

  # we check to see if the current_user is authorized based on the asset.user
  before_action :require_login, except: %i[index show latest radio listen_feed]
  before_action :check_new_user_abuse, only: %i[new create]

  # home page
  def latest
    if stale?(Asset.last_updated)
      @page_title = @description = "Latest Music"
      @tab = 'home'
      @assets = Asset.with_preloads.published.latest.limit(5)
      set_related_lastest_variables
      respond_to :html
    end
  end

  def set_related_user_variables
    all_user_tracks = @user.assets
    @hot_tracks_this_week = all_user_tracks.hottest.limit(5)
    @most_fav_tracks = all_user_tracks.favorited.limit(5)
    @most_commented_tracks = all_user_tracks.most_commented.limit(5)
    @most_listened_to_tracks = all_user_tracks.most_listened.limit(5)
  end

  # user's home page
  def index
    @page_title = "#{@user.name}'s Music"
    set_related_user_variables
    if current_user_is_admin_or_owner?(@user)
      @assets = @user.assets
    else
      @assets = @user.assets.published
    end
    @pagy, @assets = pagy(@assets.recent)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render xml: @assets.to_xml }
      format.rss  { render xml: @assets.to_xml }
      format.js do
        render :update do |page|
          page.replace 'stash', partial: "assets"
        end
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        check_for_missing_attachment
        lazily_create_waveform_if_needed
        @assets = [@asset]
        set_related_show_variables
      end
      format.mp3 do
        listen(@asset)
      end
    end
  end

  def radio
    params[:source] = (params[:source] || cookies[:radio] || 'latest')
    @channel = params[:source].humanize
    if !logged_in? && %w(those_you_follow songs_you_have_not_heard mangoz_shuffle).include?(params[:source])
      flash[:error] = "Sorry. Page you've been looking for is not found."
      raise ActionController::RoutingError, 'Page Not Found'
    end
    @page_title = "#{@channel} radio"
    @pagy, @assets = pagy(Asset.radio(params[:source], current_user), items: params[:items])
  end

  def top
    top = params[:top] && params[:top].to_i < 50 ? params[:top] : 40
    @page_title = "Top #{top} tracks"
    @assets = Asset.published.limit(top).order('hotness DESC')
    respond_to do |wants|
      wants.html
      wants.rss
    end
  end

  def search
    @assets = Asset.published.where("assets.filename LIKE ? OR assets.title LIKE ?",
                                 "%#{params[:search]}%", "%#{params[:search]}%")
                   .limit(10)
    render partial: 'results', layout: false
  end

  def new
    redirect_to signup_path unless logged_in?
    @user = current_user
    @tab = 'upload' if current_user == @user
    @asset = Asset.new
    @page_title = "Upload New Track"
  end

  def edit
    check_for_missing_attachment
    @single_track_page = true
  end

  def mass_edit
    @assets = [@user.assets.where(id: params[:assets])].flatten if params[:assets] # expects comma seperated list of ids
    @assets = @user.assets unless @assets.present?
  end

  def create
    @assets = assets
    @playlists = playlists

    flashes = ""
    at_least_one_upload = false

    @assets.each do |asset|
      if !asset.new_record?
        flashes += "#{CGI.escapeHTML asset.mp3_file_name} uploaded successfully!<br/>"
        asset.update_attribute(:is_spam, asset.spam?) # makes an api call
        at_least_one_upload = true
      else
        errors = asset.errors.full_messages.join('.')
        flashes += "'#{CGI.escapeHTML asset.mp3_file_name}' failed to upload. Please double check that it's an Mp3.<br/>"
      end
    end

    if @playlist
      flash[:ok] = (flashes + "<br/>You had ID3 tags in place so we created an album for you").html_safe
      redirect_to edit_user_playlist_path(@user, @playlist)
    elsif @assets.present? && at_least_one_upload
      @user.followers.includes(:settings).where('settings.email_new_tracks = ?', true).pluck(:id).each do |follower_id|
        AssetNotificationJob.set(wait: 10.minutes).perform_later(asset_ids: @assets.map(&:id), user_id: follower_id)
      end
      if @assets.count == 1
        redirect_to edit_user_track_path(current_user, @assets.first)
      else
        flash[:ok] = (flashes + "<br/>Check the title and add a description for your tracks").html_safe
        redirect_to mass_edit_user_tracks_path(current_user, assets: @assets.collect(&:id))
      end
    else
      flash[:error] = "Oh noes! Either that file was not an mp3 or you didn't actually pick a file to upload."
      redirect_to new_user_track_path(current_user)
     end
  end

  def update
    result = @asset.update(asset_params)
    # Spam detection temporarily disabled as of Dec 2019
    # @asset.update_attribute(:is_spam, @asset.spam?)
    @asset.publish! if params[:commit] == 'Publish'

    if request.xhr?
      result ? head(:ok) : head(:bad_request)
    else
      if result
        redirect_to user_track_url(@asset.user.login, @asset.permalink)
      else
        flash[:error] = "There was an issue with updating that track"
        render :edit
      end
    end
  end

  def destroy
    AssetCommand.new(@asset).soft_delete_with_relations

    flash[:ok] = "We threw the puppy away. No one can listen to it again " \
                 "(unless you reupload it, of course ;)"

    respond_to do |format|
      format.html { redirect_to user_tracks_url(current_user) }
      format.xml  { head :ok }
    end
  end

  def stats
    respond_to do |format|
      format.xml
    end
  end

  def listen_feed
    @tracks = @user.new_tracks_from_followees(15)
    respond_to do |format|
      format.rss
    end
  end

  protected

  def asset_params
    params.require(:asset).permit(
      :audio_file,
      :credits,
      :description,
      :name,
      :title,
      :user,
      :user_id,
      :youtube_embed,
      :post
    )
  end

  def check_for_missing_attachment
    unless @asset.audio_file.attached?
      flash.now[:error] = "Uh oh, there's no longer an mp3 attached to this track.<br/>
        Please edit it and click 'upload a new version' to add the mp3"
    end
  end

  def track_not_found
    raise ActionController::RoutingError, 'Track Not Found'
  end

  def user_has_tracks_from_followees?
    logged_in? && current_user.has_followees?
  end

  def uploaded_files
    params.fetch(:asset_data, []).reject do |item|
      item.try(:starts_with?, 'http')
    end
  end

  def selected_urls
    params.fetch(:asset_data, []).select do |item|
      item.try(:starts_with?, 'http')
    end
  end

  DONT_PUBLISH_RE = /don't publish/

  def dont_publish_param?
    DONT_PUBLISH_RE.match?(params[:commit].to_s)
  end

  def asset_attributes
    {
      private: dont_publish_param?,
      user_agent: request.user_agent
    }
  end

  def playlist_attributes
    {
      published: !dont_publish_param?
    }
  end

  def upload
    @upload ||= Upload.process(
      user: current_user,
      files: uploaded_files,
      asset_attributes: asset_attributes,
      playlist_attributes: playlist_attributes
    )
  end

  def downloads
    @downloads ||= selected_urls.map do |url|
      Download.process(
        user: current_user,
        url: url,
        asset_attributes: asset_attributes,
        playlist_attributes: playlist_attributes
      )
    end
  end

  def assets
    upload.assets +
      downloads.inject([]) { |accumulator, download| accumulator + download.assets }
  end

  def playlists
    upload.assets +
      downloads.inject([]) { |accumulator, download| accumulator + download.playlists }
  end

  def set_related_lastest_variables
    @favorites = Track.favorites_for_home
    @popular = Asset.with_preloads.published.order('hotness DESC').limit(5)
    @playlists = Playlist.for_home.limit(4)
    @comments = admin? ? Comment.last_5_private : Comment.to_other_members.last_5_public
    @followee_tracks = current_user.new_tracks_from_followees(5) if user_has_tracks_from_followees?
  end

  def set_related_show_variables
    @listens = @asset.listens
    @comments = @asset.comments.with_preloads.public_or_private(display_private_comments?)
    @listeners = @asset.listeners.first(6)
    @favoriters = @asset.favoriters
    @page_title = "#{@asset.name} by #{@user.name}"
    @description = @page_title + " - #{@asset[:description]}"
    @single_track = true
  end

  def authorized?
    # admin or the owner of the asset can edit/update/delete
    !dangerous_action? || current_user_is_mod_or_owner?(@user) ||
      (@asset && current_user_is_mod_or_owner?(@asset.user))
  end

  def dangerous_action?
    %w[destroy update edit create spam unspam].include? action_name
  end

  def new_user_potentially_abusive?
    current_user.brand_new? && current_user.assets_count >= 25
  end

  def check_new_user_abuse
    return unless new_user_potentially_abusive?

    @upload_disabled = true

    case action_name
    when "new"
      flash.now[:error] = "To prevent abuse, new users are limited to 25 " \
                          "uploads in their first day. Come back tomorrow!"
    when "create"
      flash[:error] = "To prevent abuse, new users are limited to 25 " \
                          "uploads in their first day. Come back tomorrow!"
      redirect_to new_user_track_path(current_user)
    end
  end
end

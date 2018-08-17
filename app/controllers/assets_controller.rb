class AssetsController < ApplicationController
  include Listens

  before_action :find_user, except: %i[radio latest new]
  before_action :find_asset, only: %i[edit update destroy stats spam unspam]
  before_action :find_published_asset, only: %i[show stats]

  # we check to see if the current_user is authorized based on the asset.user
  before_action :require_login, except: %i[index show latest radio listen_feed]

  # home page
  def latest
    if stale?(Asset.last_updated)
      respond_to do |wants|
        wants.html do
          @page_title = @description = "Latest #{@limit} uploaded mp3s" if params[:latest]
          @tab = 'home'
          @assets = Asset.published.latest.includes(user: :pic).limit(5)
          set_related_lastest_variables
          render 'latest_white' if white_theme_enabled?
        end
        wants.rss do
          @assets = Asset.published.latest(50)
        end
        wants.json do
          @assets = Asset.published.limit(500).includes(:user)
          render json: @assets.to_json(only: %i[name title id], methods: [:name], include: { user: { only: :name, method: :name } })
        end
      end
    end
  end

  # index serves assets for a specific user
  def index
    @page_title = "All music by " + @user.name

    @assets = if current_user_is_admin_or_owner?(@user)
                @user.assets
              else
                @user.assets.published
              end
    @assets = @assets.recent.paginate(per_page: 200, page: params[:page])

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render xml: @assets.to_xml }
      format.rss  { render xml: @assets.to_xml }
      format.js do
        render :update do |page|
          page.replace 'stash', partial: "assets"
        end
      end
      format.json do
        cached_json = cache("tracksby/#{@user.login}") do
          '{ "records" : ' + @assets.to_json(methods: %i[name type length seconds], only: %i[id name listens_count description permalink hotness user_id created_at]) + '}'
        end
        render json: cached_json
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        @assets = [@asset]
        set_related_show_variables
        render 'show_white' if white_theme_enabled?
      end
      format.mp3 do
        listen(@asset)
      end
    end
  end

  def radio
    params[:source] = (params[:source] || cookies[:radio] || 'latest')
    @channel = params[:source].humanize
    @page_title = "alonetone Radio: #{@channel}"
    @assets = Asset.radio(params[:source], params, current_user)
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
  end

  def edit
    @descriptionless = @user.assets.descriptionless
    @allow_reupload = true
    render 'edit_white' if white_theme_enabled?
  end

  def mass_edit
    redirect_to_default && (return false) unless logged_in? && (current_user.id == @user.id) || admin?
    @descriptionless = @user.assets.descriptionless
    @assets = [@user.assets.where(id: params[:assets])].flatten if params[:assets] # expects comma seperated list of ids
    @assets = @user.assets unless @assets.present?
    render 'mass_edit_white' if white_theme_enabled?
  end

  def mass_update; end

  def create
    extract_assets_from_params

    flashes = ""
    good = false

    @assets.each do |asset|
      if !asset.new_record?
        flashes += "#{CGI.escapeHTML asset.mp3_file_name} uploaded!<br/>"
        good = true
      else
        errors = asset.errors.full_messages.join('.')
        flashes += "'#{CGI.escapeHTML asset.mp3_file_name}' failed to upload. Please double check that it's an Mp3.<br/>"
      end
    end

    if good
      flash[:ok] = (flashes + "<br/>Check the title and add description for your track(s)").html_safe
      redirect_to mass_edit_user_tracks_path(current_user, assets: @assets.collect(&:id))
    else
      flash[:error] = if @assets.present?
                        flashes.html_safe
                      else
                        "Oh noes! Either that file was not an mp3 or you didn't actually pick a file to upload."
                       end
      redirect_to new_user_track_path(current_user)
    end
  end

  # PUT /assets/1
  # PUT /assets/1.xml
  def update
    result =  @asset.update_attributes(asset_params)
    is_spam = @asset.spam? # && @user.created_at > 7.days.ago # makes an api call
    @asset.update_attribute(:private, true) if is_spam
    @asset.publish! if params[:commit] == 'Publish'

    if request.xhr?
      result ? head(:ok) : head(:bad_request)
    else
      if result
        redirect_to user_track_url(@asset.user.login, @asset.permalink)
      else
        flash[:error] = "There was an issue with updating that track"
        render action: "edit"
      end
    end
  end

  def destroy
    @asset.destroy
    flash[:ok] = "We threw the puppy away. No one can listen to it again " \
                 "(unless you reupload it, of course ;)"

    respond_to do |format|
      format.html { redirect_to user_tracks_url(current_user) }
      format.xml  { head :ok }
    end
  end

  def unspam
    @asset.ham!
    @asset.update_column :private, false
    flash.notice = "Track was made public"
    redirect_back(fallback_location: root_path)
  end

  def spam
    @asset.spam!
    @asset.update_column :private, true
    flash.notice = "Track was marked as spam and is private"
    redirect_back(fallback_location: root_path)
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
    params.require(:asset).permit(:user, :mp3, :size, :name, :user_id,
                                  :title, :description, :youtube_embed, :credits)
  end

  def track_not_found
    flash[:error] = "Hmm, we didn't find that track!"
    raise ActionController::RoutingError, 'Track Not Found'
  end

  def user_has_tracks_from_followees?
    logged_in? && current_user.has_followees?
  end

  def extract_assets_from_params
    @assets = []
    attrs = { private: !!(params[:commit] =~ /don't publish/) }
    Array(params[:asset_data]).each do |file|
      if file.is_a?(String) && file.starts_with?("http")
        if url_is_a_zip?(file)
          open Asset.parse_external_url(file) do |tempfile|
            create_mp3s_from_zip(tempfile, attrs)
          end
        else
          @assets << current_user.assets.create(attrs.merge(mp3: Asset.parse_external_url(file)))
        end
      elsif file.is_a?(String)
        # twiddle thumbs
      elsif file_is_a_zip?(file)
        create_mp3s_from_zip(file, attrs)
      else
        @assets << current_user.assets.create(attrs.merge(mp3: file))
      end
    end
  end

  def url_is_a_zip?(url)
    File.basename(URI.parse(url).path).split('.')[1] == "zip"
  end

  def file_is_a_zip?(file)
    Paperclip::ContentTypeDetector.new(file.path).detect == 'application/zip'
  end

  def create_mp3s_from_zip(file, attrs)
    Asset.extract_mp3s(file) do |asset|
      @assets << current_user.assets.create(attrs.merge(mp3: asset))
    end
  end

  def set_related_lastest_variables
    @favorites = Track.favorites_for_home
    @popular = Asset.published.order('hotness DESC').includes(user: :pic).limit(5)
    @playlists = white_theme_enabled? ? Playlist.for_home.limit(4) : Playlist.for_home.limit(5)
    @comments = admin? ? Comment.last_5_private : Comment.last_5_public
    @followee_tracks = current_user.new_tracks_from_followees(5) if user_has_tracks_from_followees?
  end

  def set_related_show_variables
    @listens = @asset.listens
    @comments = @asset.comments.only_public
    @listeners = @asset.listeners.first(6)
    @favoriters = @asset.favoriters
    @page_title = "#{@asset.name} by #{@user.name}"
    @description = @page_title + " - #{@asset[:description]}"
    @single_track = true
  end

  def authorized?
    # admin or the owner of the asset can edit/update/delete
    !dangerous_action? || current_user_is_admin_or_moderator_or_owner?(@user) ||
      (@asset && current_user_is_admin_or_moderator_or_owner?(@asset.user))
  end

  def dangerous_action?
    %w[destroy update edit create spam unspam].include? action_name
  end
end

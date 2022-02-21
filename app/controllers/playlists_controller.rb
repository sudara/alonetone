class PlaylistsController < ApplicationController
  include Listens

  before_action :find_user, except: :all
  before_action :find_playlists, except: %i[index new create all sort]
  before_action :require_login, except: %i[index show all]
  before_action :find_tracks, only: %i[show edit all]

  def all
    @playlist_pagy, @playlists = pagy(Playlist.recently_published.only_public.with_preloads, items: 30)
  end

  # all user's playlists
  def index
    @page_title = @description = "#{@user.name}'s albums and playlists"
    set_playlists
  end

  def sort
    respond_to do |format|
      format.js do
        params[:playlist].each_with_index do |id, position|
          @user.playlists.find(id).update_column(:position, position + 1)
        end
        head :ok
      end
    end
  end

  def favorites
    @playlist = @user.favorites
    redirect_to user_playlist_path(@user, @playlist)
  end

  def show
    find_track_and_asset_in_playlist
    @comments = @asset.comments.public_or_private(display_private_comments?) if @asset
    respond_to do |format|
      format.html do
        lazily_create_waveform_if_needed if @asset
        @page_title = @description = "#{@playlist.title} by #{@user.name}"
        render partial: '/shared/asset' if turbo_frame_request? && @asset
      end
      format.mp3 do
        listen(@asset, register: true)
      end
      format.xml
    end
  end

  def new
    @playlist = @user.playlists.build
  end

  def edit
    set_assets
    @listens_pagy, @listens = pagy(@user.listened_to_tracks.preload(:user).distinct, page_param: :listens_page, items: 10)
    @favorites_pagy, @favorites = pagy(@user.favorites.tracks, page_param: :favorites_page, items: 10) if @user.favorites.present?
    @page_title = "Editing \"#{@playlist.title}\" by #{@user.name}"
    if request.xhr?
      render_desired_partial
    else
      render 'edit'
    end
  end

  def add_track
    id = params[:asset_id].split("_")[1]
    asset = Asset.find(id)
    @track = @playlist.tracks.create(asset: asset, user: @user)
    respond_to do |format|
      format.js do
        render plain: @track.id
      end
    end
  end

  def attach_pic
    cover_image = params.dig(:pic, :pic)
    if cover_image && @playlist.update(cover_image: cover_image)
      flash[:notice] = 'Picture updated!'
    else
      flash[:error] = 'Whups, picture not updated! Try again.'
    end
    redirect_to edit_user_playlist_path(@user, @playlist)
  end

  def remove_track
    @track = @playlist.tracks.find(params[:track_id])
    if @track&.destroy
      respond_to do |format|
        format.js { head(:ok) }
      end
    else
      head :ok
    end
  rescue ActiveRecord::RecordNotFound
    head(:bad_request)
  end

  def sort_tracks
    # get the params for this playlist
    params["track"].each_with_index do |id, position|
      @playlist.tracks.find(id).update_column(:position, position + 1)
    end
    head :ok
  rescue ActiveRecord::RecordNotFound, NoMethodError
    head(:bad_request)
  end

  def create
    @playlist = @user.playlists.build(playlist_params)
    if @playlist.save
      flash[:notice] = 'Great, go ahead and add some tracks'
      redirect_to edit_user_playlist_path(@user, @playlist)
    else
       render action: "new"
    end
  end

  def update
    is_private = params[:playlist].delete(:is_private)
    if @playlist.update(playlist_params)
      @playlist.is_private = is_private
      redirect_to edit_user_playlist_path(@user, @playlist), notice: 'Playlist was successfully updated.'
    else
      set_assets
      render action: "edit"
    end
  end

  def destroy
    @playlist.destroy
    flash[:notice] = "That playlist is toast."
    redirect_to(user_playlists_url(@user))
  end

  protected

  def find_track_and_asset_in_playlist
    return if !params[:asset_id].present?

    @asset = Asset.where(id: @playlist.tracks.pluck(:asset_id), permalink: params[:asset_id]).take!

    # there may be many of the same asset in the playlist, but we're only ever going to refer to the first
    @track = @playlist.tracks.where(asset_id: @asset.id).take!
  end

  def playlist_params
    params.require(:playlist).permit(:cover_image, :title, :year, :is_private, :link1, :link2, :link3, :credits)
  end

  def render_desired_partial
    render partial: 'your_stuff.html.erb'     if params[:uploads_page]
    render partial: 'your_listens.html.erb'   if params[:listens_page]
    render partial: 'your_favorites.html.erb' if params[:favorites_page]
  end

  def set_assets
    @assets_pagy, @assets = pagy(@user.assets.recent, page_param: :uploads_page, items: 10)
  end

  def set_playlists
    @playlists =  current_user_is_admin_or_owner?(@user) ?
                      @user.playlists.include_private :
                      @user.playlists.only_public

    set_right_and_left_playlists if @playlists.present?
  end

  def set_right_and_left_playlists
    middle = (@playlists.size + 1) / 2
    @playlists_left  = @playlists[0...middle]
    @playlists_right = @playlists[middle..-1]
  end

  def authorized?
    current_user_is_mod_or_owner?(@user)
  end

  def find_playlists
    permalink = params[:permalink] || params[:id]
    @playlist = @user.playlists.where(permalink: permalink).first || @user.playlists.where(id: permalink).take!
  end

  def find_tracks
    @tracks = @playlist.tracks if @playlist
  end
end

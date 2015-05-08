class PlaylistsController < ApplicationController

  before_filter :find_user, :except => :all
  before_filter :find_playlists, :except => [:index, :new, :create, :sort, :all]
  before_filter :require_login, :except => [:index, :show, :all]
  before_filter :find_tracks, :only => [:show, :edit, :all]

  def all
    @playlists = Playlist.recent.only_public.with_pic.
                   paginate(:page => params[:page], :per_page => 20)
  end

  # all user's playlists
  def index
    @page_title = @description  = "#{@user.name}'s albums and playlists: "
    set_all_playlists
  end

  def sort
    respond_to do |format|
      format.html { @playlists = @user.playlists.include_private.all }
      format.js do
        params["playlist"].each_with_index do |id, position|
          @user.playlists.update(id, :position => position+1)
        end
        render :nothing => true
      end
    end
  end

  def favorites
    @playlist = @user.favorites
    redirect_to user_playlist_path(@user, @playlist)
  end

  def show
    @page_title = @description = "\"#{@playlist.title}\" by #{@user.name}"
    @single_playlist = true
  end

  def new
    @playlist = @user.playlists.build(:private => true)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @playlist }
    end
  end

  def edit
    set_assets
    @listens = @user.listened_to_tracks.preload(:user).
                 select('assets.*').distinct.
                 paginate(:page => params[:listens_page], :per_page => 10)
    @favorites = @user.favorites.tracks.paginate(:page => params[:favorites_page], :per_page => 10) if @user.favorites.present?
    if request.xhr?
      render_desired_partial
    end
  end

  def add_track
    id = params[:asset_id].split("_")[1]
    asset = Asset.find(id)
    @track = @playlist.tracks.create(:asset => asset)
    respond_to do |format|
      format.js
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
    return head(:bad_request)
  end

  def attach_pic
    if params[:pic].present?
      @pic = @playlist.build_pic(params[:pic])
      flash[:notice] = 'Picture updated!' if @pic.save
    end
    flash[:error] = 'Whups, picture not updated! Try again.' unless flash[:notice].present?
    redirect_to edit_user_playlist_path(@user, @playlist)
  end

  def remove_track
    @track = @playlist.tracks.find(params[:track_id])
    if @track && @track.destroy
      respond_to do |format|
        format.js {return head(:ok); render :nothing => true}
      end
    else
      render :nothing => true
    end
  rescue ActiveRecord::RecordNotFound
    head(:bad_request)
  end

  def sort_tracks
    # get the params for this playlist
    params["track"].each_with_index do |id, position|
      Track.update(id, :position => position+1)
    end
    render :nothing => true
  end


  def create
    @playlist = @user.playlists.build(params[:playlist])
    if @playlist.save
      flash[:notice] = 'Great, go ahead and add some tracks'
       redirect_to edit_user_playlist_path(@user, @playlist)
    else
       render :action => "new"
    end
  end

  def update
    if @playlist.update_attributes(params[:playlist])
      redirect_to edit_user_playlist_path(@user,@playlist), :notice => 'Playlist was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @playlist.destroy
    flash[:notice] = "That playlist is toast."
    redirect_to(user_playlists_url(@user))
  end

  protected

  def render_desired_partial
    render :partial => 'your_stuff.html.erb'     if params[:uploads_page]
    render :partial => 'your_listens.html.erb'   if params[:listens_page]
    render :partial => 'your_favorites.html.erb' if params[:favorites_page]
  end

  def set_assets
    @assets = @user.assets.recent.paginate(:page => params[:uploads_page], :per_page => 10)
  end

  def set_all_playlists
    @all_playlists =  current_user_is_admin_or_owner?(@user) ?
                      @user.playlists.include_private :
                      @user.playlists.only_public

    set_right_and_left_playlists if @all_playlists.present?
  end

  def set_right_and_left_playlists
    middle = (@all_playlists.size + 1) / 2
    @playlists_left  = @all_playlists[ 0 ... middle ]
    @playlists_right = @all_playlists[ middle .. -1 ]
  end


  def authorized?
    @playlist.nil? || current_user_is_admin_or_owner?(@playlist.user) ||
    %w[ destroy admin edit update remove_track attach_pic sort_tracks
        add_track set_playlist_description set_playlist_title ].include?(action_name) == false
  end

  def find_playlists
    permalink = params[:permalink] || params[:id]
    @playlist = @user.playlists.where(:permalink => permalink).first || @user.playlists.where(:id => permalink).take!
  end

  def find_tracks
    @tracks = @playlist.tracks if @playlist
  end
end

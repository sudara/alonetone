class PlaylistsController < ApplicationController
  
  before_filter :find_user
  before_filter :find_playlists, :except => [:index, :new, :create, :sort]
  before_filter :login_required, :except => [:index, :show]

  before_filter :find_tracks, :only => [:show, :edit]
  
  #rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  #rescue_from NoMethodError, :with => :user_not_found
  
  # GET /playlists
  # GET /playlists.xml
  def index
    if logged_in? && (current_user.id.to_s == @user.id.to_s || current_user.admin?)
      @all_playlists = @user.playlists.include_private 
    else
      @all_playlists = @user.playlists.public       
    end
    if present?(@all_playlists)
      # TODO: fugly array work
      split = @all_playlists.in_groups_of((@all_playlists.size.to_f/2).round)
      @playlists_left, @playlists_right = split[0].try(:compact), split[1].try(:compact)
      @page_title = "#{@user.name}'s albums and playlists"
      respond_to do |format|
         format.html # index.html.erb
         format.xml  { render :xml => @playlists }
      end
    else
      redirect_to user_path(@user)
    end
  end

  def sort
    respond_to do |format| 
      format.js do
        params["playlist"].each_with_index do |id, position|
          Playlist.update(id, :position => position)
        end
        render :nothing => true
      end
      format.html { @playlists = @user.playlists.include_private.find(:all) }
    end
  end
  
  # GET /playlists/1
  # GET /playlists/1.xml
  def show
    @page_title = "\"#{@playlist.title}\" by #{@user.name}"
    respond_to do |format|
      format.html # show.html.erb
      format.xml 
      format.rss 
    end
  end

  # GET /playlists/new
  # GET /playlists/new.xml
  def new
    @playlist = @user.playlists.build(:private => true)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @playlist }
    end
  end

  # GET /playlists/1/edit
  def edit
    # allow them to add their own assets
    # TODO: this is bad form, should be relocated to assets/index and listens/index
    @assets = @user.assets.paginate(:all, :limit => 10, :per_page => 10, :order => 'created_at DESC', :page => params[:uploads_page])
    @listens = @user.listens.paginate(:all, :limit => 10, :order => 'listens.created_at DESC', :per_page => 10, :page => params[:listens_page])
    respond_to do |format|
      format.html
      format.js do
        render :partial => 'your_stuff.html.erb' if params[:uploads_page]
        render :partial => 'your_listens.html.erb' if params[:listens_page]
      end
    end
  end

  def add_track
    @track = @playlist.tracks.create(:asset => Asset.find(params[:asset_id].split("_")[1])) 
    respond_to do |format|
      format.js 
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
    return head(:bad_request)  
  end
  
  def attach_pic
    @pic = @playlist.build_pic(params[:pic])
    if @pic.save
      flash[:notice] = 'Cover art updated!'
    else
      flash[:error] = 'Whups, make sure you choose a valid jpg, gif, or png file!'      
    end
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
      Track.update(id, :position => position)
    end
    render :nothing => true
  end

  # POST /playlists
  # POST /playlists.xml
  def create
    @playlist = @user.playlists.build(params[:playlist])

    respond_to do |format|
      if @playlist.save
        flash[:notice] = 'Great, go ahead and add some tracks'
        format.html { redirect_to edit_user_playlist_path(@user, @playlist) }
        format.xml  { render :xml => @playlist, :status => :created, :location => @playlist }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @playlist.errors, :status => :unprocessable_entity }
      end
    end
  end
 


  # PUT /playlists/1
  # PUT /playlists/1.xml
  def update

    respond_to do |format|
      if @playlist.update_attributes(params[:playlist])
        flash[:notice] = 'Playlist was successfully updated.'
        format.html { redirect_to edit_user_playlist_path(@user,@playlist) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @playlist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /playlists/1
  # DELETE /playlists/1.xml
  def destroy
    @playlist.destroy

    respond_to do |format|
      format.html { redirect_to(user_playlists_url(@user)) }
      format.xml  { head :ok }
    end
  end
  
  
  protected
  def not_found
    flash[:error] = "We didn't find that playlist from #{@user.name}, sorry, but try these others" and redirect_to user_playlists_path(@user) 
  end
    
  def authorized?
    (!%w(destroy admin edit update remove_track attach_pic sort_tracks add_track set_playlist_description set_playlist_title).include?(action_name)) || (@playlist.user_id.to_s == current_user.id.to_s) || admin?
  end
  
  def find_playlists
    @playlist = @user.playlists.find_by_permalink(params[:permalink] || params[:id])
    @playlist = @user.playlists.find(params[:id]) if !@playlist && params[:id] 
  end
  
  def find_tracks
    @tracks = @playlist.tracks
  end
  
end

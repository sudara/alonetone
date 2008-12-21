class PlaylistsController < ApplicationController
  
  before_filter :find_user
  before_filter :find_playlists, :except => [:index, :new, :create, :sort]
  before_filter :login_required, :except => [:index, :show]

  before_filter :find_tracks, :only => [:show, :edit]
  
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from NoMethodError, :with => :user_not_found
  
  # GET /playlists
  # GET /playlists.xml
  def index
    @all_playlists =  current_user_is_admin_or_owner?(@user) ?
                      @user.playlists.include_private :
                      @user.playlists.public

    if present?(@all_playlists)
      middle = (@all_playlists.size + 1) / 2
      
      @playlists_left  = @all_playlists[ 0 ... middle ]
      @playlists_right = @all_playlists[ middle .. -1 ]
      
      @page_title  = "#{@user.name}'s albums and playlists: "
      @description = @page_title + @all_playlists.collect(&:title).join(',')

      respond_to do |format|
         format.html # index.html.erb
         format.xml  { render :xml => @playlists }
      end
    else
      redirect_to user_playlists_path(@user)
    end
  end

  def sort
    redirect_to user_home_url(@user) \
    unless current_user_is_admin_or_owner?(@user)

    respond_to do |format| 
      format.html { @playlists = @user.playlists.include_private.find(:all) }
      format.js do
        params["playlist"].each_with_index do |id, position|
          Playlist.update(id, :position => position)
        end
        render :nothing => true
      end
    end
  end
  
  def favorites
    @playlist = @user.favorites
    redirect_to user_playlist_path(@user, @playlist)
  end
  
  # GET /playlists/1
  # GET /playlists/1.xml
  def show
    return not_found unless @playlist
    @page_title = @description = "\"#{@playlist.title}\" by #{@user.name}"
    @single_playlist = true
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
    @assets = @user.assets.paginate( :all, 
      :limit    => 10, 
      :per_page => 10, 
      :order    => 'created_at DESC', 
      :page     => params[:uploads_page]
    )

    @listens = @user.listens.paginate(:all, 
      :limit    => 10, 
      :order    => 'listens.created_at DESC', 
      :per_page => 10, 
      :page     => params[:listens_page]
    )

    if request.xhr? 
        render :partial => 'your_stuff.html.erb'   if params[:uploads_page]
        render :partial => 'your_listens.html.erb' if params[:listens_page]
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
    flash[:error] = "We didn't find that playlist from #{@user.name}! Sorry. Check out what *is* available" 
    redirect_to user_playlists_path(@user) 
  end
    
  def authorized?
    @playlist.nil? || current_user_is_admin_or_owner?(@playlist.user) ||
    %w[ destroy admin edit update remove_track attach_pic sort_tracks 
        add_track set_playlist_description set_playlist_title ].include?(action_name) == false
  end
  
  def find_playlists
    id = params[:id]
    permalink = params[:permalink] || id

    @playlist = @user.playlists.find_by_permalink(permalink) ||
                @user.playlists.find_by_id(id)
  end
  
  def find_tracks
    @tracks = @playlist.tracks if @playlist
  end
end
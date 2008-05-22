class AssetsController < ApplicationController  
  before_filter :find_user
  before_filter :find_asset, :only => [:show, :edit, :update, :destroy]
  
  # we check to see if the current_user is authorized based on the asset.user
  before_filter :login_required, :except => [:index, :show, :latest]
  before_filter :find_referer, :only => :show
  
  rescue_from NoMethodError, :with => :user_not_found
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  
  @@valid_listeners = ['msie','webkit','gecko','mozilla','netscape','itunes']
  
  # GET /assets
  # GET /assets.xml
  def index
      @page_title = @user.name + "'s uploaded music (mp3)"
      @assets = @user.assets.paginate(:all, :order => 'created_at DESC', :per_page => 200, :page => params[:page])
      respond_to do |format|
        format.html # index.rhtml
        format.xml  { render :xml => @assets.to_xml }
        format.rss  { render :xml => @assets.to_xml }
        format.js do  render :update do |page| 
            page.replace 'stash', :partial => "assets"
          end
        end
      end
  end

  def show
    respond_to do |format|
      format.html do
        @page_title = "#{@asset.title} by #{@user.name}"
        @assets = [@asset]
        @listens = @asset.listens.find(:all)
        @comments = @asset.comments.find_all_by_spam(false)
        @listeners = @asset.listeners.first(5)
        @single = true
      end
      format.mp3 do
        register_listen
        redirect_to @asset.public_mp3
      end
    end
  end

  def hot_track
    respond_to do |format|
      format.mp3 do
        params[:position] = 1 unless params[:position] && params[:position].to_i < 25
        @asset = Asset.find(:all, :limit => params[:position], :order => 'hotness DESC').last
        register_listen
        redirect_to @asset.public_mp3
      end
    end
  end

  # aka home page
  def latest
    respond_to do |wants|
      wants.html do
        @limit = (params[:latest] && params[:latest].to_i < 50) ? params[:latest] : 5
        @page_title = "Latest #{@limit} uploaded mp3s" if params[:latest]
        @assets = Asset.latest(@limit)
        @favorites = Track.favorites.find(:all, :limit => 5)
        @popular = Asset.find(:all, :limit => @limit, :order => 'hotness DESC')
        @comments = Comment.public.find(:all, :limit => 5, :order => 'created_at DESC') unless admin?
        @comments = Comment.include_private.find(:all, :limit => 5, :order => 'created_at DESC') if admin?        
        @playlists = Playlist.public.latest(12)
        @tab = 'home'
        @welcome = true unless logged_in?
        
      end
      wants.rss do 
        @assets = Asset.latest(50)
      end
    end
  end
  
  def radio
    # TODO: remove fugliness into model
    @per_page = (params[:per_page] && params[:per_page].to_i < 50) ? params[:per_page] : 5
    case params[:source]
    when 'latest'
      @assets = Asset.recent.paginate(:all, :per_page => @per_page, :page => params[:page])
    when 'favorites'
      @favorites = Track.favorites.paginate(:all, :per_page => @per_page, :page => params[:page])
    end
    @page_title = "#{params[:source]} #{@per_page} mp3s on alonetone" if params[:source] == 'latest' || 'favorites'
  end
  
  def top
    top = (params[:top] && params[:top].to_i < 50) ? params[:top] : 40
    @page_title = "Top #{top} tracks"
    @assets = Asset.find(:all, :limit => top, :order => 'hotness DESC')
    respond_to do |wants|
      wants.html 
      wants.rss
    end
  end
  
  def search
    @assets = Asset.find(:all, :conditions => [ "assets.filename LIKE ? OR assets.title LIKE ?", "%#{params[:search]}%","%#{params[:search]}%"], :limit => 10)
    render :partial => 'results', :layout => false
  end

  # GET /assets/new
  def new
    redirect_to signup_path unless logged_in?
    @tab = 'upload' if current_user == @user
    @asset = Asset.new
  end

  # GET /assets/1;edit
  def edit
    @descriptionless = @user.assets.descriptionless
  end

  # POST /assets
  # POST /assets.xml
  def create
    #collect and prepare
    @assets = []
    params[:asset] ||= {} 
    params[:asset_data] ||= []
    params[:asset].delete(:title) if params[:asset_data].size > 1
        
    params[:asset_data].each do |file|
      unless file.is_a?(String)
        Asset.extract_mp3s(file) do |valid_mp3|
          @assets << current_user.assets.create(params[:asset].merge(:uploaded_data => valid_mp3))
        end
      end
    end
    flashes = ''
    good = false
    @assets.each do |asset|
      # TODO: find a non-hackish way to ensure content_types are only mp3s at this point
      # The problem is a zip can contain a zip, which passes validation
      # Furthermore, if there is an issue with the zip, the rescue in the Asset model will hand the file back
      # Butt ugly, my friends. 
      if !asset.new_record? 
        flashes += "#{CGI.escapeHTML asset.filename} uploaded!<br/>"
        good = true
      else
        errors = asset.errors.collect{|attr, msg| msg }
        flashes  += "'#{CGI.escapeHTML asset.filename}' failed to upload: <br/>#{errors}<br/>"
      end
    end
    if good 
      flash[:ok] = flashes
      redirect_to user_tracks_path(current_user)
    else
      flash[:error] = flashes 
      flash[:error] = "Please try again with a file that is not empty (or miniscule) and is an mp3. <br/>Click the HALP! button or email sudara@alonetone.com for more help" if @assets.size == 0 
      redirect_to new_user_track_path(current_user)
    end
  end

  # PUT /assets/1
  # PUT /assets/1.xml
  def update
    respond_to do |format|
      if @asset.update_attributes(params[:asset])
        flash[:ok] = 'Track updated!'
        format.html { redirect_to user_track_url(current_user, @asset) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @asset.errors.to_xml }
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.xml
  def destroy
    @asset.destroy
    flash[:ok] = 'We threw the puppy away. No one can listen to it again (unless you reupload it, of course ;)'
    respond_to do |format|
      format.html { redirect_to user_tracks_url(current_user) }
      format.xml  { head :ok }
    end
  end
  
  protected
    
    def not_found
      flash[:error] = "We didn't find that mp3 from #{@user.name}, sorry. Maybe it is here?" and redirect_to user_tracks_path(@user) 
    end
    
    def find_referer
      case params[:referer]
        when 'itunes' then @referer = 'itunes'
        when 'download' then @referer = 'download'
        when 'home' then @referer = 'home page'
        when 'facebook' then @referer = 'facebook'
        else
          @referer = (request.env['HTTP_REFERER'] && !request.env['HTTP_REFERER'].empty?) ? request.env['HTTP_REFERER'] : 'alonetone'
      end
    end
    
    def authorized?
      # admin or the owner of the asset can edit/update/delete
      admin? || (params[:permalink].nil? || (current_user != :false && @asset.user_id.to_s == current_user.id.to_s))
    end
    
    def register_listen
      @asset.listens.create(:listener => (current_user || nil), 
        :track_owner=> @asset.user, 
        :source => @referer, 
        :ip => request.remote_ip) unless bot?
      @logger.warn("BOT LISTEN: "+ request.remote_ip + request.user_agent) if bot?
    end
    
    def bot?
      @@valid_listeners.detect{ |listener| request.user_agent.downcase.include? listener} == nil
    end
end


class AssetsController < ApplicationController  
  before_filter :find_user, :except => [:radio]
  before_filter :find_asset, :only => [:show, :edit, :update, :destroy, :stats]
  
  # we check to see if the current_user is authorized based on the asset.user
  before_filter :login_required, :except => [:index, :show, :latest, :radio, :listen_feed]
  before_filter :set_user_agent, :find_referer, :prevent_abuse, :only => :show
  
  #rescue_from NoMethodError, :with => :user_not_found
  #rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  # cfnetwork = Safari on osx 10.4 *only* when it tries to download
  @@valid_listeners = ['msie','webkit','quicktime','gecko','mozilla','netscape','itunes','chrome','opera', 'safari','cfnetwork','facebookexternalhit','ipad','iphone','apple']
  @@bots = ['bot','spider','baidu']
  @@bad_ip_ranges = ['195.239', '220.181', '61.135', '60.28.232', '121.14', '221.194']
  
  
  # GET /assets
  # GET /assets.xml
  def index
      @page_title = "All music by " + @user.name 

      @assets = @user.assets.paginate(:all, 
        :order    => 'created_at DESC', 
        :per_page => 200, 
        :page     => params[:page]
      ) unless request.format.to_sym == :json

      respond_to do |format|
        format.html # index.rhtml
        format.xml  { render :xml => @assets.to_xml }
        format.rss  { render :xml => @assets.to_xml }
        format.js do  render :update do |page| 
            page.replace 'stash', :partial => "assets"
          end
        end
        format.json do
          @assets = @user.assets.find(:all, :order => 'created_at DESC')          
          cached_json = cache("tracksby"+@user.login+@user.assets.find(:first, :order => 'created_at DESC').created_at.to_s(:db).gsub(/-|:|\s/,'')) do
            '{ "records" : ' + @assets.to_json(:methods => [:name, :type, :length, :seconds], :only => [:id,:name,:listens_count, :description,:permalink,:hotness, :user_id, :created_at]) + '}'
          end
          render :json => cached_json
        end
      end
  end

  def show
    respond_to do |format|
      format.html do
        @assets = [@asset]
        @listens = @asset.listens
        @comments = @asset.comments.public.find_all_by_spam(false)
        @listeners = @asset.listeners.first(5)
        @favoriters = @asset.favoriters
        @page_title = "#{@asset.name} by #{@user.name}"
        @description = @page_title + " - #{@asset[:description]}"
        @single_track = true
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
        pos = params[:position]
        pos = 1 unless pos && pos.to_i < 25
        @asset = Asset.find(:all, :limit => pos, :order => 'hotness DESC').last
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
        @page_title = @description = "Latest #{@limit} uploaded mp3s" if params[:latest]
        @assets = Asset.latest(@limit)
        @favorites = Track.favorites.find(:all, :limit => 5)
        @popular = Asset.find(:all, :limit => @limit, :order => 'hotness DESC')
        @comments = if admin?
          Comment.include_private.find(:all, :limit => 5)
        else
          Comment.public.by_member.find(:all, :limit => 5)
        end
        @playlists = Playlist.public.latest(12)
        @tab = 'home'
        @welcome = true unless logged_in?
        @feature = Feature.published.first
        if logged_in? and current_user.has_followees?
          @followee_tracks = current_user.new_tracks_from_followees(5)
        end
      end
      wants.rss do 
        @assets = Asset.latest(50)
      end
      wants.json do
        @assets = Asset.find(:all, :limit => 5000, :include => :user)
        render :json => @assets.to_json(:only => [:name, :title, :id], :methods => [:name], :include =>{:user => {:only => :name, :method => :name}})
      end
    end
  end
  
  def radio
    params[:source] = (params[:source] || cookies[:radio] || 'latest')
    @channel = params[:source].humanize
    @page_title = "alonetone Radio: #{@channel}" 
    @assets = Asset.radio(params[:source], params, current_user)
    @safari = request.env['HTTP_USER_AGENT'].to_s.include? 'AppleWebKit'
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
    @allow_reupload = true
  end

  def mass_edit
    redirect_to_default and return false unless logged_in? and current_user.id == @user.id or admin?
    @descriptionless = @user.assets.descriptionless
    if params[:assets] # expects comma seperated list of ids
      @assets = [@user.assets.find(params[:assets])].flatten
    else
      @assets = @user.assets
    end
  end
  
  def mass_update
    
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
      # Furthermore, if there is an issue with the zip, 
      # the rescue in the Asset model will hand the file back
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
      flash[:ok] = flashes + "<br/>Now, check the title and add description for your track(s)"
      redirect_to mass_edit_user_tracks_path(current_user, :assets => (@assets.collect(&:id)))
    else
      flash[:error] = if (@assets.size == 0)
        "Oh noes! Either that file was not an mp3 or you didn't actually pick a file to upload. " <<
        "Need help? Search or ask for help the forums or email support@alonetone.com" 
      else
        flashes
      end
      redirect_to new_user_track_path(current_user)
    end # if good
  end

  # PUT /assets/1
  # PUT /assets/1.xml
  def update
    result =  @asset.update_attributes(params[:asset])
    if request.xhr?
      if result 
        head :ok
      else
        head :bad_request
      end
    else
      if result
        redirect_to user_track_url(@asset.user.login, @asset.permalink) 
      else
        flash[:error] = "There was an issue with updating that track"
        render :action => "edit" 
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.xml
  def destroy
    @asset.destroy
    flash[:ok] = "We threw the puppy away. No one can listen to it again " << 
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
    
  def not_found
    flash[:error] = "We didn't find that mp3 from #{@user.name}, sorry. Maybe it is here?" 
    redirect_to user_tracks_path(@user) 
  end
  
  def find_referer
    @referer = case params[:referer]
      when 'itunes'   then 'itunes'
      when 'download' then 'download'
      when 'home'     then 'alonetone home'
      when 'facebook' then 'facebook'
      when 'listenapp' then 'http://ListenApp.com'
      when nil        then 'direct hit'
      when ''         then 'direct hit'
      else request.env['HTTP_REFERER']
    end
  end
  
  def authorized?
    # admin or the owner of the asset can edit/update/delete
    !dangerous_action? || current_user_is_admin_or_owner?(@user) || current_user_is_admin_or_owner?(@asset.user)
  end
  
  def dangerous_action?
    %w(destroy update edit mass_edit new create).include? action_name 
  end
  
  def register_listen
    @asset.listens.create(
      :listener     => current_user || nil, 
      :track_owner  => @asset.user, 
      :source       => @referer, 
      :user_agent   => @agent,
      :ip           => request.remote_ip
    ) unless bot?
  end
  
  def bot?
    ip = request.remote_ip
    return true unless present? request.user_agent 
    return true if @@bad_ip_ranges.any?{|cloaked_ip| ip.match /^#{cloaked_ip}/  } # check bad ips that fake user agent
    not browser? or @@bots.any?{|bot_agent| @agent.include? bot_agent} # check user agent agaisnt both white and black lists
  end
  
  def browser?
    @@valid_listeners.any?{|valid_agent| @agent.include? valid_agent} 
  end
  
  def set_user_agent
    @agent = request.user_agent.downcase    
  end
  
  def prevent_abuse
    if bot? 
      Rails.logger.error "BOT LISTEN ATTEMPT FAIL: #{@asset.filename} #{@agent} #{request.remote_ip} #{@referer} User:#{current_user || 0}"
      render(:text => "Denied due to abuse", :status => 403)    
    end
  end
  
  def abuser?
    request.user_agent and request.user_agent.include? 'mp3bot'
  end
end

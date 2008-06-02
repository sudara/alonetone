class FeaturesController < ApplicationController
  
  before_filter :login_required, :only => [:new, :create, :edit, :update, :delete]
  before_filter :find_feature, :only => [:update, :delete, :edit]
  # GET /features
  # GET /features.xml
  def index
    @features = admin? ? Feature.all: Feature.published

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @features }
    end
  end

  # GET /features/1
  # GET /features/1.xml
  def show
    @feature = admin? ? Feature.all.find_by_permalink(params[:id]) : Feature.published.find_by_permalink(params[:id])
    @user = @feature.featured_user
    Feature.increment_counter(:views_count, @feature.id) unless admin?
    @featured_tracks = @feature.featured_tracks
    @mostly_listens_to = @user.mostly_listens_to
    @comment = Comment.new(:commentable_type => 'feature',:commentable_id => @feature.id)
    @comments = @feature.comments.find(:all, :limit => 10)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feature }
    end
  end

  # GET /features/new
  # GET /features/new.xml
  def new
    @feature = Feature.new
    @users = User.alpha.musicians
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feature }
    end
  end

  # GET /features/1/edit
  def edit
    @users = User.alpha.musicians
    @assets = @feature.featured_user.assets
  end

  # POST /features
  # POST /features.xml
  def create
    @feature = Feature.new(params[:feature])

    respond_to do |format|
      if @feature.save
        flash[:notice] = 'Feature was successfully created.'
        format.html { redirect_to(@feature) }
        format.xml  { render :xml => @feature, :status => :created, :location => @feature }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feature.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /features/1
  # PUT /features/1.xml
  def update

    respond_to do |format|
      if @feature.update_attributes(params[:feature])
        flash[:notice] = 'Feature was successfully updated.'
        format.html { redirect_to(@feature) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feature.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /features/1
  # DELETE /features/1.xml
  def destroy
    @feature.destroy

    respond_to do |format|
      format.html { redirect_to(features_url) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def find_feature
    @feature = Feature.find_by_permalink(params[:id])
  end
  
end

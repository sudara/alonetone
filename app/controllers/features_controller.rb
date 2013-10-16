class FeaturesController < ApplicationController
  
  before_filter :require_login,  :only => [:new, :create, :edit, :update, :delete]
  before_filter :find_feature,    :only => [:update, :delete, :edit]

  def index
    @features = admin? ? Feature.all: Feature.published
    @page_title = 'Featured Artists'
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @features }
    end
  end
  
  def show
    @feature =  admin? ? find_feature : Feature.published.where(:permalink => params[:id]).first
    set_related_feature_variables
    @page_title = "Featured Artist: #{@user.name}"
  end

  def new
    @feature = Feature.new
    @users = User.alpha
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feature }
    end
  end

  def edit
    @users = User.alpha
    @assets = @feature.featured_user.assets
  end

  def create
    @feature = Feature.new(params[:feature])
    if @feature.save
      redirect_to @feature, :notice => 'Feature was successfully created.'
    else
      render :action => "new" 
    end
  end

  def update
    if @feature.update_attributes(params[:feature])
      flash[:notice] = 'Feature was successfully updated.'
      redirect_to(@feature) 
    else
      render :action => "edit" 
    end
  end


  def destroy
    @feature.destroy
    redirect_to(features_url)  
  end
  
  protected
  
  def authorized?
    admin?
  end
  
  def find_feature
    @feature = Feature.where(:permalink => params[:id]).first
  end
  
  def set_related_feature_variables
    @user = @feature.featured_user
    Feature.increment_counter(:views_count, @feature.id) unless admin?
    @featured_tracks = @feature.featured_tracks
    @mostly_listens_to = @user.mostly_listens_to
    @comment = Comment.new(:commentable_type => 'feature', :commentable_id => @feature.id)
    @comments = @feature.comments.include_private
  end
end

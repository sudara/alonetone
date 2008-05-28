class FeaturesController < ApplicationController
  
  before_filter :login_required, :only => [:new, :create, :edit, :update, :delete]
  before_filter :find_feature, :only => [:update, :delete]
  # GET /features
  # GET /features.xml
  def index
    @features = admin? ? Feature.find(:all) : Feature.published

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @features }
    end
  end

  # GET /features/1
  # GET /features/1.xml
  def show
    @feature = admin? ? Feature.find_by_permalink[params[:permalink]] : Feature.published.find_by_permalink[params[:permalink]]

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feature }
    end
  end

  # GET /features/new
  # GET /features/new.xml
  def new
    @feature = Feature.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feature }
    end
  end

  # GET /features/1/edit
  def edit
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
    @feature = Feature.find_by_permalink[params[:permalink]]
  end
  
end

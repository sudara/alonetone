# Yup, this is the blog controller 
class UpdatesController < ApplicationController
  before_filter :require_login, :except => [:index, :show]
  before_filter :gather_sidebar_fun, :except => [:destroy, :update]
    
  # GET /updates
  # GET /updates.xml
  def index
    @updates = Update.recent.includes(:comments => [:commenter => :pic]).paginate( 
      :per_page => 5, 
      :page     => params[:page])
          
    respond_to do |format|
      format.html # index.html.erb
      format.xml
      format.rss { render 'index.xml.builder' }
    end
  end

  # GET /updates/1
  # GET /updates/1.xml
  def show
    @update = Update.where(:permalink => params[:id]).includes(:comments => [:commenter => :pic]).take!
    @previous = Update.where('created_at < ?', @update.created_at).order('created_at DESC').first
    @next = Update.where('created_at > ?', @update.created_at).order('created_at ASC').first
    @page_title = @update.title
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @update }
    end
  end

  def new
    @update = Update.new
  end

  def edit
    @update = Update.find_by_permalink(params[:id])
  end

  def create
    @update = Update.new(params[:update])
    if @update.save
      flash[:notice] = 'Update was successfully created.'
      redirect_to blog_path(@update.permalink) 
    else
      format.html { render :action => "new" }
    end
  end

  def update
    @update = Update.find_by_permalink(params[:id])
    if @update.update_attributes(params[:update])
      flash[:notice] = 'Blog entry updated.'
      redirect_to blog_path 
    else
      render :action => "edit"
    end
  end

  # DELETE /updates/1
  # DELETE /updates/1.xml
  def destroy
    @update = Update.find_by_permalink(params[:id])
    @update.destroy

    respond_to do |format|
      format.html { redirect_to(updates_url) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def gather_sidebar_fun
    @recent_updates = Update.limit(10).order('created_at DESC')
  end
  
  def authorized?
    admin?
  end
end

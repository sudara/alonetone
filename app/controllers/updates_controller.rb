# -*- encoding : utf-8 -*-
# Yup, this is the blog controller 
class UpdatesController < ApplicationController
  before_filter :require_login, :except => [:index, :show]
  before_filter :gather_sidebar_fun, :except => [:destroy, :update]
    
  # GET /updates
  # GET /updates.xml
  def index
    @updates = Update.paginate( 
      :order    => 'created_at DESC', 
      :per_page => 5, 
      :page     => params[:page], 
      :include  => [ :comments => [:commenter => :pic] ]
    )
          
    respond_to do |format|
      format.html # index.html.erb
      format.xml
      format.rss { render 'index.xml.builder' }
    end
  end

  # GET /updates/1
  # GET /updates/1.xml
  def show
    @update = Update.find_by_permalink(params[:id])
    @previous = Update.find(:first, :conditions => ['created_at < ?',@update.created_at], :order => 'created_at DESC')
    @next = Update.find(:first, :first,:conditions => ['created_at > ?',@update.created_at], :order => 'created_at ASC')
    @comments = @update.comments.public.includes(:commenter)
    @page_title = @update.title
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @update }
    end
  end

  # GET /updates/new
  # GET /updates/new.xml
  def new
    @update = Update.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @update }
    end
  end

  # GET /updates/1/edit
  def edit
    @update = Update.find_by_permalink(params[:id])
  end

  # POST /updates
  # POST /updates.xml
  def create
    @update = Update.new(params[:update])

    respond_to do |format|
      if @update.save
        flash[:notice] = 'Update was successfully created.'
        format.html { redirect_to blog_path(@update.permalink) }
        format.xml  { render :xml => @update, :status => :created, :location => @update }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @update.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /updates/1
  # PUT /updates/1.xml
  def update
    @update = Update.find_by_permalink(params[:id])

    respond_to do |format|
      if @update.update_attributes(params[:update])
        flash[:notice] = 'Update was successfully updated.'
        format.html { redirect_to blog_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @update.errors, :status => :unprocessable_entity }
      end
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
    logged_in? && admin?
  end
end

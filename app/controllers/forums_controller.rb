# -*- encoding : utf-8 -*-
class ForumsController < ApplicationController
  
  before_filter :require_login, :except => [:index, :show]
  before_filter :find_user, :only => :index
  before_filter :set_forum_tab

  # GET /forums
  # GET /forums.xml
  def index
    # reset the page of each forum we have visited when we go back to index
    session[:forums_page] = nil

    @forums = Forum.ordered
    @page_title = 'alonetone Forums'
    @description = "alonetone forums. Discuss making music, free music, " << 
                   "the changing music world, and whatever else comes to you"
    @keywords = 'alonetone, forums, music, discussion, share'
    @online =  User.currently_online
    @user_topics = Topic.replied_to_by(@user).collect(&:topic) if logged_in?
    @popular_topics = Topic.popular.collect(&:first)
    @replyless_topics = Topic.replyless
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @forums }
    end
  end

  # GET /forums/1
  # GET /forums/1.xml
  def show
    @forum = Forum.find_by_permalink(params[:id])
    session[:forums] ||= {}
    session[:forums][@forum.id] = Time.now.utc
    
    if current_page > 1
      session[:forums_page] ||= Hash.new(1)
      session[:forums_page][@forum.id] = current_page 
    end
    
    respond_to do |format|
      format.html do # show.html.erb
        @topics = @forum.topics.sticky_and_recent.paginate :page => current_page, :per_page => 20
      end
      format.xml  { render :xml => @forum }
    end
  end

  # GET /forums/new
  # GET /forums/new.xml
  def new
    @forum = Forum.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @forum }
    end
  end

  # GET /forums/1/edit
  def edit
    @forum = Forum.find_by_permalink(params[:id])
  end

  # POST /forums
  # POST /forums.xml
  def create
    @forum = Forum.new(params[:forum])

    respond_to do |format|
      if @forum.save
        flash[:notice] = 'Forum was successfully created.'
        format.html { redirect_to(@forum) }
        format.xml  { render :xml => @forum, :status => :created, :location => @forum }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /forums/1
  # PUT /forums/1.xml
  def update
    @forum = Forum.find_by_permalink(params[:id])

    respond_to do |format|
      if @forum.update_attributes(params[:forum])
        flash[:notice] = 'Forum was successfully updated.'
        format.html { redirect_to(@forum) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /forums/1
  # DELETE /forums/1.xml
  def destroy
    @forum = Forum.find_by_permalink(params[:id])
    @forum.destroy

    respond_to do |format|
      format.html { redirect_to(forums_path) }
      format.xml  { head :ok }
    end
  end
  
  protected
  def authorized?
    admin?
  end
  
  def set_forum_tab
    @tab = "forums"
  end
end

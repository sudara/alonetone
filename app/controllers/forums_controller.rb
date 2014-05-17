class ForumsController < ApplicationController
  
  before_filter :require_login, :except => [:index, :show]
  before_filter :find_forum, :only => [:show, :edit, :update, :destroy]
  before_filter :set_forum_tab, :set_html_meta
  layout 'forums'

  def index
    reset_session_forums_page
    @forums = Forum.ordered.with_topics
    set_interesting_topics
  end

  def show
    handle_forum_session    
    respond_to do |format|
      format.html do # show.html.erb
        @topics = @forum.topics.not_spam.sticky_and_recent.paginate :page => current_page, :per_page => 20
      end
      format.xml  { render :xml => @forum }
    end
  end

  def new
    @forum = Forum.new
  end

  # GET /forums/1/edit
  def edit
  end

  def create
    if @forum = Forum.create(params[:forum])
      redirect_to @forum, :notice => 'Forum was created.' 
    else
      flash[:error] = "Hrm...."
      render :action => "new"
    end
  end

  def update
    if @forum.update_attributes(params[:forum])
      redirect_to @forum, :notice => 'Forum was successfully updated.' 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @forum.destroy
    redirect_to(forums_path) 
  end
  
  protected
  
  def find_forum
    @forum = Forum.where(:permalink => params[:id]).first || not_found
  end
  
  def reset_session_forums_page 
    # reset the page of each forum we have visited when we go back to index
    session[:forums_page] = nil
  end
  
  def set_interesting_topics
    @user_topics = Topic.replied_to_by(current_user).collect(&:topic) if logged_in?
    @popular_topics = Topic.popular.collect(&:first)
    @replyless_topics = Topic.replyless
  end
  
  def authorized?
    admin?
  end
  
  def set_html_meta
    @page_title = 'alonetone Forums'
    @description = "alonetone forums. Discuss making music, free music, the changing music world, and whatever else comes to you"
    @keywords = 'alonetone, forums, music, discussion, share'
  end
  
  def handle_forum_session
    session[:forums] ||= {}
    session[:forums][@forum.id] = Time.now.utc
    
    if current_page > 1
      session[:forums_page] ||= Hash.new(1)
      session[:forums_page][@forum.id] = current_page 
    end
  end
  
  def set_forum_tab
    @tab = "forums"
  end
end

class TopicsController < ApplicationController
  before_action :redirect_to_new_forums_if_white_theme
  before_action :find_forum
  before_action :find_topic, only: %i[show edit update destroy]
  before_action :require_login, only: %i[create update]
  layout "forums"

  def index
    redirect_to forum_path(@forum)
  end

  def edit; end

  def show
    set_session_topics
    @topic.hit! unless logged_in? && @topic.user_id == current_user.id
    if params[:spam]
      @posts = @topic.posts.recent
    else
      @posts = @topic.posts.recent.not_spam
    end
    @posts_pagy, @posts = pagy(@posts.preload(user: :pic))
    @post  = Post.new
  end

  def new
    redirect_to(login_url) && (return false) unless logged_in?
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @topic }
    end
  end

  def create
    unless current_user.can_post?
      @topic = Topic.new(params[:topic])
      flash[:error] = "Sorry, we couldn't do that right now. Please try again in a bit."
      return render "new"
    end

    @topic = current_user.post @forum, params[:topic], request
    if @topic.new_record?
      render action: "new"
    else
      flash[:notice] = 'Topic was successfully created.'
      redirect_to(forum_topic_path(@forum, @topic))
    end
  end

  def update
    current_user.revise @topic, params[:topic]
    if @topic.errors.empty?
      redirect_to(forum_topic_path(@topic.forum, @topic), notice: 'Topic was updated.')
    else
      render action: "edit"
    end
  end

  def destroy
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to(@forum) }
      format.xml  { head :ok }
    end
  end

  private

  def topics_params
    params.require(:topic).permit(:title, :body, :sticky, :locked)
  end

  def set_session_topics
    if @topic
      ((session[:topics] ||= {})[@topic.id] = Time.now.utc) if logged_in?
    end
  end

  def authorized?
    !%w[destroy edit update].include?(action_name) ||
      current_user_is_admin_or_moderator_or_owner?(@topic.user)
  end

  def find_forum
    @forum = Forum.where(permalink: params[:forum_id]).take!
  end

  def find_topic
    @topic = @forum.topics.where(permalink: params[:id]).take!
  end
end

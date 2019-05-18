class PostsController < ApplicationController
  before_action :redirect_to_new_forums_if_white_theme
  before_action :find_parents
  before_action :find_post, only: %i[edit update destroy spam unspam]
  before_action :require_login, only: :create
  layout "forums"
  include ActionView::RecordIdentifier

  # /posts
  # /users/1/posts
  # /forums/1/posts
  # /forums/1/topics/1/posts
  def index
    @posts = pagy((@parent ? @parent.posts : Post).search(params))
    @users = @user ? { @user.id => @user } : User.index_from(@posts)
    @page_title = @description = 'Recent Forum Posts'
    @show_title_and_link = true
    respond_to do |format|
      format.html # index.html.erb
      format.atom
      format.xml  { render xml: @posts }
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to forum_topic_path(@forum, @topic) }
      format.xml  do
        find_post
        render xml: @post
      end
    end
  end

  def unspam
    @post.ham!
    @post.update_column :is_spam, false
    # unspam the topic too
    @post.topic.update_column :spam, false if @post.topic.posts.count == 1
    redirect_back(fallback_location: root_path)
  end

  def spam
    @post.spam!
    @post.update_column :is_spam, true
    # mark the topic as spam too if it's the only post
    @post.topic.update_column :spam, true if @post.topic.posts.count == 1
    redirect_back(fallback_location: root_path)
  end

  def new
    @post = Post.new
  end

  def edit
    respond_to do |format|
      format.html # edit.html.erb
      format.js
    end
  end

  def create
    unless current_user.can_post?
      @post = Post.new(post_params)
      @post.forum = @forum
      @post.topic = @topic
      flash[:error] = "Sorry, we couldn't do that right now. Please try again in a bit."
      return render "new"
    end

    @post = current_user.reply @topic, params[:post][:body], request
    if @post.new_record?
      render action: "new"
    else
      flash[:notice] = 'Post was successfully created.'
      redirect_to(forum_topic_path(@forum, @topic, page: @topic.last_page, anchor: dom_id(@post)))
    end
  end

  def update
    if @post.update(post_params)
      flash[:notice] = 'Post was successfully updated.'
      redirect_to(forum_topic_path(@forum, @topic, anchor: dom_id(@post)))
    else
      render action: "edit"
    end
  end

  def destroy
    @post.destroy
    redirect_to(forum_topic_path(@forum, @topic))
  end

  protected

  def post_params
    params.require(:post).permit(:body)
  end

  def find_parents
    if params[:user_id]
      @parent = @user = User.where(login: params[:user_id]).first
    elsif params[:forum_id]
      @parent = @forum = Forum.find_by_permalink(params[:forum_id])
      @parent = @topic = @forum.topics.find_by_permalink(params[:topic_id]) if params[:topic_id]
    end
  end

  def authorized?
    !%w[destroy edit update new spam unspam].include?(action_name) || (!%w[spam unspam].include?(action_name) && (@topic.user_id.to_s == current_user.id.to_s)) || moderator?
  end

  def find_post
    @post = @topic.posts.find(params[:id])
  end
end

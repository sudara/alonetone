class CommentsController < ApplicationController
  before_action :find_user, except: %i[index create destroy]
  before_action :find_comment, only: %i[destroy]
  before_action :require_login, only: %i[destroy]

  def create
    head :bad_request unless request.xhr?
    @comment = Comment.new(massaged_params)
    @comment.is_spam = @comment.spam? # makes api request
    if !@comment.abuse_from_guest? && @comment.save
      CommentNotification.new_comment(@comment, @comment.commentable).deliver_now if @comment.is_deliverable?
      head :created, location: @comment
    else
      head :unprocessable_entity
    end
  end

  def destroy
    if params[:spam].present?
      @comment.spam!
      @comment.update_column(:is_spam, true)
      flash[:ok] = 'We marked that comment as spam'
    else
      @comment.destroy
      flash[:ok] = 'We threw away that comment'
    end
    redirect_back(fallback_location: root_path, status: :see_other)
  end

  def index
    if params[:login].present?
      find_user
      @page_title = "#{@user.name} Comments"
      @pagy, @comments = pagy(@user.comments_received.with_preloads.on_track.public_or_private(display_private_comments?))
      @pagy_comments_made, @comments_made = pagy(@user.comments_made.with_preloads.on_track.public_or_private(display_private_comments?), page_param: :page_made)
    else
      @page_title = "Recent Comments"
      @pagy, @comments = pagy(Comment.with_preloads.on_track.public_or_private(moderator?))
      set_spam_comments
    end
  end

  protected

  def comment_params
    params.require(:comment).permit(:body, :commentable_type, :commentable_id, :private,
      :commenter, :commentable)
  end

  def find_comment
    @comment = Comment.where(id: params[:id]).first
  end

  def set_spam_comments
    @pagy_spam, @spam = pagy(Comment.spam, page_param: :page_spam) if moderator?
  end

  def authorized?
    moderator? || user_made_comment? || user_owns_commentable?
  end

  def user_made_comment?
    @comment.user && @comment.user.id == current_user.id
  end

  def user_owns_commentable?
    @comment.commentable.user.id == current_user.id
  end

  def massaged_params
    comment_params.merge(
      commenter: find_commenter,
      remote_ip: request.remote_ip,
      user_agent: request.env['HTTP_USER_AGENT'],
      referrer: request.env['HTTP_REFERER']
    )
  end

  def find_commenter
    logged_in? ? current_user : nil
  end
end

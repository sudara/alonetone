class CommentsController < ApplicationController
  before_action :find_user, except: %i[index create spam unspam destroy]
  before_action :find_comment, only: %i[destroy unspam spam]
  before_action :require_login, only: %i[destroy unspam]

  def create
    if request.xhr? # it always is...
      head(:bad_request) unless params[:comment] && params[:comment][:body].present?
      @comment = Comment.new(massaged_params)
      head(:bad_request) unless @comment.save
      head :created, location: @comment
    else
      head(:bad_request)
    end
  rescue SocketError # allow offline dev
  end

  def destroy
    if params[:spam] == true
      @comment.spam!
      flash[:ok] = 'We marked that comment as spam'
    else
      @comment.destroy
      flash[:ok] = 'We threw away that comment'
    end
    redirect_back(fallback_location: root_path)
  end

  def unspam
    @comment.ham!
    @comment.update_column :is_spam, false
    @comment.deliver_comment_notification
    redirect_back(fallback_location: root_path)
  end

  def spam
    @comment.spam!
    @comment.update_column :is_spam, true
    redirect_back(fallback_location: root_path)
  end

  def index
    if params[:login].present?
      find_user
      @page_title = "#{@user.name} Comments"
      @comments = @user.comments.on_track.public_or_private(display_private_comments?).includes(commenter: :pic, commentable: { user: :pic }).page(params[:page])
      set_comments_made
    else
      @page_title = "Recent Comments"
      @comments = Comment.on_track.includes(commenter: :pic, commentable: { user: :pic }).public_or_private(moderator?).page(params[:page])
      set_spam_comments
    end
    render 'index_white' if white_theme_enabled?
  end

  protected

  def comment_params
    params.require(:comment).permit(:body, :remote_ip, :commentable_type, :commentable_id, :private,
    :commenter_id, :user_agent, :referrer, :commenter, :user_id, :commentable)
  end

  def find_comment
    @comment = Comment.where(id: params[:id]).first
  end

  def set_comments_made
    @comments_made = Comment.where(commenter_id: @user.id).public_or_private(display_private_comments?).page(params[:made_page])
  end

  def set_spam_comments
    @spam = Comment.spam.page(params[:spam_page]) if moderator?
  end

  def authorized?
    moderator? || (@comment.user.id == @comment.commentable.user.id)
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

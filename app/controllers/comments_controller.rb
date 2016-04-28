class CommentsController < ApplicationController
  
  before_filter :find_user, :except => [:index, :create, :spam, :unspam, :destroy]
  before_filter :find_comment, :only => [:destroy, :unspam, :spam]
  before_filter :require_login, :only => [:destroy, :unspam]
  
  def create
    if request.xhr? # it always is...
      unless params[:comment] && params[:comment][:body].present?
        return head(:bad_request) 
      end
      @comment = Comment.new(massaged_params)
      return head(:bad_request) unless @comment.save
      render :nothing => true
    else
      render :nothing => true, :status => :bad_request
    end
  end  

  def destroy
    if params[:spam] == true
      @comment.spam! 
      flash[:ok] = 'We marked that comment as spam'
    else
      @comment.destroy
      flash[:ok] = 'We threw away that comment'
    end
    redirect_to :back 
  end

  def unspam
    @comment.ham!
    @comment.update_column :is_spam, false
    @comment.deliver_comment_notification
    redirect_to :back
  end
  
  def spam
    @comment.spam!
    @comment.update_column :is_spam, true
    redirect_to :back
  end

  def index
    if params[:login].present?
      find_user
      @page_title = "#{@user.name} Comments"
      @comments = @user.comments.public_or_private(display_private_comments?).page(params[:page])
      set_comments_made
    else
      @page_title = "Recent Comments"
      @comments = Comment.public_or_private(moderator?).page(params[:page])
      set_spam_comments
    end
  end
  
  
  protected
  
  def find_comment
    @comment = Comment.where(:id => params[:id]).first    
  end
  
  def set_comments_made
    @comments_made = Comment.where(:commenter_id => @user.id).public_or_private(display_private_comments?).page(params[:made_page])
  end
  
  def set_spam_comments
    @spam = Comment.spam.page(params[:spam_page]) if moderator?
  end
  
  def authorized?
    moderator? or (@comment.user.id == @comment.commentable.user.id )
  end
  
  def massaged_params
    params[:comment].merge({
      :commenter          => find_commenter,
      :remote_ip          => request.remote_ip,
      :user_agent         => request.env['HTTP_USER_AGENT'], 
      :referrer           => request.env['HTTP_REFERER']})
  end
  
  def find_commenter
    logged_in? ? current_user : nil
  end
end

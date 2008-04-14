class CommentsController < ApplicationController
  
  before_filter :find_user
  before_filter :find_commenter
  
  def create
    respond_to do |wants|
      wants.js do
        return head(:bad_request) unless params[:comment][:body] && !params[:comment][:body].empty?
        case params[:comment][:commentable_type] 
        when 'asset'
          find_asset
          @comment = @asset.comments.build(:commenter => @commenter,
                                            :body => params[:comment][:body], 
                                            :user => @asset.user,
                                            :remote_ip => request.remote_ip,
                                            :user_agent => request.env['HTTP_USER_AGENT'], 
                                            :referer   => request.env['HTTP_REFERER'])
          @comment.env = request.env
          
        end
        return head(:bad_request) unless @comment.save && User.increment_counter(:comments_count, @asset.user)
        render :nothing => true
      end
    end
  end
  
  
  def destroy
    @comment = Comment.find(params[:id], :include => [:commenter, :user])
    if current_user.admin? || (@comment.user.id == @comment.commentable.user.id)
      @comment.destroy 
      flash[:ok] = 'We trashed that feedback, yo'
    else
      flash[:error] = "Um, sorry, you can't do that"
    end
    redirect_to :back 
  end
  
  
  def index
    @comments_made = Comment.paginate_by_spam(false, :per_page => 10, :page => params[:made_page], :order => 'created_at DESC', :conditions => {:commenter_id => @user.id})
    @comments = @user.comments.paginate_by_spam(false, :per_page => 10, :page => params[:page])
  end
  
  
  protected
  
  
  
  def find_commenter
    @commenter = current_user if logged_in?
  end
  
end

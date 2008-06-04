class CommentsController < ApplicationController
  
  before_filter :find_user
  
  def create
    respond_to do |wants|
      wants.js do
        return head(:bad_request) unless params[:comment] && params[:comment][:body] && !params[:comment][:body].empty?                                  
        case params[:comment][:commentable_type] 
        when 'asset'
          find_asset
          @comment = @asset.comments.build(shared_attributes.merge(:user => @asset.user))
        when 'feature'
          @feature = Feature.find(params[:comment][:commentable_id])
          @comment = @feature.comments.build(shared_attributes)
        when 'update'
          @update = Update.find(params[:comment][:commentable_id])
          @comment = @update.comments.build(shared_attributesrespond_to do |wants|
        end
        @comment.env = request.env
        return head(:bad_request) unless @comment.save
        User.increment_counter(:comments_count, @asset.user) if @asset
        render :nothing => true
      end
    end
  end  
  
  def destroy
    @comment = Comment.find(params[:id], :include => [:commenter, :user])
    if current_user.admin? || (@comment.user.id == @comment.commentable.user.id)
      @comment.report_as_false_negative 
      flash[:ok] = 'We trashed that feedback, yo'
    else
      flash[:error] = "Um, sorry, you can't do that"
    end
    redirect_to :back 
  end
  
  
  def index
    if params[:login]
      @page_title = "Recent comments of #{@user.name}"
      if display_private_comments_of?(@user)
        @comments = @user.comments.include_private.paginate(:all, :per_page => 10, :page => params[:page])
        @comments_made = Comment.include_private.paginate(:all, :per_page => 10, :page => params[:made_page], 
          :order => 'created_at DESC', :conditions => {:commenter_id => @user.id})
      else
        @comments = @user.comments.public.paginate(:all, :per_page => 10, :page => params[:page])
        @comments_made = Comment.public.paginate(:all, :per_page => 10, :page => params[:made_page], 
          :order => 'created_at DESC', :conditions => {:commenter_id => @user.id, :private => false})
      end
      
    else
      @page_title = "Recent Comments"
      @comments = Comment.public.paginate(:all, :per_page => 10, :page => params[:page]) unless admin?
      @comments = Comment.include_private.paginate(:all, :per_page => 10, :page => params[:page]) if admin?
    end
  end
  
  
  protected
  
  def shared_attributes
    {:commenter => find_commenter,
    :body => params[:comment][:body], 
    :private => (params[:comment][:private] || false),
    :remote_ip => request.remote_ip,
    :user_agent => request.env['HTTP_USER_AGENT'], 
    :referer   => request.env['HTTP_REFERER']}
  end
  
  def find_commenter
    logged_in? ? current_user : nil
  end
  
end

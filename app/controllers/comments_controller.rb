class CommentsController < ApplicationController
  
  before_filter :find_user
  before_filter :find_comment, :only => [:destroy, :unspam]
  before_filter :login_required, :only => [:destroy, :unspam]
  
  def create
    if request.xhr? 
      unless params[:comment] && !params[:comment][:body].blank?
        return head(:bad_request) 
      end
      
      case params[:comment][:commentable_type] 
        # TODO: move into model
        when 'asset'
          find_asset
          @comment = @asset.comments.build(shared_attributes.merge(:user => @asset.user))

        when 'feature'
          @feature = Feature.find(params[:comment][:commentable_id])
          @comment = @feature.comments.build(shared_attributes)

        when 'update'
          @update = Update.find(params[:comment][:commentable_id])
          @comment = @update.comments.build(shared_attributes)
      end

      @comment.env = request.env

      return head(:bad_request) unless @comment.save

      if @asset && !@comment.spam
        User.increment_counter(:comments_count, @asset.user) 
        Asset.increment_counter(:comments_count, @asset) 
      end

      render :nothing => true
    end
  end  
  

  def destroy
    if params[:spam] == true
      @comment.report_as_false_negative 
      flash[:ok] = 'We marked that comment as spam'
    else
      @comment.destroy
      flash[:ok] = 'We threw away that comment'
    end
    redirect_to :back 
  end
  

  def unspam
    @comment.report_as_false_positive
    redirect_to :back
  end
  
  
  def index
    if params[:login]
      @page_title = "#{@user.name} Comments"

      if display_private_comments_of?(@user)
        @comments = @user.comments.include_private.paginate( :all, 
          :per_page   => 10, 
          :page       => params[:page]
        )
        
        @comments_made = Comment.include_private.paginate(:all, 
          :per_page   => 10,
          :page       => params[:made_page], 
          :order      => 'created_at DESC', 
          :conditions => {:commenter_id => @user.id}
        )
      else
        @comments = @user.comments.public.paginate( :all,
          :per_page   => 10, 
          :page       => params[:page]
        )
        
        @comments_made = Comment.public.paginate( :all, 
          :per_page   => 10, 
          :page       => params[:made_page], 
          :order      => 'created_at DESC', 
          :conditions => { :commenter_id => @user.id, :private => false }
        )
      end
      
    else # if params[:login]
      @page_title = "Recent Comments"
      
      @comments = Comment.public.paginate( :all,
          :per_page => 10,
          :page => params[:page]
      ) unless admin?
      
      @comments = Comment.include_private.paginate( :all,
          :per_page => 10,
          :page => params[:page]
      ) if admin?
      
      @spam = Comment.paginate_by_spam( true,
          :order    => 'created_at DESC',
          :per_page => 10,
          :page     => params[:spam_page]
      ) if moderator? or admin?
    end
  end
  
  
  protected
  
  def find_comment
    @comment = Comment.find(params[:id], :include => [:commenter, :user])    
  end
  
  def authorized?
    logged_in? && (
      current_user.moderator? || 
      current_user.admin? || 
      @comment.user.id == @comment.commentable.user.id )
  end
  
  def shared_attributes
    {
      :commenter  => find_commenter,
      :body       => params[:comment][:body], 
      :private    => params[:comment][:private] || false,
      :remote_ip  => request.remote_ip,
      :user_agent => request.env['HTTP_USER_AGENT'], 
      :referer    => request.env['HTTP_REFERER']
    }
  end
  
  def find_commenter
    logged_in? ? current_user : nil
  end
end
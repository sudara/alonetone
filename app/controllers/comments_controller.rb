# -*- encoding : utf-8 -*-
class CommentsController < ApplicationController
  
  before_filter :find_user
  before_filter :find_comment, :only => [:destroy, :unspam]
  before_filter :require_login, :only => [:destroy, :unspam]
  
  def create
    if request.xhr? # it always is...
      unless params[:comment] && !params[:comment][:body].blank?
        return head(:bad_request) 
      end
      @comment = Comment.new(massaged_params)
      return head(:bad_request) unless @comment.save
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
    @comment.ham!
    @comment.update
    redirect_to :back
  end
  
  def spam
    @comment.spam!
    redirect_to :back
  end
  
  
  def index
    respond_to do |format|

      format.html do
        if params[:login]
          @page_title = "#{@user.name} Comments"

          if display_private_comments_of?(@user)
            @comments = @user.comments.include_private.paginate(:per_page => 10, 
              :page => params[:page])
        
            @comments_made = Comment.include_private.paginate(:per_page => 10,
              :page       => params[:made_page], 
              :conditions => {:commenter_id => @user.id}
            )
          else
            @comments = @user.comments.public.paginate(:per_page => 10, 
              :page       => params[:page]
            )
        
            @comments_made = Comment.public.paginate(:per_page => 10, 
              :page       => params[:made_page], 
              :conditions => { :commenter_id => @user.id }
            )
          end
      
        else # if params[:login]
          @page_title = "Recent Comments"
      
          @comments = Comment.public.paginate(:per_page => 10,
              :page => params[:page]
          ) unless admin?
      
          @comments = Comment.include_private.paginate(:per_page => 10,
              :page => params[:page]
          ) if admin?
      
          @spam = Comment.paginate_by_spam(:order  => 'created_at DESC',
              :per_page => 10,
              :page     => params[:spam_page]
          ) if moderator? or admin?
        end
        format.json do
        if params[:start] && params[:end]
          @comments = Comment.count_by_user(params[:start].to_date, params[:end].to_date, params[:limit].to_i)
        else
          @comments = Comment.count_by_user(30.days.ago, Date.today)
        end
        render :json => @comments.collect{|c,count| [c.name, c.avatar,count]}.to_json
      end
      end
    end
  end
  
  
  protected
  
  def find_comment
    @comment = Comment.find(params[:id], :include => [:commenter, :user])    
  end
  
  def authorized?
    current_user.moderator? or (@comment.user.id == @comment.commentable.user.id )
  end
  
  def massaged_params
    {
      :commenter          => find_commenter,
      :body               => params[:comment][:body], 
      :commentable_type   => params[:comment][:commentable_type], 
      :commentable_id     => params[:comment][:commentable_id], 
      :private            => params[:comment][:private] || false,
      :remote_ip  => request.remote_ip,
      :user_agent => request.env['HTTP_USER_AGENT'], 
      :referer    => request.env['HTTP_REFERER']
    }
  end
  
  def find_commenter
    logged_in? ? current_user : nil
  end
end

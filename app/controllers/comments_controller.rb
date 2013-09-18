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
          @comments = @user.comments.public_or_private(display_private?).paginate(:page => params[:page])
          @comments_made = Comment.where(:commenter_id => @user.id).public_or_private(display_private?).paginate(:page => params[:made_page])
        else
          @page_title = "Recent Comments"
          @comments = Comment.public_or_private(moderator?).paginate(:page => params[:page])
          @spam = Comment.spam.paginate(:page => params[:page]) if moderator?
        end
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
  
  
  protected
  
  def find_comment
    @comment = Comment.find(params[:id], :include => [:commenter, :user])    
  end
  
  def authorized?
    moderator? or (@comment.user.id == @comment.commentable.user.id )
  end
  
  def display_private?
    moderator? or (logged_in? && (current_user.id.to_s == @user.id.to_s))
  end
  
  def massaged_params
    {
      :commenter          => find_commenter,
      :body               => params[:comment][:body], 
      :commentable_type   => params[:comment][:commentable_type], 
      :commentable_id     => params[:comment][:commentable_id], 
      :private            => params[:comment][:private] || false,
      :remote_ip          => request.remote_ip,
      :user_agent         => request.env['HTTP_USER_AGENT'], 
      :referer            => request.env['HTTP_REFERER']
    }
  end
  
  def find_commenter
    logged_in? ? current_user : nil
  end
end

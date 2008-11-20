class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    if !comment.spam? and 
        user_wants_email?(comment.user) and 
        comment.commentable.class == Asset and
        comment.user != comment.commenter
      CommentMailer.deliver_new_comment(comment, comment.commentable) 
    end
  end
  
  protected
  
  def user_wants_email?(user)
    # anyone who doesn't have it set to false, aka, opt-out
    (user.settings == nil) || (user.settings[:email_comments] != "false")
  end
end

class CommentMailer < ActionMailer::Base
  

  def new_comment(comment, asset, sent_at = Time.now)
    subject    "[alonetone] Comment on #{asset.name} from #{person_who_made(comment)}"
    recipients comment.user.email
    from       'noreply@alonetone.com'
    sent_on    sent_at
    body       :comment => comment[:body],
               :name => comment.user.name, 
               :commenter => person_who_made(comment),
               :song => asset.name,
               :number_of_comments => asset.comments_count,
               :login => comment.user.login
  end

  protected
  
  def person_who_made(comment)
    comment.commenter ? comment.commenter.name : 'Guest'
  end

end

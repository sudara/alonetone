class CommentNotification < ActionMailer::Base
  default :from => Alonetone.email
  

  def new_comment(comment, asset)
    @comment = comment[:body]
    @name = comment.user.name
    @commenter = person_who_made(comment)
    @song = asset.name
    @number_of_comments = asset.comments_count
    @login = comment.user.login

    mail :to => comment.user.email, :subject => "[alonetone] Comment on '#{asset.name}' from #{person_who_made(comment)}"
  end



  protected
  
  def person_who_made(comment)
    comment.commenter ? comment.commenter.name : 'Guest'
  end

end

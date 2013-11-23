module CommentsHelper
  
  def link_for_comment(comment)
    return "" unless comment.commentable.present?
    case comment.commentable_type.downcase
    when 'asset'
      link_to comment.commentable.name, user_track_path(comment.commentable.user,comment.commentable)
    when 'feature'
      link_to comment.commentable.name, feature_path(comment.commentable.user.login)
    when 'update' # aka blog
      link_to comment.commentable.name, blog_path(comment.commentable.permalink)
    end
  end
end

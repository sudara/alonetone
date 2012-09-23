# -*- encoding : utf-8 -*-
module CommentsHelper
  
  def link_for_comment(comment)
    case comment.commentable_type.downcase
    when 'asset'
      link_to h(comment.commentable.name), user_track_path(comment.commentable.user,comment.commentable)
    when 'feature'
      link_to h(comment.commentable.name), feature_path(comment.commentable.user.login)
    when 'update' # aka blog
      link_to h(comment.commentable.name), blog_path(comment.commentable.permalink)
    end
  end
end

class CommentCommand
  attr_reader :comment

  def initialize(comment)
    @comment = comment
  end

  def spam_and_soft_delete
    return if comment.is_spam? && comment.soft_deleted?

    comment.spam!
    Comment.adjust_cached_comment_counts(Comment.where(id: comment.id), -1)
    comment.update_attribute(:is_spam, true)
    comment.soft_delete
  end

  def unspam_and_restore
    return unless comment.is_spam? || comment.soft_deleted?

    comment.ham!
    comment.update_attribute(:is_spam, false)
    comment.restore
    Comment.adjust_cached_comment_counts(Comment.where(id: comment.id), 1)
  end
end

module Admin
  class CommentsController < Admin::BaseController
    before_action :set_comment, only: %i[unspam spam]

    def index
      @pagy, @comments = pagy(Comment.recent)
    end

    def unspam
      @comment.ham!
      @comment.update_column :is_spam, false
      @comment.deliver_comment_notification

      redirect_back(fallback_location: root_path)
    end

    def spam
      @comment.spam!
      @comment.update_column :is_spam, true

      redirect_back(fallback_location: root_path)
    end

    def mark_group_as_spam
      # limit scope to non_spam comments
      # and we should include private comments as well
      scope = Comment.where(params[:mark_spam_by].permit!)
      comments = scope.include_private

      comments.map(&:spam!)
      comments.update_all(is_spam: true)
      redirect_back(fallback_location: root_path)
    end

    private

    def set_comment
      @comment = Comment.find(params[:id])
    end
  end
end

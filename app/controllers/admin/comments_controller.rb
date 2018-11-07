module Admin
  class CommentsController < Admin::BaseController
    before_action :set_comment, only: [:unspam, :spam]

    def index
      @pagy, @comments = pagy(Comment.all)
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

    # sample params:
    # { mark_spam_by: {ip: 123.3.3.169}}
    # or
    # { mark_spam_by: {user_id: sudara.id}}
    # then we can reuse this method for different mass spam rules
    def spam_group
      binding.pry
      scope = Comment.where(params[:mark_spam_by])
      # limit scope to non_spam comments
      # and we should include private comments as well
      comments = scope.include_private
      comments.map(&:spam!)
      comments.update_all(is_spam: true)

      redirect_back(fallback_location: root_path)
    end

    private

    def set_comment
      @comment = Comment.find(params[:id])
    end

    def admin_comment_params
      params.fetch(:admin_comment, {})
    end
  end
end

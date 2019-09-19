module Admin
  class CommentsController < Admin::BaseController
    before_action :set_comment, only: %i[unspam spam]

    def index
      if permitted_params[:filter_by]
        @pagy, @comments = pagy(Comment.where(permitted_params[:filter_by]).recent)
      else
        @pagy, @comments = pagy(Comment.recent)
      end
    end

    def unspam
      @comment.ham!
      @comment.update_attribute :is_spam, false
      CommentNotification.new_comment(@comment, @comment.commentable).deliver_now if @comment.is_deliverable?

      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.js
      end
    end

    def spam
      @comment.spam!
      @comment.update_attribute :is_spam, true

      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.js
      end
    end

    private

    def permitted_params
      params.permit(:filter_by)
    end

    def set_comment
      @comment = Comment.find(params[:id])
    end
  end
end

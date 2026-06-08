module Admin
  class CommentsController < Admin::BaseController
    layout 'admin'

    before_action :set_comment, only: %i[unspam spam]

    def index
      @admin_title = 'Comments'
      @pagy, @comments = if permitted_params[:filter_by]
                           pagy(Comment.where(permitted_params[:filter_by]).recent)
                         else
                           pagy(Comment.recent)
                         end
    end

    def unspam
      @comment.ham!
      @comment.update_attribute :is_spam, false
      respond_with_comment_row
    end

    def spam
      @comment.spam!
      @comment.update_attribute :is_spam, true
      respond_with_comment_row
    end

    private

    def respond_with_comment_row
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@comment, partial: 'admin/comments/comment', locals: { comment: @comment })
        end
        format.html { redirect_back(fallback_location: root_path, status: :see_other) }
      end
    end

    def permitted_params
      params.permit(:filter_by)
    end

    def set_comment
      @comment = Comment.find(params[:id])
    end
  end
end

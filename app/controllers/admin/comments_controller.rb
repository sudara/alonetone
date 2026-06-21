module Admin
  class CommentsController < Admin::BaseController
    before_action :set_comment, only: %i[unspam spam]

    def index
      @admin_title = 'Comments'
      @pagy, @comments = pagy(Comment.filter_by(permitted_params[:filter_by]).includes(:commenter))
    end

    def unspam
      CommentCommand.new(@comment).unspam_and_restore
      respond_with_comment_row
    end

    def spam
      CommentCommand.new(@comment).spam_and_soft_delete
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
      @comment = Comment.with_deleted.find(params[:id])
    end
  end
end

class Admin::CommentsController < Admin::BaseController
  def index
    @pagy, @comments = pagy(Comment.all)
  end
end

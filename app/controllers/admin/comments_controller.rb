module Admin
  class CommentsController < Admin::BaseController
    def index
      @pagy, @comments = pagy(Comment.all)
    end
  end
end

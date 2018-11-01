class Admin::CommentsController < Admin::BaseController
  def index
    @comments = Comment.all
  end
end

class Admin::Comments::MarkAsSpamController < Admin::BaseController
  def create
    if params[:id]
      comments = Comment.where(id: params[:id])
    elsif params[:user_id]
      comments = Comment.where(commenter: params[:user_id])
    end

    comments.map(&:spam!)
    comments.update_all(is_spam: true)
    redirect_back(fallback_location: root_path)
  end
end

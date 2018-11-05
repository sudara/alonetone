class Admin::Comments::AddToBlocklistController < Admin::BaseController
  def create
    comments = Comment.where(id: params[:id])
    # comments.update_all(is_spam: true)

    redirect_back(fallback_location: root_path)
  end
end

module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: %i[delete spam]

    def index
      @pagy, @users = pagy(User.recent)
    end

    def delete
      @user.soft_delete
      @user.efficiently_soft_delete_relations
      redirect_back(fallback_location: root_path)
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end

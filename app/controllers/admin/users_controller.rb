module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: %i[delete restore]

    def index
      @pagy, @users = pagy(User.with_deleted.recent)
    end

    # should we rescue/display any error that occured to admin user
    def delete
      @user.soft_delete_with_relations
      redirect_back(fallback_location: root_path)
    end

    def restore
      @user.restore
      @user.restore_relations
    end

    private

    def set_user
      @user = User.with_deleted.find_by_login(params[:id])
    end
  end
end

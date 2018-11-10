module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: %i[destroy spam]

    def index
      @pagy, @users = pagy(User.all)
    end

    def destroy_user
      @user.destroy
      redirect_back(fallback_location: root_path)
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end

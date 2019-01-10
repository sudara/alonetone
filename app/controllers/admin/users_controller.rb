module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: %i[destroy spam]

    def index
      if permitted_params[:deleted]
        scope = User.only_deleted
      else
        scope = User.recent
      end
      @pagy, @users = pagy(scope)
    end

    def destroy
      @user.destroy
      redirect_back(fallback_location: root_path)
    end

    private

    def permitted_params
      params.permit!
    end

    def set_user
      @user = User.find(params[:id])
    end
  end
end

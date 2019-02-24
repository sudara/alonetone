module Admin
  class UsersController < Admin::BaseController
    before_action :find_user, only: %i[delete restore]

    def index
      scope = User.only_deleted if permitted_params[:deleted]
      # Do we want to display both deleted and active users on index?
      scope ||= User.with_deleted.recent

      @pagy, @users = pagy(scope)
    end

    def delete
      @user.destroy(recursive: true)
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.js
      end
    end

    def restore
      # this will perform restore on all associated records that also act
      # as paranoid
      @user.restore(recursive: true)
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.js
      end
    end

    private

    def permitted_params
      params.permit!
    end
  end
end

module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: %i[delete restore unspam]

    def index
      scope = User.only_deleted if permitted_params[:deleted]
      scope ||= User.with_deleted.recent

      scope = scope.where(permitted_params[:filter_by]) if permitted_params[:filter_by]

      @pagy, @users = pagy(scope)
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

    def unspam
      @user.ham!
      @user.update_column :is_spam, false
      redirect_back(fallback_location: root_path)
    end

    private

    def permitted_params
      params.permit(:filter_by, :deleted)
    end

    def set_user
      @user = User.with_deleted.find_by_login(params[:id])
    end
  end
end

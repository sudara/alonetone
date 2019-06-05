module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, except: %i[index]

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
    end

    def spam
      @user.spam_and_mark_for_deletion!
    end

    def mark_all_users_with_ip_as_spam
      ip = @user.current_login_ip
      count = User.where(current_login_ip: ip).count
      MarkAllUsersWithIpAsSpam.perform_later(ip)
      redirect_to :index, notice: "#{count} accounts by #{ip} being marked as spam..."
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

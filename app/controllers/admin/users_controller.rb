module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, except: %i[index]

    def index
      @pagy, @users = pagy(User.filter_by(permitted_params[:filter_by]))
    end

    def show
      @assets_pagy, @assets = pagy(@user.assets.with_deleted, items: 5)
      @comment_pagy, @comments = pagy(@user.comments.with_deleted, items: 5)
    end

    def delete
      UserCommand.new(@user).soft_delete_with_relations
      redirect_to admin_users_path(filter_by: :deleted)
    end

    def restore
      UserCommand.new(@user).restore_with_relations
    end

    def unspam
      UserCommand.new(@user).unspam_and_restore_with_relations
    end

    def spam
      UserCommand.new(@user).spam_soft_delete_with_relations

      respond_to do |format|
        format.html { redirect_to admin_users_path(filter_by: :is_spam) }
        format.js
      end
    end

    def mark_all_users_with_ip_as_spam
      ip = @user.current_login_ip
      count = User.where(current_login_ip: ip).count
      MarkAllUsersWithIpAsSpam.perform_later(ip)
      redirect_back fallback_location: { action: :index }, notice: "#{count} accounts by #{ip} being marked as spam..."
    end

    private

    def permitted_params
      params.permit(:filter_by)
    end

    def set_user
      @user = User.with_deleted.find_by_login(params[:id])
    end
  end
end

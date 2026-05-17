module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, except: %i[index]

    def index
      @pagy, @users = pagy(User.filter_by(permitted_params[:filter_by]))
    end

    def show
      @assets_pagy, @assets = pagy(@user.assets.with_deleted, limit: 5)
      @comment_pagy, @comments = pagy(@user.comments_made.with_deleted, limit: 5)
    end

    def delete
      UserCommand.new(@user).soft_delete_with_relations
      respond_with_user_row(fallback_filter: :deleted)
    end

    def restore
      UserCommand.new(@user).restore_with_relations
      respond_with_user_row(fallback_filter: nil)
    end

    def unspam
      UserCommand.new(@user).unspam_and_restore_with_relations
      respond_with_user_row(fallback_filter: nil)
    end

    def spam
      UserCommand.new(@user).spam_soft_delete_with_relations
      respond_with_user_row(fallback_filter: :is_spam)
    end

    def mark_all_users_with_ip_as_spam
      ip = @user.current_login_ip
      count = User.where(current_login_ip: ip).count
      MarkAllUsersWithIpAsSpam.perform_later(ip)
      redirect_back fallback_location: { action: :index }, notice: "#{count} accounts by #{ip} being marked as spam..."
    end

    private

    def respond_with_user_row(fallback_filter:)
      if turbo_stream_row_request?
        render turbo_stream: turbo_stream.replace(@user, partial: 'admin/users/user', locals: { user: @user })
      elsif @user.soft_deleted?
        redirect_to user_soft_deleted_location(fallback_filter), status: :see_other
      else
        redirect_back(fallback_location: admin_users_path(filter_by: fallback_filter), status: :see_other)
      end
    end

    def permitted_params
      params.permit(:filter_by)
    end

    def user_soft_deleted_location(fallback_filter)
      if admin_row_request? || request.referer.blank?
        admin_users_path(filter_by: fallback_filter)
      else
        root_path
      end
    end

    def set_user
      @user = User.with_deleted.find_by_login(params[:id])
    end
  end
end

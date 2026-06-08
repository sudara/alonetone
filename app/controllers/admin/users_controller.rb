module Admin
  class UsersController < Admin::BaseController
    layout 'admin'

    before_action :set_user, except: %i[index shared_ips bandwidth]
    before_action :admin_only, only: %i[purge]

    def index
      @admin_title = 'Users'
      @pagy, @users = pagy(User.filter_by(permitted_params[:filter_by]).includes(:profile, :avatar_image_blob))
    end

    def shared_ips
      @admin_title = 'Shared IPs'
      @shared_ips = User.with_same_ip
    end

    def bandwidth
      @admin_title = 'Bandwidth'
      @users = User.where('bandwidth_used > 0').order(bandwidth_used: :desc).limit(25)
    end

    def show
      @admin_title = @user.name
      @assets_pagy, @assets = pagy(@user.assets.with_deleted, limit: 5)
      @comment_pagy, @comments = pagy(@user.comments_made.with_deleted, limit: 5)
    end

    def delete
      UserCommand.new(@user).soft_delete_with_relations
      respond_with_user_row(fallback_filter: :deleted, notice: "#{@user.name} and all their tracks, playlists, and comments have been deleted.")
    end

    def restore
      UserCommand.new(@user).restore_with_relations
      respond_with_user_row(fallback_filter: nil, notice: "#{@user.name} and their tracks, playlists, and comments have been restored.")
    end

    def unspam
      UserCommand.new(@user).unspam_and_restore_with_relations
      respond_with_user_row(fallback_filter: nil, notice: "#{@user.name} has been unspammed and their content restored.")
    end

    def spam
      UserCommand.new(@user).spam_soft_delete_with_relations
      respond_with_user_row(fallback_filter: :is_spam, notice: "#{@user.name} has been marked as spam and their content hidden.")
    end

    def purge
      if @user.perma_deletable?
        name = @user.name
        @user.destroy
        flash[:ok] = "#{name} has been permanently deleted."
      else
        flash[:alert] = 'Only accounts soft-deleted more than 30 days ago can be permanently deleted.'
      end
      redirect_to admin_users_path(filter_by: :deleted), status: :see_other
    end

    def mark_all_users_with_ip_as_spam
      ip = @user.current_login_ip
      count = User.where(current_login_ip: ip).count
      MarkAllUsersWithIpAsSpam.perform_later(ip)
      redirect_back fallback_location: { action: :index }, notice: "#{count} accounts by #{ip} being marked as spam..."
    end

    private

    def respond_with_user_row(fallback_filter:, notice:)
      flash[:ok] = notice
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

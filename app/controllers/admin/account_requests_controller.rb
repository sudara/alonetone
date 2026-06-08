module Admin
  class AccountRequestsController < Admin::BaseController
    layout 'admin'

    before_action :set_account_request, except: %i[index]

    def index
      @admin_title = 'Account Requests'
      @pagy, @account_requests = pagy(AccountRequest.filter_by(params[:filter_by]).includes(:moderated_by))
    end

    def approve
      @user = @account_request.approve!(current_user)
      InviteNotification.approved_request(@user).deliver_now
      respond_with_account_request_row
    end

    def deny
      @account_request.deny!(current_user)
      respond_with_account_request_row
    end

    private

    def respond_with_account_request_row
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@account_request, partial: 'admin/account_requests/account_request', locals: { account_request: @account_request })
        end
        format.html { redirect_back(fallback_location: admin_account_requests_path, status: :see_other) }
      end
    end

    def set_account_request
      @account_request = AccountRequest.find(params[:id])
    end
  end
end

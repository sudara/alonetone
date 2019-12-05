module Admin
  class AccountRequestsController < Admin::BaseController
    before_action :set_account_request, except: %i[index]

    def index
      @pagy, @account_requests = pagy(AccountRequest.where(status: params[:filter_by]))
    end

    def approve
      @account_request.approve!
      respond_to :js
    end

    def deny
      @account_request.deny
      respond_to :js
    end

    private

    def set_account_request
      @account_request = AccountRequest.find(params[:id])
    end
  end
end

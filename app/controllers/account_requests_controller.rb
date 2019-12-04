class AccountRequestsController < ApplicationController
  def new
    @account_request = AccountRequest.new
  end

  def create
    @account_request = AccountRequest.new(account_request_params)

    if @account_request.save
      redirect_to @article
    else
      render 'new'
    end
  end

  def show

  end

  private

  def account_request_params
    params.require(:account_request).permit(:login, :email, :entity_type, :status)
  end
end

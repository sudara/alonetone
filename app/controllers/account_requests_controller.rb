class AccountRequestsController < ApplicationController
  def new
    @account_request = AccountRequest.new
    @page_title = "Get An Account"
  end

  def show
    @account_request = session[:email].present? && AccountRequest.where(email: session[:email]).first
    if @account_request
      @page_title = "Thank you, #{@account_request.login}"
      @email = @account_request.email
      render layout: 'pages'
    else
      redirect_to '/get_an_account'
    end
  end

  def create
    @account_request = AccountRequest.new(account_request_params)

    if @account_request.save
      session[:email] = @account_request.email
      redirect_to @account_request
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private

  def account_request_params
    params.require(:account_request).permit(:login, :email, :entity_type, :details)
  end
end

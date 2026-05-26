class AccountRequestsController < ApplicationController
  def new
    @account_request = AccountRequest.new
    @page_title = "Get An Account"
  end

  def create
    @account_request = AccountRequest.new(account_request_params)
    @account_request.remote_ip = request.remote_ip

    if @account_request.save
      if spam_detected?
        @account_request.update!(
          status: :denied,
          review_reason: "Rakismet marked as spam"
        )
        WeeklyDeniedDigestJob.schedule_next
      else
        ReviewAccountRequestJob.perform_later(@account_request.id)
      end
      @page_title = "Thank you, #{@account_request.login}"
      @email = @account_request.email
      render 'thank_you', layout: 'pages', status: 303
    else
      render 'new', status: :unprocessable_content
    end
  end

  private

  def account_request_params
    params.require(:account_request).permit(:login, :email, :entity_type, :details)
  end

  def spam_detected?
    @account_request.spam?
  rescue StandardError => e
    Rails.logger.warn("Rakismet check failed for AccountRequest #{@account_request.id}: #{e.message}")
    false
  end
end

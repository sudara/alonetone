class ReviewAccountRequestJob < ApplicationJob
  queue_as :default

  def perform(account_request_id)
    account_request = AccountRequest.find_by(id: account_request_id)
    return unless account_request&.waiting?

    result = AccountRequestReviewer.new(account_request).review
    account_request.update!(review_reason: review_reason_for(result))
    send_billing_alert(result)

    case result.decision
    when "approve"
      auto_approve(account_request)
    when "deny"
      account_request.denied!
      WeeklyDeniedDigestJob.schedule_next
    when "flag"
      InviteNotification.flagged_mod_notification(account_request).deliver_now
    end
  end

  private

  def auto_approve(account_request)
    account_request.auto_approve!
    InviteNotification.approved_request(account_request.user).deliver_now
    InviteNotification.auto_approved_mod_notification(account_request).deliver_now
  end

  def review_reason_for(result)
    result.reason.present? ? "Anthropic: #{result.reason}" : "Anthropic auto-review"
  end

  def send_billing_alert(result)
    return if result.alert_status_code.blank?

    InviteNotification.api_billing_alert(result.alert_status_code).deliver_now
  end
end

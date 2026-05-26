class InviteNotification < ApplicationMailer
  def approved_request(user)
    @login = user.login
    @password_url = edit_password_reset_url(user.perishable_token)
    @profile_url = edit_user_url(user)
    mail to: user.email, subject: "[#{hostname}] Your account was approved. Welcome!"
  end

  def auto_approved_mod_notification(account_request)
    @account_request = account_request
    @admin_url = admin_account_requests_url
    mail to: mod_emails, subject: "[#{hostname}] Auto-approved: #{account_request.login}"
  end

  def flagged_mod_notification(account_request)
    @account_request = account_request
    @admin_url = admin_account_requests_url
    mail to: mod_emails, subject: "[#{hostname}] Needs review: #{account_request.login}"
  end

  def api_billing_alert(status_code)
    @status_code = status_code
    mail to: mod_emails, subject: "[#{hostname}] Signup auto-review is down (API #{status_code})"
  end

  def weekly_denied_digest(denied_requests)
    @denied_requests = denied_requests
    @admin_url = admin_account_requests_url
    mail to: mod_emails, subject: "[#{hostname}] Weekly signup review: #{denied_requests.size} denied"
  end

  private

  def mod_emails
    User.where(moderator: true).pluck(:email)
  end
end

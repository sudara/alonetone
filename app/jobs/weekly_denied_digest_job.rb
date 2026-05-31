class WeeklyDeniedDigestJob < ApplicationJob
  queue_as :mailers

  def perform
    denied_requests = AccountRequest.denied
      .where(moderated_by_id: nil)
      .where(updated_at: 1.week.ago..)
    return if denied_requests.empty?

    InviteNotification.weekly_denied_digest(denied_requests).deliver_now
  end
end

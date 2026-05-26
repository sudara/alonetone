class WeeklyDeniedDigestJob < ApplicationJob
  RUN_DAY = 1
  RUN_HOUR = 9

  queue_as :mailers

  def self.schedule_next(now = Time.current)
    run_at = next_run_at(now)
    expires_in = [run_at - now, 0].max.seconds + 1.hour
    return unless Rails.cache.write(cache_key_for(run_at), true, expires_in: expires_in, unless_exist: true)

    set(wait_until: run_at).perform_later(run_at.to_date.iso8601)
  end

  def self.next_run_at(now = Time.current)
    run_at = now.change(hour: RUN_HOUR, min: 0, sec: 0)
    run_at += ((RUN_DAY - run_at.wday) % 7).days
    run_at > now ? run_at : run_at + 1.week
  end

  def self.cache_key_for(run_at)
    date = run_at.respond_to?(:to_date) ? run_at.to_date : Date.iso8601(run_at.to_s)
    "weekly_denied_digest_job:#{date.iso8601}"
  end

  def perform(run_on = nil)
    denied_requests = AccountRequest.denied
      .where(moderated_by_id: nil)
      .where(updated_at: 1.week.ago..)
    return if denied_requests.empty?

    InviteNotification.weekly_denied_digest(denied_requests).deliver_now
  ensure
    Rails.cache.delete(self.class.cache_key_for(run_on)) if run_on.present?
  end
end

class MarkAllUsersWithIpAsSpam < ApplicationJob
  queue_as :default

  def perform(ip)
    return unless ip.present? # older acocunts have ip as nil

    User.where(current_login_ip: ip).each do |user|
      user.spam_and_mark_for_deletion!
    end
  end
end

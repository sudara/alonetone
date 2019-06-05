class MarkAllUsersWithIpAsSpam < ApplicationJob
  queue_as :default

  def perform(ip)
    User.where(current_login_ip: ip).each do |user|
      user.spam_and_mark_for_deletion!
    end
  end
end
